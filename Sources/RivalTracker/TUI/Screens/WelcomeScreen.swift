import Foundation

/// Welcome screen for first-time users.
struct WelcomeScreen: ScreenProtocol {
    /// Callback for completing the onboarding process.
    let onboarding: (String) -> Void
    
    /// The API key input by the user.
    private var apiKey: String = ""
    
    /// The input mode.
    private var inputMode: InputMode = .normal
    
    /// The cursor position in the API key input.
    private var cursorPosition: Int = 0
    
    /// Input modes.
    private enum InputMode {
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
        
        // Draw the logo
        let logoLines = ASCIIArt.logo.split(separator: "\n")
        let logoHeight = logoLines.count
        let logoStartRow = max(0, (height - logoHeight - 10) / 2)
        
        for (i, line) in logoLines.enumerated() {
            renderer.renderAt(row: logoStartRow + i, column: max(0, (width - line.count) / 2)) {
                renderer.setForegroundColor(.cyan)
                renderer.write(String(line))
                renderer.resetColors()
            }
        }
        
        // Draw welcome text
        let welcomeText = "Welcome to RivalTracker for Marvel Rivals!"
        renderer.renderAt(row: logoStartRow + logoHeight + 2, column: max(0, (width - welcomeText.count) / 2)) {
            renderer.setForegroundColor(.brightYellow)
            renderer.write(welcomeText)
            renderer.resetColors()
        }
        
        // Draw instructions
        let instructions = "Please enter your Marvel Rivals API key to get started."
        renderer.renderAt(row: logoStartRow + logoHeight + 4, column: max(0, (width - instructions.count) / 2)) {
            renderer.write(instructions)
        }
        
        // Draw API key input
        let inputBoxWidth = min(width - 20, 60)
        let inputBoxStartColumn = max(0, (width - inputBoxWidth) / 2)
        let inputBoxRow = logoStartRow + logoHeight + 6
        
        renderer.drawBox(
            startRow: inputBoxRow,
            startColumn: inputBoxStartColumn,
            width: inputBoxWidth,
            height: 3,
            title: "API Key"
        )
        
        // Draw API key input
        let displayApiKey = apiKey.isEmpty ? "" : apiKey
        renderer.renderAt(row: inputBoxRow + 1, column: inputBoxStartColumn + 2) {
            if inputMode == .input {
                renderer.setForegroundColor(.brightWhite)
            }
            renderer.write(displayApiKey)
            renderer.resetColors()
        }
        
        // Draw the cursor
        if inputMode == .input {
            renderer.renderAt(row: inputBoxRow + 1, column: inputBoxStartColumn + 2 + cursorPosition) {
                renderer.setForegroundColor(.brightWhite)
                renderer.setBackgroundColor(.brightBlack)
                if cursorPosition < displayApiKey.count {
                    let charIndex = displayApiKey.index(displayApiKey.startIndex, offsetBy: cursorPosition)
                    renderer.write(String(displayApiKey[charIndex]))
                } else {
                    renderer.write(" ")
                }
                renderer.resetColors()
            }
        }
        
        // Draw help text
        let helpText = inputMode == .normal
            ? "Press 'i' to enter your API key, press 'Enter' to continue"
            : "Press 'Escape' to finish editing, press 'Enter' to continue"
        
        renderer.renderAt(row: inputBoxRow + 4, column: max(0, (width - helpText.count) / 2)) {
            renderer.setForegroundColor(.brightBlack)
            renderer.write(helpText)
            renderer.resetColors()
        }
        
        // Draw version information
        let versionText = "RivalTracker v1.0.0"
        renderer.renderAt(row: height - 2, column: width - versionText.count - 2) {
            renderer.setForegroundColor(.brightBlack)
            renderer.write(versionText)
            renderer.resetColors()
        }
    }
    
    /// Handle a key press.
    /// - Parameter key: The key that was pressed.
    func handleKey(_ key: Key) {
        switch inputMode {
        case .normal:
            handleNormalModeKey(key)
        case .input:
            handleInputModeKey(key)
        }
    }
    
    /// Handle a key press in normal mode.
    /// - Parameter key: The key that was pressed.
    private func handleNormalModeKey(_ key: Key) {
        switch key {
        case .character("i"), .character("I"):
            // Enter input mode
            inputMode = .input
            if apiKey.isEmpty {
                cursorPosition = 0
            } else {
                cursorPosition = apiKey.count
            }
            
        case .enter:
            // Submit the API key
            if !apiKey.isEmpty {
                onboarding(apiKey)
            }
            
        default:
            break
        }
    }
    
    /// Handle a key press in input mode.
    /// - Parameter key: The key that was pressed.
    private func handleInputModeKey(_ key: Key) {
        switch key {
        case .escape:
            // Exit input mode
            inputMode = .normal
            
        case .enter:
            // Submit the API key
            if !apiKey.isEmpty {
                inputMode = .normal
                onboarding(apiKey)
            }
            
        case .backspace:
            // Delete the character before the cursor
            if cursorPosition > 0 {
                let before = apiKey.index(apiKey.startIndex, offsetBy: cursorPosition - 1)
                let after = apiKey.index(apiKey.startIndex, offsetBy: cursorPosition)
                apiKey.removeSubrange(before..<after)
                cursorPosition -= 1
            }
            
        case .delete:
            // Delete the character at the cursor
            if cursorPosition < apiKey.count {
                let before = apiKey.index(apiKey.startIndex, offsetBy: cursorPosition)
                let after = apiKey.index(apiKey.startIndex, offsetBy: cursorPosition + 1)
                apiKey.removeSubrange(before..<after)
            }
            
        case .left:
            // Move the cursor left
            if cursorPosition > 0 {
                cursorPosition -= 1
            }
            
        case .right:
            // Move the cursor right
            if cursorPosition < apiKey.count {
                cursorPosition += 1
            }
            
        case .home:
            // Move the cursor to the start
            cursorPosition = 0
            
        case .end:
            // Move the cursor to the end
            cursorPosition = apiKey.count
            
        case .character(let char):
            // Add the character to the API key
            let before = apiKey.index(apiKey.startIndex, offsetBy: cursorPosition)
            apiKey.insert(char, at: before)
            cursorPosition += 1
            
        default:
            break
        }
    }
}