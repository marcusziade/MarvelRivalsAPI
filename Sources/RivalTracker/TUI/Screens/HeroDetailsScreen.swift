import Foundation
import MarvelRivalsAPI

/// Screen for displaying hero details.
struct HeroDetailsScreen: ScreenProtocol {
    /// The hero to display.
    let hero: Hero
    
    /// The hero stats.
    let stats: HeroStats
    
    /// The hero leaderboard.
    let leaderboard: HeroLeaderboard
    
    /// Callback for going back to the previous screen.
    let onBack: () -> Void
    
    /// The selected tab.
    private var selectedTab: Tab = .overview
    
    /// The selected row in leaderboard.
    private var selectedRow: Int = 0
    
    /// The scroll offset for leaderboard.
    private var scrollOffset: Int = 0
    
    /// Tabs for hero details.
    private enum Tab: Int, CaseIterable {
        case overview
        case abilities
        case stats
        case leaderboard
        
        /// Title for the tab.
        var title: String {
            switch self {
            case .overview:
                return "Overview"
            case .abilities:
                return "Abilities"
            case .stats:
                return "Stats"
            case .leaderboard:
                return "Leaderboard"
            }
        }
    }
    
    /// Render the screen.
    /// - Parameter context: The screen context.
    func render(in context: ScreenContext) {
        let renderer = context.renderer
        let width = context.terminalSize.columns
        let height = context.terminalSize.rows
        
        // Clear the screen
        renderer.clearScreen()
        
        // Draw header
        let headerText = "Hero Details: \(hero.name)"
        renderer.renderAt(row: 1, column: max(0, (width - headerText.count) / 2)) {
            renderer.setForegroundColor(.brightYellow)
            renderer.write(headerText)
            renderer.resetColors()
        }
        
        // Draw role and difficulty
        let roleText = "Role: \(hero.role)"
        let difficultyText = "Difficulty: \(String(repeating: "★", count: hero.difficulty))"
        let subHeaderText = "\(roleText)  |  \(difficultyText)"
        
        renderer.renderAt(row: 2, column: max(0, (width - subHeaderText.count) / 2)) {
            renderer.write(subHeaderText)
        }
        
        // Draw tabs
        let tabsRow = 4
        var currentColumn = 2
        
        for tab in Tab.allCases {
            let isSelected = tab == selectedTab
            let tabText = tab.title
            
            renderer.renderAt(row: tabsRow, column: currentColumn) {
                if isSelected {
                    renderer.setForegroundColor(.brightWhite)
                    renderer.setBackgroundColor(.blue)
                    renderer.write(" \(tabText) ")
                    renderer.resetColors()
                } else {
                    renderer.write(" \(tabText) ")
                }
            }
            
            currentColumn += tabText.count + 3
        }
        
        // Draw horizontal line
        renderer.renderAt(row: tabsRow + 1, column: 0) {
            renderer.drawHorizontalLine(row: tabsRow + 1, startColumn: 0, width: width)
        }
        
        // Draw the selected tab content
        let contentStartRow = tabsRow + 3
        let contentHeight = height - contentStartRow - 2
        
        switch selectedTab {
        case .overview:
            renderOverviewTab(renderer: renderer, startRow: contentStartRow, width: width, height: contentHeight)
        case .abilities:
            renderAbilitiesTab(renderer: renderer, startRow: contentStartRow, width: width, height: contentHeight)
        case .stats:
            renderStatsTab(renderer: renderer, startRow: contentStartRow, width: width, height: contentHeight)
        case .leaderboard:
            renderLeaderboardTab(renderer: renderer, startRow: contentStartRow, width: width, height: contentHeight)
        }
        
        // Draw navigation help
        let navHelp = "h/l to switch tabs, j/k to navigate, b or Esc to go back"
        renderer.renderAt(row: height - 1, column: max(0, (width - navHelp.count) / 2)) {
            renderer.setForegroundColor(.brightBlack)
            renderer.write(navHelp)
            renderer.resetColors()
        }
    }
    
    /// Render the overview tab.
    /// - Parameters:
    ///   - renderer: The terminal renderer.
    ///   - startRow: The row to start rendering at.
    ///   - width: The width of the terminal.
    ///   - height: The height of the content area.
    private func renderOverviewTab(renderer: TerminalRenderer, startRow: Int, width: Int, height: Int) {
        // Draw hero description
        let descriptionTitle = "Description"
        renderer.renderAt(row: startRow, column: 2) {
            renderer.setForegroundColor(.brightCyan)
            renderer.write(descriptionTitle)
            renderer.resetColors()
        }
        
        let descriptionLines = wrapText(hero.description, width: width - 4)
        for (i, line) in descriptionLines.enumerated().prefix(min(5, height - 2)) {
            renderer.renderAt(row: startRow + 2 + i, column: 2) {
                renderer.write(line)
            }
        }
        
        // Draw hero backstory if available
        if let backstory = hero.backstory, !backstory.isEmpty {
            let backstoryTitle = "Backstory"
            renderer.renderAt(row: startRow + 8, column: 2) {
                renderer.setForegroundColor(.brightCyan)
                renderer.write(backstoryTitle)
                renderer.resetColors()
            }
            
            let backstoryLines = wrapText(backstory, width: width - 4)
            for (i, line) in backstoryLines.enumerated().prefix(min(6, height - 10)) {
                renderer.renderAt(row: startRow + 10 + i, column: 2) {
                    renderer.write(line)
                }
            }
        }
        
        // Draw pick and win rates
        renderer.renderAt(row: startRow, column: width - 30) {
            renderer.setForegroundColor(.brightCyan)
            renderer.write("Hero Stats")
            renderer.resetColors()
        }
        
        renderer.renderAt(row: startRow + 2, column: width - 30) {
            renderer.write("Pick Rate: ")
            renderer.setForegroundColor(.brightYellow)
            renderer.write(String(format: "%.1f%%", stats.pickRate * 100))
            renderer.resetColors()
        }
        
        renderer.renderAt(row: startRow + 3, column: width - 30) {
            renderer.write("Win Rate:  ")
            renderer.setForegroundColor(.brightGreen)
            renderer.write(String(format: "%.1f%%", stats.winRate * 100))
            renderer.resetColors()
        }
        
        renderer.renderAt(row: startRow + 4, column: width - 30) {
            renderer.write("Ban Rate:  ")
            renderer.setForegroundColor(.brightRed)
            renderer.write(String(format: "%.1f%%", stats.banRate * 100))
            renderer.resetColors()
        }
        
        renderer.renderAt(row: startRow + 6, column: width - 30) {
            renderer.write("Tier Rating: ")
            renderer.setForegroundColor(.brightMagenta)
            renderer.write(stats.tierRating)
            renderer.resetColors()
        }
        
        // Draw play style
        renderer.renderAt(row: startRow + 8, column: width - 30) {
            renderer.write("Play Style: ")
        }
        
        for (i, style) in stats.playStyle.enumerated().prefix(3) {
            renderer.renderAt(row: startRow + 9 + i, column: width - 28) {
                renderer.write("- \(style)")
            }
        }
    }
    
    /// Render the abilities tab.
    /// - Parameters:
    ///   - renderer: The terminal renderer.
    ///   - startRow: The row to start rendering at.
    ///   - width: The width of the terminal.
    ///   - height: The height of the content area.
    private func renderAbilitiesTab(renderer: TerminalRenderer, startRow: Int, width: Int, height: Int) {
        // Draw title
        let titleText = "Abilities"
        renderer.renderAt(row: startRow, column: 2) {
            renderer.setForegroundColor(.brightCyan)
            renderer.write(titleText)
            renderer.resetColors()
        }
        
        // Draw abilities
        var currentRow = startRow + 2
        
        for (i, ability) in hero.abilities.enumerated() {
            if currentRow >= startRow + height - 2 {
                break
            }
            
            // Draw ability name and cooldown
            renderer.renderAt(row: currentRow, column: 2) {
                renderer.setForegroundColor(.brightYellow)
                renderer.write(ability.name)
                renderer.resetColors()
                
                if let cooldown = ability.cooldown {
                    renderer.write(" (Cooldown: \(cooldown))")
                }
            }
            
            currentRow += 1
            
            // Draw ability description
            let descriptionLines = wrapText(ability.description, width: width - 4)
            for line in descriptionLines {
                if currentRow >= startRow + height - 2 {
                    break
                }
                
                renderer.renderAt(row: currentRow, column: 4) {
                    renderer.write(line)
                }
                
                currentRow += 1
            }
            
            // Add a blank line between abilities
            if i < hero.abilities.count - 1 {
                currentRow += 1
            }
        }
    }
    
    /// Render the stats tab.
    /// - Parameters:
    ///   - renderer: The terminal renderer.
    ///   - startRow: The row to start rendering at.
    ///   - width: The width of the terminal.
    ///   - height: The height of the content area.
    private func renderStatsTab(renderer: TerminalRenderer, startRow: Int, width: Int, height: Int) {
        // Draw title
        let titleText = "Hero Statistics"
        renderer.renderAt(row: startRow, column: 2) {
            renderer.setForegroundColor(.brightCyan)
            renderer.write(titleText)
            renderer.resetColors()
        }
        
        // Draw hero stats graph
        renderer.renderAt(row: startRow + 2, column: 2) {
            renderer.write("Pick Rate: ")
            let pickRateBar = ASCIIArt.bar(value: stats.pickRate, maxValue: 0.3, width: 30)
            renderer.setForegroundColor(.blue)
            renderer.write(pickRateBar)
            renderer.resetColors()
        }
        
        renderer.renderAt(row: startRow + 3, column: 2) {
            renderer.write("Win Rate:  ")
            let winRateBar = ASCIIArt.bar(value: stats.winRate, maxValue: 0.65, width: 30)
            renderer.setForegroundColor(.green)
            renderer.write(winRateBar)
            renderer.resetColors()
        }
        
        renderer.renderAt(row: startRow + 4, column: 2) {
            renderer.write("Ban Rate:  ")
            let banRateBar = ASCIIArt.bar(value: stats.banRate, maxValue: 0.2, width: 30)
            renderer.setForegroundColor(.red)
            renderer.write(banRateBar)
            renderer.resetColors()
        }
        
        // Draw hero counters
        let countersTitle = "Countered By"
        renderer.renderAt(row: startRow + 6, column: 2) {
            renderer.setForegroundColor(.brightCyan)
            renderer.write(countersTitle)
            renderer.resetColors()
        }
        
        for (i, counter) in stats.counters.enumerated().prefix(5) {
            renderer.renderAt(row: startRow + 8 + i, column: 4) {
                renderer.write("\(counter.heroName): \(counter.reason)")
            }
        }
        
        // Draw heroes countered by this hero
        let strongAgainstTitle = "Strong Against"
        renderer.renderAt(row: startRow + 6, column: width / 2 + 2) {
            renderer.setForegroundColor(.brightCyan)
            renderer.write(strongAgainstTitle)
            renderer.resetColors()
        }
        
        for (i, counter) in stats.strongAgainst.enumerated().prefix(5) {
            renderer.renderAt(row: startRow + 8 + i, column: width / 2 + 4) {
                renderer.write("\(counter.heroName): \(counter.reason)")
            }
        }
    }
    
    /// Render the leaderboard tab.
    /// - Parameters:
    ///   - renderer: The terminal renderer.
    ///   - startRow: The row to start rendering at.
    ///   - width: The width of the terminal.
    ///   - height: The height of the content area.
    private func renderLeaderboardTab(renderer: TerminalRenderer, startRow: Int, width: Int, height: Int) {
        // Draw title
        let titleText = "Hero Leaderboard - Platform: \(leaderboard.platform)"
        renderer.renderAt(row: startRow, column: 2) {
            renderer.setForegroundColor(.brightCyan)
            renderer.write(titleText)
            renderer.resetColors()
        }
        
        // Draw column headers
        renderer.renderAt(row: startRow + 2, column: 2) {
            renderer.setForegroundColor(.brightBlack)
            renderer.write("Rank".padding(toLength: 10, withPad: " ", startingAt: 0))
            renderer.write("Player".padding(toLength: 30, withPad: " ", startingAt: 0))
            renderer.write("Score".padding(toLength: 15, withPad: " ", startingAt: 0))
            renderer.write("Platform".padding(toLength: 15, withPad: " ", startingAt: 0))
            renderer.resetColors()
        }
        
        // Draw horizontal line
        renderer.renderAt(row: startRow + 3, column: 0) {
            renderer.drawHorizontalLine(row: startRow + 3, startColumn: 0, width: width)
        }
        
        // Calculate visible rows
        let visibleRows = height - 6 // Accounting for header and footer
        
        // Adjust scroll offset if necessary
        if selectedRow < scrollOffset {
            scrollOffset = selectedRow
        } else if selectedRow >= scrollOffset + visibleRows {
            scrollOffset = selectedRow - visibleRows + 1
        }
        
        // Draw leaderboard entries
        let entries = leaderboard.leaderboard
        for i in 0..<min(visibleRows, entries.count - scrollOffset) {
            let entryIndex = i + scrollOffset
            let entry = entries[entryIndex]
            let isSelected = entryIndex == selectedRow
            
            renderer.renderAt(row: startRow + 4 + i, column: 2) {
                if isSelected {
                    renderer.setForegroundColor(.brightWhite)
                    renderer.setBackgroundColor(.blue)
                }
                
                renderer.write("#\(entry.rank)".padding(toLength: 10, withPad: " ", startingAt: 0))
                renderer.write(entry.playerName.padding(toLength: 30, withPad: " ", startingAt: 0))
                renderer.write("\(entry.score)".padding(toLength: 15, withPad: " ", startingAt: 0))
                renderer.write(entry.platform.padding(toLength: 15, withPad: " ", startingAt: 0))
                
                if isSelected {
                    renderer.resetColors()
                }
            }
        }
        
        // Draw scroll indicators if necessary
        if entries.count > visibleRows {
            if scrollOffset > 0 {
                renderer.renderAt(row: startRow + 4, column: width - 5) {
                    renderer.setForegroundColor(.brightBlack)
                    renderer.write("▲")
                    renderer.resetColors()
                }
            }
            
            if scrollOffset + visibleRows < entries.count {
                renderer.renderAt(row: startRow + 4 + visibleRows - 1, column: width - 5) {
                    renderer.setForegroundColor(.brightBlack)
                    renderer.write("▼")
                    renderer.resetColors()
                }
            }
        }
    }
    
    /// Handle a key press.
    /// - Parameter key: The key that was pressed.
    func handleKey(_ key: Key) {
        switch key {
        case .left, .character("h"):
            // Switch to the previous tab
            if let currentIndex = Tab.allCases.firstIndex(of: selectedTab), currentIndex > 0 {
                selectedTab = Tab.allCases[currentIndex - 1]
            }
            
        case .right, .character("l"):
            // Switch to the next tab
            if let currentIndex = Tab.allCases.firstIndex(of: selectedTab), currentIndex < Tab.allCases.count - 1 {
                selectedTab = Tab.allCases[currentIndex + 1]
            }
            
        case .up, .character("k"):
            // Move up in leaderboard
            if selectedTab == .leaderboard && selectedRow > 0 {
                selectedRow -= 1
            }
            
        case .down, .character("j"):
            // Move down in leaderboard
            if selectedTab == .leaderboard && selectedRow < leaderboard.leaderboard.count - 1 {
                selectedRow += 1
            }
            
        case .pageUp:
            // Move up a page in leaderboard
            if selectedTab == .leaderboard {
                selectedRow = max(0, selectedRow - 10)
            }
            
        case .pageDown:
            // Move down a page in leaderboard
            if selectedTab == .leaderboard {
                selectedRow = min(leaderboard.leaderboard.count - 1, selectedRow + 10)
            }
            
        case .escape, .character("b"), .character("q"):
            // Go back
            onBack()
            
        default:
            break
        }
    }
    
    /// Wrap text to a specified width.
    /// - Parameters:
    ///   - text: The text to wrap.
    ///   - width: The width to wrap to.
    /// - Returns: An array of wrapped lines.
    private func wrapText(_ text: String, width: Int) -> [String] {
        var lines: [String] = []
        var currentLine = ""
        
        for word in text.split(separator: " ") {
            if currentLine.count + word.count + 1 <= width {
                if !currentLine.isEmpty {
                    currentLine += " "
                }
                currentLine += word
            } else {
                lines.append(currentLine)
                currentLine = String(word)
            }
        }
        
        if !currentLine.isEmpty {
            lines.append(currentLine)
        }
        
        return lines
    }
}