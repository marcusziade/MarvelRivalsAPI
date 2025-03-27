import Foundation
import MarvelRivalsAPI

/// Screen for searching for a match.
struct MatchSearchScreen: ScreenProtocol {
    /// Callback for searching for a match.
    let onSearch: (String) -> Void
    
    /// Callback for canceling the search.
    let onCancel: () -> Void
    
    /// The current match ID input.
    private var matchId: String = ""
    
    /// The input mode.
    private var inputMode: InputMode = .normal
    
    /// The cursor position in the match ID input.
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
        
        // Draw title
        let titleText = "Match Analysis"
        renderer.renderAt(row: 2, column: max(0, (width - titleText.count) / 2)) {
            renderer.setForegroundColor(.brightYellow)
            renderer.write(titleText)
            renderer.resetColors()
        }
        
        // Draw instructions
        let instructions = "Enter a match ID to analyze match details."
        renderer.renderAt(row: 4, column: max(0, (width - instructions.count) / 2)) {
            renderer.write(instructions)
        }
        
        // Draw match ID input
        let inputBoxWidth = min(width - 20, 60)
        let inputBoxStartColumn = max(0, (width - inputBoxWidth) / 2)
        let inputBoxRow = 6
        
        renderer.drawBox(
            startRow: inputBoxRow,
            startColumn: inputBoxStartColumn,
            width: inputBoxWidth,
            height: 3,
            title: "Match ID"
        )
        
        // Draw match ID input
        let displayMatchId = matchId.isEmpty ? "" : matchId
        renderer.renderAt(row: inputBoxRow + 1, column: inputBoxStartColumn + 2) {
            if inputMode == .input {
                renderer.setForegroundColor(.brightWhite)
            }
            renderer.write(displayMatchId)
            renderer.resetColors()
        }
        
        // Draw the cursor
        if inputMode == .input {
            let cursorColumn = inputBoxStartColumn + 2 + cursorPosition
            
            renderer.renderAt(row: inputBoxRow + 1, column: cursorColumn) {
                renderer.setForegroundColor(.brightWhite)
                renderer.setBackgroundColor(.brightBlack)
                
                if cursorPosition < displayMatchId.count {
                    let charIndex = displayMatchId.index(displayMatchId.startIndex, offsetBy: cursorPosition)
                    renderer.write(String(displayMatchId[charIndex]))
                } else {
                    renderer.write(" ")
                }
                
                renderer.resetColors()
            }
        }
        
        // Draw help text
        let helpText = inputMode == .normal
            ? "Press 'i' to enter a match ID, press 'Enter' to search, press 'Esc' to go back"
            : "Press 'Escape' to finish editing, press 'Enter' to search"
        
        renderer.renderAt(row: inputBoxRow + 4, column: max(0, (width - helpText.count) / 2)) {
            renderer.setForegroundColor(.brightBlack)
            renderer.write(helpText)
            renderer.resetColors()
        }
        
        // Draw match analysis information
        let infoStartRow = inputBoxRow + 6
        
        renderer.renderAt(row: infoStartRow, column: inputBoxStartColumn) {
            renderer.setForegroundColor(.brightCyan)
            renderer.write("Match Analysis Features:")
            renderer.resetColors()
        }
        
        let features = [
            "• Detailed match statistics for all players",
            "• Team composition analysis",
            "• Player performance metrics",
            "• Hero usage and effectiveness",
            "• Compare to historical averages"
        ]
        
        for (i, feature) in features.enumerated() {
            renderer.renderAt(row: infoStartRow + 2 + i, column: inputBoxStartColumn) {
                renderer.write(feature)
            }
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
            if matchId.isEmpty {
                cursorPosition = 0
            } else {
                cursorPosition = matchId.count
            }
            
        case .enter:
            // Submit the match ID
            if !matchId.isEmpty {
                onSearch(matchId)
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
    private func handleInputModeKey(_ key: Key) {
        switch key {
        case .escape:
            // Exit input mode
            inputMode = .normal
            
        case .enter:
            // Submit the match ID
            if !matchId.isEmpty {
                inputMode = .normal
                onSearch(matchId)
            }
            
        case .backspace:
            // Delete the character before the cursor
            if cursorPosition > 0 {
                let before = matchId.index(matchId.startIndex, offsetBy: cursorPosition - 1)
                let after = matchId.index(matchId.startIndex, offsetBy: cursorPosition)
                matchId.removeSubrange(before..<after)
                cursorPosition -= 1
            }
            
        case .delete:
            // Delete the character at the cursor
            if cursorPosition < matchId.count {
                let before = matchId.index(matchId.startIndex, offsetBy: cursorPosition)
                let after = matchId.index(matchId.startIndex, offsetBy: cursorPosition + 1)
                matchId.removeSubrange(before..<after)
            }
            
        case .left:
            // Move the cursor left
            if cursorPosition > 0 {
                cursorPosition -= 1
            }
            
        case .right:
            // Move the cursor right
            if cursorPosition < matchId.count {
                cursorPosition += 1
            }
            
        case .home:
            // Move the cursor to the start
            cursorPosition = 0
            
        case .end:
            // Move the cursor to the end
            cursorPosition = matchId.count
            
        case .character(let char):
            // Add the character to the match ID
            let before = matchId.index(matchId.startIndex, offsetBy: cursorPosition)
            matchId.insert(char, at: before)
            cursorPosition += 1
            
        default:
            break
        }
    }
}