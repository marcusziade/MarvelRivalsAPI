import Foundation

/// Main menu screen.
struct MainMenuScreen: ScreenProtocol {
    /// Callback for player dashboard option.
    let onPlayerDashboard: () -> Void
    
    /// Callback for hero explorer option.
    let onHeroExplorer: () -> Void
    
    /// Callback for match analysis option.
    let onMatchAnalysis: () -> Void
    
    /// Callback for leaderboards option.
    let onLeaderboards: () -> Void
    
    /// Callback for settings option.
    let onSettings: () -> Void
    
    /// Callback for help option.
    let onHelp: () -> Void
    
    /// Callback for exit option.
    let onExit: () -> Void
    
    /// The currently selected menu item.
    private var selectedItem: Int = 0
    
    /// Initialize a main menu screen.
    /// - Parameters:
    ///   - onPlayerDashboard: Callback for player dashboard option.
    ///   - onHeroExplorer: Callback for hero explorer option.
    ///   - onMatchAnalysis: Callback for match analysis option.
    ///   - onLeaderboards: Callback for leaderboards option.
    ///   - onSettings: Callback for settings option.
    ///   - onHelp: Callback for help option.
    ///   - onExit: Callback for exit option.
    ///   - selectedItem: The currently selected menu item. Default is 0.
    init(
        onPlayerDashboard: @escaping () -> Void,
        onHeroExplorer: @escaping () -> Void,
        onMatchAnalysis: @escaping () -> Void,
        onLeaderboards: @escaping () -> Void,
        onSettings: @escaping () -> Void,
        onHelp: @escaping () -> Void,
        onExit: @escaping () -> Void,
        selectedItem: Int = 0
    ) {
        self.onPlayerDashboard = onPlayerDashboard
        self.onHeroExplorer = onHeroExplorer
        self.onMatchAnalysis = onMatchAnalysis
        self.onLeaderboards = onLeaderboards
        self.onSettings = onSettings
        self.onHelp = onHelp
        self.onExit = onExit
        self.selectedItem = selectedItem
    }
    
    /// The menu items.
    private let menuItems = [
        "Player Dashboard",
        "Hero Explorer",
        "Match Analysis",
        "Leaderboards & Community",
        "Settings",
        "Help",
        "Exit"
    ]
    
    /// Render the screen.
    /// - Parameter context: The screen context.
    func render(in context: ScreenContext) {
        let renderer = context.renderer
        let width = context.terminalSize.columns
        let height = context.terminalSize.rows
        
        // Clear the screen
        renderer.clearScreen()
        
        // Draw the logo
        let logoLines = ASCIIArt.smallLogo.split(separator: "\n")
        let logoHeight = logoLines.count
        let logoStartRow = 2
        
        for (i, line) in logoLines.enumerated() {
            renderer.renderAt(row: logoStartRow + i, column: max(0, (width - line.count) / 2)) {
                renderer.setForegroundColor(.cyan)
                renderer.write(String(line))
                renderer.resetColors()
            }
        }
        
        // Draw title
        let titleText = "Main Menu"
        renderer.renderAt(row: logoStartRow + logoHeight + 2, column: max(0, (width - titleText.count) / 2)) {
            renderer.setForegroundColor(.brightYellow)
            renderer.write(titleText)
            renderer.resetColors()
        }
        
        // Draw menu items
        let menuStartRow = logoStartRow + logoHeight + 4
        let menuWidth = 30
        let menuStartColumn = max(0, (width - menuWidth) / 2)
        
        for (i, item) in menuItems.enumerated() {
            renderer.renderAt(row: menuStartRow + i * 2, column: menuStartColumn) {
                if i == selectedItem {
                    renderer.setForegroundColor(.brightWhite)
                    renderer.write("> ")
                } else {
                    renderer.write("  ")
                }
                
                renderer.write(item)
                renderer.resetColors()
            }
        }
        
        // Draw navigation help
        let navHelp = "Use j/k or ↑/↓ to navigate, Enter to select"
        renderer.renderAt(row: height - 4, column: max(0, (width - navHelp.count) / 2)) {
            renderer.setForegroundColor(.brightBlack)
            renderer.write(navHelp)
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
    mutating func handleKey(_ key: Key) {
        switch key {
        case .up, .character("k"):
            // Move up
            if selectedItem > 0 {
                selectedItem -= 1
            } else {
                selectedItem = menuItems.count - 1
            }
            
        case .down, .character("j"):
            // Move down
            if selectedItem < menuItems.count - 1 {
                selectedItem += 1
            } else {
                selectedItem = 0
            }
            
        case .enter, .character(" "):
            // Select the menu item
            selectMenuItem()
            
        case .escape, .character("q"):
            // Exit
            onExit()
            
        default:
            // If the key is a number and in range, select that menu item
            if case .character(let char) = key, let index = Int(String(char)), index > 0, index <= menuItems.count {
                selectedItem = index - 1
                selectMenuItem()
            }
        }
    }
    
    /// Select the current menu item.
    private func selectMenuItem() {
        switch selectedItem {
        case 0:
            onPlayerDashboard()
        case 1:
            onHeroExplorer()
        case 2:
            onMatchAnalysis()
        case 3:
            onLeaderboards()
        case 4:
            onSettings()
        case 5:
            onHelp()
        case 6:
            onExit()
        default:
            break
        }
    }
}