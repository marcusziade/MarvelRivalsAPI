import Foundation
#if os(Linux)
import Glibc
#else
import Darwin
#endif
import SystemPackage

/// Terminal size information.
struct TerminalSize: Equatable {
    /// The number of columns (width).
    let columns: Int
    
    /// The number of rows (height).
    let rows: Int
}

/// Utility for interacting with the terminal.
enum Terminal {
    /// Get the current terminal size.
    /// - Returns: The terminal size.
    static func size() -> TerminalSize {
        #if os(Linux)
        var size = winsize()
        if ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &size) == 0 {
            return TerminalSize(columns: Int(size.ws_col), rows: Int(size.ws_row))
        }
        #else
        var size = winsize()
        if ioctl(STDOUT_FILENO, TIOCGWINSZ, &size) == 0 {
            return TerminalSize(columns: Int(size.ws_col), rows: Int(size.ws_row))
        }
        #endif
        
        // Fallback to default size
        return TerminalSize(columns: 80, rows: 24)
    }
    
    /// Enter raw mode for terminal input.
    static func enterRawMode() {
        #if os(Linux)
        var termios = termios()
        tcgetattr(STDIN_FILENO, &termios)
        
        // Save original termios to restore on exit
        var original = termios
        
        // Set raw mode flags
        termios.c_iflag &= ~(UInt32(ICRNL) | UInt32(IXON))
        termios.c_lflag &= ~(UInt32(ECHO) | UInt32(ICANON) | UInt32(IEXTEN) | UInt32(ISIG))
        termios.c_cc.15 = 1 // VMIN: minimum number of bytes to read
        termios.c_cc.16 = 0 // VTIME: timeout (tenths of seconds)
        
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &termios)
        #else
        var termios = termios()
        tcgetattr(STDIN_FILENO, &termios)
        
        // Save original termios to restore on exit
        var original = termios
        
        // Set raw mode flags
        termios.c_iflag &= ~(UInt(ICRNL) | UInt(IXON))
        termios.c_lflag &= ~(UInt(ECHO) | UInt(ICANON) | UInt(IEXTEN) | UInt(ISIG))
        termios.c_cc.pointee = 1 // VMIN: minimum number of bytes to read
        termios.c_cc.pointee = 0 // VTIME: timeout (tenths of seconds)
        
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &termios)
        #endif
    }
    
    /// Exit raw mode for terminal input.
    static func exitRawMode() {
        #if os(Linux)
        var termios = termios()
        tcgetattr(STDIN_FILENO, &termios)
        
        // Reset flags to canonical mode
        termios.c_iflag |= UInt32(ICRNL) | UInt32(IXON)
        termios.c_lflag |= UInt32(ECHO) | UInt32(ICANON) | UInt32(IEXTEN) | UInt32(ISIG)
        
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &termios)
        #else
        var termios = termios()
        tcgetattr(STDIN_FILENO, &termios)
        
        // Reset flags to canonical mode
        termios.c_iflag |= UInt(ICRNL) | UInt(IXON)
        termios.c_lflag |= UInt(ECHO) | UInt(ICANON) | UInt(IEXTEN) | UInt(ISIG)
        
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &termios)
        #endif
    }
}

/// ANSI color codes.
enum AnsiColor: String {
    case black = "30"
    case red = "31"
    case green = "32"
    case yellow = "33"
    case blue = "34"
    case magenta = "35"
    case cyan = "36"
    case white = "37"
    case brightBlack = "90"
    case brightRed = "91"
    case brightGreen = "92"
    case brightYellow = "93"
    case brightBlue = "94"
    case brightMagenta = "95"
    case brightCyan = "96"
    case brightWhite = "97"
    case reset = "0"
}

/// Terminal renderer for TUI.
final class TerminalRenderer {
    /// Initializes a new terminal renderer.
    init() {}
    
    /// Clear the screen.
    func clearScreen() {
        // Clear screen and move cursor to home position
        print("\u{001B}[2J\u{001B}[H", terminator: "")
        fflush(stdout)
    }
    
    /// Set the cursor visibility.
    /// - Parameter visible: Whether the cursor should be visible.
    func setCursorVisible(_ visible: Bool) {
        print("\u{001B}[\(visible ? "?25h" : "?25l")", terminator: "")
        fflush(stdout)
    }
    
    /// Move the cursor to a specific position.
    /// - Parameters:
    ///   - row: The row to move to (0-based).
    ///   - column: The column to move to (0-based).
    func moveCursor(to row: Int, column: Int) {
        print("\u{001B}[\(row + 1);\(column + 1)H", terminator: "")
        fflush(stdout)
    }
    
    /// Set the foreground color.
    /// - Parameter color: The color to set.
    func setForegroundColor(_ color: AnsiColor) {
        print("\u{001B}[\(color.rawValue)m", terminator: "")
        fflush(stdout)
    }
    
    /// Set the background color.
    /// - Parameter color: The color to set.
    func setBackgroundColor(_ color: AnsiColor) {
        print("\u{001B}[4\(String(color.rawValue.dropFirst()))m", terminator: "")
        fflush(stdout)
    }
    
    /// Reset all colors to default.
    func resetColors() {
        print("\u{001B}[0m", terminator: "")
        fflush(stdout)
    }
    
    /// Write text to the terminal.
    /// - Parameter text: The text to write.
    func write(_ text: String) {
        print(text, terminator: "")
        fflush(stdout)
    }
    
    /// Write text with a newline.
    /// - Parameter text: The text to write.
    func writeLine(_ text: String) {
        print(text)
        fflush(stdout)
    }
    
    /// Clear the current line.
    func clearLine() {
        print("\u{001B}[2K", terminator: "")
        fflush(stdout)
    }
    
    /// Render at a specific position.
    /// - Parameters:
    ///   - row: The row to render at (0-based).
    ///   - column: The column to render at (0-based).
    ///   - block: The block to render.
    func renderAt(row: Int, column: Int, block: () -> Void) {
        moveCursor(to: row, column: column)
        block()
    }
    
    /// Draw a box with a title.
    /// - Parameters:
    ///   - startRow: The starting row (0-based).
    ///   - startColumn: The starting column (0-based).
    ///   - width: The width of the box.
    ///   - height: The height of the box.
    ///   - title: The title of the box.
    func drawBox(startRow: Int, startColumn: Int, width: Int, height: Int, title: String? = nil) {
        // Draw top border
        moveCursor(to: startRow, column: startColumn)
        write("┌")
        
        if let title = title, !title.isEmpty {
            let titleStart = max(3, (width - title.count) / 2)
            for i in 1..<width-1 {
                if i == titleStart - 1 {
                    write("┤ ")
                } else if i == titleStart + title.count {
                    write(" ├")
                } else if i >= titleStart && i < titleStart + title.count {
                    write(String(title[title.index(title.startIndex, offsetBy: i - titleStart)]))
                } else {
                    write("─")
                }
            }
        } else {
            for _ in 1..<width-1 {
                write("─")
            }
        }
        
        write("┐")
        
        // Draw sides
        for i in 1..<height-1 {
            moveCursor(to: startRow + i, column: startColumn)
            write("│")
            moveCursor(to: startRow + i, column: startColumn + width - 1)
            write("│")
        }
        
        // Draw bottom border
        moveCursor(to: startRow + height - 1, column: startColumn)
        write("└")
        for _ in 1..<width-1 {
            write("─")
        }
        write("┘")
    }
    
    /// Draw a horizontal separator line.
    /// - Parameters:
    ///   - row: The row to draw at (0-based).
    ///   - startColumn: The starting column (0-based).
    ///   - width: The width of the line.
    func drawHorizontalLine(row: Int, startColumn: Int, width: Int) {
        moveCursor(to: row, column: startColumn)
        for _ in 0..<width {
            write("─")
        }
    }
}

/// Signal handling utilities.
enum Signal {
    /// Signal types.
    enum SignalType {
        case int
        case term
        case winch
        
        /// The signal value.
        var value: Int32 {
            switch self {
            case .int:
                #if os(Linux)
                return Int32(SIGINT)
                #else
                return SIGINT
                #endif
            case .term:
                #if os(Linux)
                return Int32(SIGTERM)
                #else
                return SIGTERM
                #endif
            case .winch:
                #if os(Linux)
                return Int32(SIGWINCH)
                #else
                return SIGWINCH
                #endif
            }
        }
    }
    
    /// Trap a signal with a handler.
    /// - Parameters:
    ///   - signal: The signal to trap.
    ///   - handler: The handler to call when the signal is received.
    static func trap(signal: SignalType, handler: @escaping (Int32) -> Void) {
        #if os(Linux)
        var action = sigaction()
        action.__sigaction_handler.sa_handler = { signal in
            handler(signal)
        }
        sigaction(signal.value, &action, nil)
        #else
        signal(signal.value) { signal in
            handler(signal)
            return
        }
        #endif
    }
}