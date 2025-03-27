import Foundation

/// Screen for displaying help information.
struct HelpScreen: ScreenProtocol {
    /// Callback for going back to the previous screen.
    let onBack: () -> Void
    
    /// The selected section.
    private var selectedSection: Int = 0
    
    /// Initialize a new help screen.
    /// - Parameters:
    ///   - onBack: Callback for going back to the previous screen.
    ///   - selectedSection: The selected section. Default is 0.
    init(
        onBack: @escaping () -> Void,
        selectedSection: Int = 0
    ) {
        self.onBack = onBack
        self.selectedSection = selectedSection
    }
    
    /// The help sections.
    private let sections = [
        ("Navigation", [
            "j/↓: Move down",
            "k/↑: Move up",
            "h/←: Move left or previous tab",
            "l/→: Move right or next tab",
            "Enter: Select item",
            "Space: Select item",
            "Esc: Go back or exit",
            "q: Quit (from main menu)"
        ]),
        ("Input", [
            "i: Enter input mode",
            "Esc: Exit input mode",
            "Enter: Submit input",
            "Backspace: Delete character before cursor",
            "Delete: Delete character at cursor",
            "←/→: Move cursor left/right",
            "Home: Move cursor to start",
            "End: Move cursor to end"
        ]),
        ("Search", [
            "/: Enter search mode",
            "n: Next search result",
            "N: Previous search result",
            "Esc: Exit search mode"
        ]),
        ("Commands", [
            ":r or r: Refresh data",
            ":q or q: Quit",
            ":h or ?: Show help",
            ":b or b: Go back"
        ]),
        ("About", [
            "RivalTracker v1.0.0",
            "A terminal user interface for Marvel Rivals",
            "Created by: Your Name",
            "API Version: v1",
            "",
            "This is an unofficial tool and is not affiliated",
            "with Marvel or NetEase Games."
        ])
    ]
    
    /// Render the screen.
    /// - Parameter context: The screen context.
    func render(in context: ScreenContext) {
        let renderer = context.renderer
        let width = context.terminalSize.columns
        let height = context.terminalSize.rows
        
        // Clear the screen
        renderer.clearScreen()
        
        // Draw header
        let headerText = "RivalTracker Help"
        renderer.renderAt(row: 1, column: max(0, (width - headerText.count) / 2)) {
            renderer.setForegroundColor(.brightYellow)
            renderer.write(headerText)
            renderer.resetColors()
        }
        
        // Draw sections on the left
        let sectionListWidth = 20
        let sectionContentStartColumn = sectionListWidth + 4
        
        renderer.renderAt(row: 3, column: 2) {
            renderer.setForegroundColor(.brightCyan)
            renderer.write("Help Topics")
            renderer.resetColors()
        }
        
        // Draw section list
        for (i, (section, _)) in sections.enumerated() {
            let isSelected = i == selectedSection
            
            renderer.renderAt(row: 5 + i, column: 2) {
                if isSelected {
                    renderer.setForegroundColor(.brightWhite)
                    renderer.setBackgroundColor(.blue)
                    renderer.write("> \(section)")
                    renderer.resetColors()
                } else {
                    renderer.write("  \(section)")
                }
            }
        }
        
        // Draw vertical separator
        for i in 3..<height - 2 {
            renderer.renderAt(row: i, column: sectionContentStartColumn - 2) {
                renderer.write("│")
            }
        }
        
        // Draw selected section content
        let (sectionTitle, sectionContent) = sections[selectedSection]
        
        renderer.renderAt(row: 3, column: sectionContentStartColumn) {
            renderer.setForegroundColor(.brightCyan)
            renderer.write(sectionTitle)
            renderer.resetColors()
        }
        
        for (i, line) in sectionContent.enumerated() {
            renderer.renderAt(row: 5 + i, column: sectionContentStartColumn) {
                renderer.write(line)
            }
        }
        
        // Draw navigation help
        let navHelp = "j/k to navigate sections, b or Esc to go back"
        renderer.renderAt(row: height - 2, column: max(0, (width - navHelp.count) / 2)) {
            renderer.setForegroundColor(.brightBlack)
            renderer.write(navHelp)
            renderer.resetColors()
        }
    }
    
    /// Handle a key press.
    /// - Parameter key: The key that was pressed.
    mutating func handleKey(_ key: Key) {
        switch key {
        case .up, .character("k"):
            // Move up in section list
            if selectedSection > 0 {
                selectedSection -= 1
            }
            
        case .down, .character("j"):
            // Move down in section list
            if selectedSection < sections.count - 1 {
                selectedSection += 1
            }
            
        case .escape, .character("b"), .character("q"):
            // Go back
            onBack()
            
        default:
            break
        }
    }
}