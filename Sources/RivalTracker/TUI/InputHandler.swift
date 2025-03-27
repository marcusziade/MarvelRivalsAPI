import Foundation
#if os(Linux)
import Glibc
#else
import Darwin
#endif
import NIOPosix

/// Key representation.
enum Key: Equatable {
    case character(Character)
    case enter
    case escape
    case tab
    case backspace
    case delete
    case up
    case down
    case left
    case right
    case home
    case end
    case pageUp
    case pageDown
    case function(Int)
    case combination(Character) // Ctrl+character
    case alt(Character)        // Alt+character
    case unknown([UInt8])
    
    /// Check if the key is a quit key (Ctrl+C or Ctrl+D).
    var isQuit: Bool {
        switch self {
        case .combination(let char) where char == "c" || char == "d":
            return true
        default:
            return false
        }
    }
    
    /// Check if the key is a navigation key.
    var isNavigation: Bool {
        switch self {
        case .up, .down, .left, .right, .home, .end, .pageUp, .pageDown:
            return true
        case .character(let char) where char == "h" || char == "j" || char == "k" || char == "l":
            return true
        default:
            return false
        }
    }
    
    /// Check if the key is a command key (colon).
    var isCommand: Bool {
        switch self {
        case .character(let char) where char == ":":
            return true
        default:
            return false
        }
    }
    
    /// Check if the key is a search key (forward slash).
    var isSearch: Bool {
        switch self {
        case .character(let char) where char == "/":
            return true
        default:
            return false
        }
    }
}

/// Protocol for handling input events.
protocol InputHandlerDelegate: AnyObject {
    /// Called when a key is received.
    /// - Parameters:
    ///   - handler: The input handler.
    ///   - key: The key that was received.
    func inputHandler(_ handler: InputHandler, didReceiveKey key: Key)
}

/// Handler for keyboard input.
final class InputHandler {
    /// The delegate that will receive input events.
    weak var delegate: InputHandlerDelegate?
    
    /// The input channel for reading keyboard input.
    private var readChannel: NIOFileHandle?
    
    /// The event loop for processing input.
    private let eventLoop = MultiThreadedEventLoopGroup(numberOfThreads: 1).next()
    
    /// The input task.
    private var inputTask: Task<Void, Never>?
    
    /// Initialize the input handler.
    init() {}
    
    /// Start handling input.
    func startHandlingInput() {
        // Create a file handle for standard input
        let inputFd = FileHandle.standardInput.fileDescriptor
        let readNIOHandle = NIOFileHandle(descriptor: inputFd)
        self.readChannel = readNIOHandle
        
        // Start the input task
        self.inputTask = Task {
            do {
                while !Task.isCancelled {
                    if let key = try await readKey() {
                        delegate?.inputHandler(self, didReceiveKey: key)
                        
                        // Check for quit key
                        if key.isQuit {
                            break
                        }
                    }
                    
                    // Small delay to prevent high CPU usage
                    try await Task.sleep(nanoseconds: 10_000_000) // 10ms
                }
            } catch {
                print("Error reading input: \(error)")
            }
        }
    }
    
    /// Stop handling input.
    func stopHandlingInput() {
        // Cancel the input task
        inputTask?.cancel()
        inputTask = nil
        
        // Close the read channel
        try? readChannel?.close()
        readChannel = nil
    }
    
    /// Read a key from the input.
    /// - Returns: The key that was read, or nil if no key was available.
    private func readKey() async throws -> Key? {
        guard let readChannel = readChannel else {
            return nil
        }
        
        var buffer = [UInt8](repeating: 0, count: 32)
        let bytesRead = try await readChannel.read(into: &buffer, at: 0, max: buffer.count)
        
        if bytesRead == 0 {
            return nil
        }
        
        // Parse the key from the buffer
        return parseKey(buffer: buffer, bytesRead: bytesRead)
    }
    
    /// Parse a key from a buffer.
    /// - Parameters:
    ///   - buffer: The buffer containing the key data.
    ///   - bytesRead: The number of bytes read.
    /// - Returns: The parsed key.
    private func parseKey(buffer: [UInt8], bytesRead: Int) -> Key {
        let bytes = Array(buffer.prefix(bytesRead))
        
        switch bytes.count {
        case 1:
            // Single byte keys
            switch bytes[0] {
            case 0x0A, 0x0D: // Enter
                return .enter
            case 0x09: // Tab
                return .tab
            case 0x1B: // Escape
                return .escape
            case 0x7F, 0x08: // Backspace
                return .backspace
            case 0x01...0x1A: // Ctrl+A through Ctrl+Z
                let char = Character(UnicodeScalar(0x60 + bytes[0]))
                return .combination(char)
            default:
                if let scalar = UnicodeScalar(bytes[0]) {
                    return .character(Character(scalar))
                }
            }
            
        case 2:
            // Two byte keys (most likely Alt+key)
            if bytes[0] == 0x1B {
                if let scalar = UnicodeScalar(bytes[1]) {
                    return .alt(Character(scalar))
                }
            }
            
        case 3:
            // Three byte keys (most likely arrow keys)
            if bytes[0] == 0x1B && bytes[1] == 0x5B {
                switch bytes[2] {
                case 0x41: return .up
                case 0x42: return .down
                case 0x43: return .right
                case 0x44: return .left
                case 0x48: return .home
                case 0x46: return .end
                default: break
                }
            }
            
        case 4:
            // Four byte keys
            if bytes[0] == 0x1B && bytes[1] == 0x5B && bytes[3] == 0x7E {
                switch bytes[2] {
                case 0x32: return .delete
                case 0x35: return .pageUp
                case 0x36: return .pageDown
                default: break
                }
            }
        default:
            break
        }
        
        // Unknown key sequence
        return .unknown(bytes)
    }
}