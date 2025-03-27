import Foundation

/// Screen for searching for a player.
struct PlayerSearchScreen: ScreenProtocol {
    /// Callback for searching for a player.
    let onSearch: (String) -> Void
    
    /// Callback for canceling the search.
    let onCancel: () -> Void
    
    /// The current username input.
    private var username: String = ""
    
    /// The input mode.
    private var inputMode: InputMode = .normal
    
    /// The cursor position in the username input.
    private var cursorPosition: Int = 0
    
    /// Initialize a player search screen.
    /// - Parameters:
    ///   - onSearch: Callback for searching for a player.
    ///   - onCancel: Callback for canceling the search.
    ///   - username: The current username input.
    ///   - inputMode: The input mode.
    ///   - cursorPosition: The cursor position in the username input.
    init(
        onSearch: @escaping (String) -> Void,
        onCancel: @escaping () -> Void,
        username: String = "",
        inputMode: InputMode = .normal,
        cursorPosition: Int = 0
    ) {
        self.onSearch = onSearch
        self.onCancel = onCancel
        self.username = username
        self.inputMode = inputMode
        self.cursorPosition = cursorPosition
    }
    
    /// Input modes.
    enum InputMode {
        case normal
        case input
    }
    
    /// Render the screen.
    /// - Parameter context: The screen context.
    func render(in context: ScreenContext) {
        let renderer = context.renderer
        let width = context.terminalSize.columns
        let height = context.terminalSize.rows
        
        // Clear the screen
        renderer.clearScreen()
        
        // Draw title
        let titleText = "Player Search"
        renderer.renderAt(row: 2, column: max(0, (width - titleText.count) / 2)) {
            renderer.setForegroundColor(.brightYellow)
            renderer.write(titleText)
            renderer.resetColors()
        }
        
        // Draw instructions
        let instructions = "Enter a player username to search for their stats."
        renderer.renderAt(row: 4, column: max(0, (width - instructions.count) / 2)) {
            renderer.write(instructions)
        }
        
        // Draw username input
        let inputBoxWidth = min(width - 20, 60)
        let inputBoxStartColumn = max(0, (width - inputBoxWidth) / 2)
        let inputBoxRow = 6
        
        renderer.drawBox(
            startRow: inputBoxRow,
            startColumn: inputBoxStartColumn,
            width: inputBoxWidth,
            height: 3,
            title: "Username"
        )
        
        // Draw username input
        let displayUsername = username.isEmpty ? "" : username
        renderer.renderAt(row: inputBoxRow + 1, column: inputBoxStartColumn + 2) {
            if inputMode == .input {
                renderer.setForegroundColor(.brightWhite)
            }
            renderer.write(displayUsername)
            renderer.resetColors()
        }
        
        // Draw the cursor
        if inputMode == .input {
            renderer.renderAt(row: inputBoxRow + 1, column: inputBoxStartColumn + 2 + cursorPosition) {
                renderer.setForegroundColor(.brightWhite)
                renderer.setBackgroundColor(.brightBlack)
                if cursorPosition < displayUsername.count {
                    let charIndex = displayUsername.index(displayUsername.startIndex, offsetBy: cursorPosition)
                    renderer.write(String(displayUsername[charIndex]))
                } else {
                    renderer.write(" ")
                }
                renderer.resetColors()
            }
        }
        
        // Draw help text
        let helpText = inputMode == .normal
            ? "Press 'i' to enter a username, press 'Enter' to search, press 'Esc' to go back"
            : "Press 'Escape' to finish editing, press 'Enter' to search"
        
        renderer.renderAt(row: inputBoxRow + 4, column: max(0, (width - helpText.count) / 2)) {
            renderer.setForegroundColor(.brightBlack)
            renderer.write(helpText)
            renderer.resetColors()
        }
        
        // Draw navigation help
        let navHelp = "Vim-style navigation: i to edit, Esc to exit edit mode"
        renderer.renderAt(row: height - 4, column: max(0, (width - navHelp.count) / 2)) {
            renderer.setForegroundColor(.brightBlack)
            renderer.write(navHelp)
            renderer.resetColors()
        }
    }
    
    /// Handle a key press.
    /// - Parameter key: The key that was pressed.
    mutating func handleKey(_ key: Key) {
        switch inputMode {
        case .normal:
            handleNormalModeKey(key)
        case .input:
            handleInputModeKey(key)
        }
    }
    
    /// Handle a key press in normal mode.
    /// - Parameter key: The key that was pressed.
    private mutating func handleNormalModeKey(_ key: Key) {
        switch key {
        case .character("i"), .character("I"):
            // Enter input mode
            inputMode = .input
            if username.isEmpty {
                cursorPosition = 0
            } else {
                cursorPosition = username.count
            }
            
        case .enter:
            // Submit the username
            if !username.isEmpty {
                onSearch(username)
            }
            
        case .escape:
            // Cancel the search
            onCancel()
            
        default:
            break
        }
    }
    
    /// Handle a key press in input mode.
    /// - Parameter key: The key that was pressed.
    private mutating func handleInputModeKey(_ key: Key) {
        switch key {
        case .escape:
            // Exit input mode
            inputMode = .normal
            
        case .enter:
            // Submit the username
            if !username.isEmpty {
                inputMode = .normal
                onSearch(username)
            }
            
        case .backspace:
            // Delete the character before the cursor
            if cursorPosition > 0 {
                let before = username.index(username.startIndex, offsetBy: cursorPosition - 1)
                let after = username.index(username.startIndex, offsetBy: cursorPosition)
                username.removeSubrange(before..<after)
                cursorPosition -= 1
            }
            
        case .delete:
            // Delete the character at the cursor
            if cursorPosition < username.count {
                let before = username.index(username.startIndex, offsetBy: cursorPosition)
                let after = username.index(username.startIndex, offsetBy: cursorPosition + 1)
                username.removeSubrange(before..<after)
            }
            
        case .left:
            // Move the cursor left
            if cursorPosition > 0 {
                cursorPosition -= 1
            }
            
        case .right:
            // Move the cursor right
            if cursorPosition < username.count {
                cursorPosition += 1
            }
            
        case .home:
            // Move the cursor to the start
            cursorPosition = 0
            
        case .end:
            // Move the cursor to the end
            cursorPosition = username.count
            
        case .character(let char):
            // Add the character to the username
            let before = username.index(username.startIndex, offsetBy: cursorPosition)
            username.insert(char, at: before)
            cursorPosition += 1
            
        default:
            break
        }
    }
}