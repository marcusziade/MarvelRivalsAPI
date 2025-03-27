import Foundation
import MarvelRivalsAPI

/// Screen for displaying a player's dashboard.
struct PlayerDashboardScreen: ScreenProtocol {
    /// The player to display.
    let player: Player
    
    /// The player's stats.
    let stats: PlayerStats
    
    /// The player's recent matches.
    let matches: [Match]
    
    /// Callback for refreshing the player data.
    let onRefresh: () -> Void
    
    /// Callback for going back to the previous screen.
    let onBack: () -> Void
    
    /// Initialize a player dashboard screen.
    /// - Parameters:
    ///   - player: The player to display.
    ///   - stats: The player's stats.
    ///   - matches: The player's recent matches.
    ///   - onRefresh: Callback for refreshing the player data.
    ///   - onBack: Callback for going back to the previous screen.
    ///   - selectedSection: The selected section. Default is Overview.
    ///   - selectedRow: The selected row. Default is 0.
    init(
        player: Player,
        stats: PlayerStats,
        matches: [Match],
        onRefresh: @escaping () -> Void,
        onBack: @escaping () -> Void,
        selectedSection: Section = .overview,
        selectedRow: Int = 0
    ) {
        self.player = player
        self.stats = stats
        self.matches = matches
        self.onRefresh = onRefresh
        self.onBack = onBack
        self.selectedSection = selectedSection
        self.selectedRow = selectedRow
    }
    
    /// The selected section.
    private var selectedSection: Section = .overview
    
    /// The selected row in the current section.
    private var selectedRow: Int = 0
    
    /// The dashboard sections.
    enum Section: Int, CaseIterable {
        case overview
        case favoriteHeroes
        case matchHistory
        case performance
        
        /// The title of the section.
        var title: String {
            switch self {
            case .overview:
                return "Player Overview"
            case .favoriteHeroes:
                return "Favorite Heroes"
            case .matchHistory:
                return "Recent Matches"
            case .performance:
                return "Performance Metrics"
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
        let headerText = "Player Dashboard: \(player.username)"
        renderer.renderAt(row: 1, column: max(0, (width - headerText.count) / 2)) {
            renderer.setForegroundColor(.brightYellow)
            renderer.write(headerText)
            renderer.resetColors()
        }
        
        // Draw player info
        renderer.renderAt(row: 3, column: 2) {
            renderer.write("Player: ")
            renderer.setForegroundColor(.brightWhite)
            renderer.write(player.username)
            renderer.resetColors()
            
            renderer.write("  |  Level: ")
            renderer.setForegroundColor(.brightWhite)
            renderer.write("\(player.level)")
            renderer.resetColors()
            
            renderer.write("  |  Rank: ")
            renderer.setForegroundColor(.brightWhite)
            renderer.write(player.rank)
            renderer.resetColors()
            
            renderer.write("  |  Region: ")
            renderer.setForegroundColor(.brightWhite)
            renderer.write(player.region ?? "Unknown")
            renderer.resetColors()
        }
        
        // Draw section tabs
        let tabsRow = 5
        var currentColumn = 2
        
        for section in Section.allCases {
            let isSelected = section == selectedSection
            let tabText = section.title
            
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
        
        // Draw the selected section
        let sectionStartRow = tabsRow + 3
        let sectionHeight = height - sectionStartRow - 4
        
        switch selectedSection {
        case .overview:
            renderOverviewSection(renderer: renderer, startRow: sectionStartRow, width: width, height: sectionHeight)
        case .favoriteHeroes:
            renderFavoriteHeroesSection(renderer: renderer, startRow: sectionStartRow, width: width, height: sectionHeight)
        case .matchHistory:
            renderMatchHistorySection(renderer: renderer, startRow: sectionStartRow, width: width, height: sectionHeight)
        case .performance:
            renderPerformanceSection(renderer: renderer, startRow: sectionStartRow, width: width, height: sectionHeight)
        }
        
        // Draw navigation help
        let navHelp = "Use h/l or ←/→ to switch tabs, j/k or ↑/↓ to navigate, r to refresh, b or Esc to go back"
        renderer.renderAt(row: height - 2, column: max(0, (width - navHelp.count) / 2)) {
            renderer.setForegroundColor(.brightBlack)
            renderer.write(navHelp)
            renderer.resetColors()
        }
    }
    
    /// Render the overview section.
    /// - Parameters:
    ///   - renderer: The terminal renderer.
    ///   - startRow: The row to start rendering at.
    ///   - width: The width of the terminal.
    ///   - height: The height of the section.
    private func renderOverviewSection(renderer: TerminalRenderer, startRow: Int, width: Int, height: Int) {
        // Draw season stats
        renderer.renderAt(row: startRow, column: 2) {
            renderer.setForegroundColor(.brightCyan)
            renderer.write("Season \(stats.seasonStats.season): \(stats.seasonStats.seasonName)")
            renderer.resetColors()
        }
        
        // Draw rank info
        renderer.renderAt(row: startRow + 2, column: 4) {
            renderer.write("Rank: ")
            renderer.setForegroundColor(.brightWhite)
            renderer.write(stats.seasonStats.rank)
            renderer.resetColors()
        }
        
        // Draw win rate info
        renderer.renderAt(row: startRow + 4, column: 4) {
            renderer.write("Matches: \(stats.seasonStats.matchesPlayed)  |  Wins: \(stats.seasonStats.wins)  |  Losses: \(stats.seasonStats.losses)")
        }
        
        // Draw win rate chart
        renderer.renderAt(row: startRow + 5, column: 4) {
            renderer.write("Win Rate: ")
            
            let winRateChart = ASCIIArt.winLossChart(
                wins: stats.seasonStats.wins,
                losses: stats.seasonStats.losses,
                width: 40
            )
            
            renderer.setForegroundColor(.green)
            renderer.write(winRateChart)
            renderer.resetColors()
        }
        
        // Draw KDA info
        renderer.renderAt(row: startRow + 7, column: 4) {
            renderer.write("KDA Ratio: ")
            renderer.setForegroundColor(.brightYellow)
            renderer.write(String(format: "%.2f", stats.seasonStats.kdaRatio))
            renderer.resetColors()
        }
        
        // Draw damage and healing
        renderer.renderAt(row: startRow + 9, column: 4) {
            renderer.write("Average Damage: ")
            renderer.setForegroundColor(.brightRed)
            renderer.write("\(stats.seasonStats.averageDamage)")
            renderer.resetColors()
        }
        
        renderer.renderAt(row: startRow + 10, column: 4) {
            renderer.write("Average Healing: ")
            renderer.setForegroundColor(.brightGreen)
            renderer.write("\(stats.seasonStats.averageHealing)")
            renderer.resetColors()
        }
        
        // Draw recent activity
        if let recentActivity = player.recentActivity, !recentActivity.isEmpty {
            renderer.renderAt(row: startRow + 12, column: 2) {
                renderer.setForegroundColor(.brightCyan)
                renderer.write("Recent Activity")
                renderer.resetColors()
            }
            
            for (i, activity) in recentActivity.prefix(5).enumerated() {
                renderer.renderAt(row: startRow + 14 + i, column: 4) {
                    renderer.write("\(activity.type): \(activity.details) (\(activity.timestamp))")
                }
            }
        }
    }
    
    /// Render the favorite heroes section.
    /// - Parameters:
    ///   - renderer: The terminal renderer.
    ///   - startRow: The row to start rendering at.
    ///   - width: The width of the terminal.
    ///   - height: The height of the section.
    private func renderFavoriteHeroesSection(renderer: TerminalRenderer, startRow: Int, width: Int, height: Int) {
        // Draw header
        renderer.renderAt(row: startRow, column: 2) {
            renderer.setForegroundColor(.brightCyan)
            renderer.write("Most Played Heroes")
            renderer.resetColors()
        }
        
        // Draw column headers
        renderer.renderAt(row: startRow + 2, column: 4) {
            renderer.setForegroundColor(.brightBlack)
            renderer.write("Hero".padding(toLength: 20, withPad: " ", startingAt: 0))
            renderer.write("Matches".padding(toLength: 10, withPad: " ", startingAt: 0))
            renderer.write("Win Rate".padding(toLength: 10, withPad: " ", startingAt: 0))
            renderer.write("KDA".padding(toLength: 10, withPad: " ", startingAt: 0))
            renderer.resetColors()
        }
        
        // Draw hero stats
        if stats.heroStats.isEmpty {
            renderer.renderAt(row: startRow + 4, column: 4) {
                renderer.setForegroundColor(.brightBlack)
                renderer.write("No hero stats available.")
                renderer.resetColors()
            }
        } else {
            // Sort hero stats by matches played
            let sortedHeroStats = stats.heroStats.sorted { $0.matchesPlayed > $1.matchesPlayed }
            
            for (i, heroStat) in sortedHeroStats.prefix(min(10, height - 6)).enumerated() {
                let rowIndex = startRow + 4 + i
                let isSelected = i == selectedRow
                
                renderer.renderAt(row: rowIndex, column: 4) {
                    if isSelected {
                        renderer.setForegroundColor(.brightWhite)
                        renderer.setBackgroundColor(.blue)
                    }
                    
                    renderer.write(heroStat.heroName.padding(toLength: 20, withPad: " ", startingAt: 0))
                    renderer.write("\(heroStat.matchesPlayed)".padding(toLength: 10, withPad: " ", startingAt: 0))
                    renderer.write("\(Int(heroStat.winRate * 100))%".padding(toLength: 10, withPad: " ", startingAt: 0))
                    renderer.write(String(format: "%.2f", heroStat.kdaRatio).padding(toLength: 10, withPad: " ", startingAt: 0))
                    
                    if isSelected {
                        renderer.resetColors()
                    }
                }
            }
        }
        
        // Draw favorite heroes
        if let favoriteHeroes = player.favoriteHeroes, !favoriteHeroes.isEmpty {
            renderer.renderAt(row: startRow + 16, column: 2) {
                renderer.setForegroundColor(.brightCyan)
                renderer.write("Favorite Heroes")
                renderer.resetColors()
            }
            
            for (i, hero) in favoriteHeroes.prefix(5).enumerated() {
                renderer.renderAt(row: startRow + 18 + i, column: 4) {
                    renderer.write("\(hero.heroName) - Play Time: \(formatPlayTime(minutes: hero.playTime)) - Win Rate: \(Int(hero.winRate * 100))%")
                }
            }
        }
    }
    
    /// Render the match history section.
    /// - Parameters:
    ///   - renderer: The terminal renderer.
    ///   - startRow: The row to start rendering at.
    ///   - width: The width of the terminal.
    ///   - height: The height of the section.
    private func renderMatchHistorySection(renderer: TerminalRenderer, startRow: Int, width: Int, height: Int) {
        // Draw header
        renderer.renderAt(row: startRow, column: 2) {
            renderer.setForegroundColor(.brightCyan)
            renderer.write("Recent Matches")
            renderer.resetColors()
        }
        
        // Draw column headers
        renderer.renderAt(row: startRow + 2, column: 4) {
            renderer.setForegroundColor(.brightBlack)
            renderer.write("Result".padding(toLength: 10, withPad: " ", startingAt: 0))
            renderer.write("Hero".padding(toLength: 15, withPad: " ", startingAt: 0))
            renderer.write("KDA".padding(toLength: 10, withPad: " ", startingAt: 0))
            renderer.write("Map".padding(toLength: 20, withPad: " ", startingAt: 0))
            renderer.write("Mode".padding(toLength: 15, withPad: " ", startingAt: 0))
            renderer.write("Time".padding(toLength: 20, withPad: " ", startingAt: 0))
            renderer.resetColors()
        }
        
        // Draw match history
        if let matchHistory = stats.matchHistory, !matchHistory.isEmpty {
            for (i, match) in matchHistory.prefix(min(10, height - 6)).enumerated() {
                let rowIndex = startRow + 4 + i
                let isSelected = i == selectedRow
                
                renderer.renderAt(row: rowIndex, column: 4) {
                    if isSelected {
                        renderer.setForegroundColor(.brightWhite)
                        renderer.setBackgroundColor(.blue)
                    }
                    
                    // Result (Win/Loss)
                    if match.result.lowercased().contains("win") {
                        renderer.setForegroundColor(.green)
                    } else {
                        renderer.setForegroundColor(.red)
                    }
                    renderer.write(match.result.padding(toLength: 10, withPad: " ", startingAt: 0))
                    
                    // Reset color for the rest if selected
                    if isSelected {
                        renderer.setForegroundColor(.brightWhite)
                    } else {
                        renderer.resetColors()
                    }
                    
                    // Hero, KDA, Map, Mode, Time
                    renderer.write(match.hero.padding(toLength: 15, withPad: " ", startingAt: 0))
                    renderer.write(match.kda.padding(toLength: 10, withPad: " ", startingAt: 0))
                    renderer.write(match.map.padding(toLength: 20, withPad: " ", startingAt: 0))
                    renderer.write(match.gameMode.padding(toLength: 15, withPad: " ", startingAt: 0))
                    renderer.write(match.timestamp.padding(toLength: 20, withPad: " ", startingAt: 0))
                    
                    if isSelected {
                        renderer.resetColors()
                    }
                }
            }
        } else if !matches.isEmpty {
            // Use the matches array if matchHistory is empty
            for (i, match) in matches.prefix(min(10, height - 6)).enumerated() {
                let rowIndex = startRow + 4 + i
                let isSelected = i == selectedRow
                let matchDetails = match.matchDetails
                
                // Find the player in the match
                let playerDetails = matchDetails.matchPlayers.first { player in
                    player.nickName.lowercased() == self.player.username.lowercased()
                }
                
                renderer.renderAt(row: rowIndex, column: 4) {
                    if isSelected {
                        renderer.setForegroundColor(.brightWhite)
                        renderer.setBackgroundColor(.blue)
                    }
                    
                    // Result (Win/Loss)
                    if let playerDetails = playerDetails {
                        if playerDetails.isWin {
                            renderer.setForegroundColor(.green)
                            renderer.write("Win".padding(toLength: 10, withPad: " ", startingAt: 0))
                        } else {
                            renderer.setForegroundColor(.red)
                            renderer.write("Loss".padding(toLength: 10, withPad: " ", startingAt: 0))
                        }
                    } else {
                        renderer.write("???".padding(toLength: 10, withPad: " ", startingAt: 0))
                    }
                    
                    // Reset color for the rest if selected
                    if isSelected {
                        renderer.setForegroundColor(.brightWhite)
                    } else {
                        renderer.resetColors()
                    }
                    
                    // Hero, KDA, Map, Mode, Time
                    if let playerDetails = playerDetails {
                        let heroName = "Hero #\(playerDetails.curHeroId)"
                        let kda = "\(playerDetails.kills)/\(playerDetails.deaths)/\(playerDetails.assists)"
                        
                        renderer.write(heroName.padding(toLength: 15, withPad: " ", startingAt: 0))
                        renderer.write(kda.padding(toLength: 10, withPad: " ", startingAt: 0))
                    } else {
                        renderer.write("???".padding(toLength: 15, withPad: " ", startingAt: 0))
                        renderer.write("???".padding(toLength: 10, withPad: " ", startingAt: 0))
                    }
                    
                    renderer.write("???".padding(toLength: 20, withPad: " ", startingAt: 0))
                    renderer.write(matchDetails.gameMode.gameModeName.padding(toLength: 15, withPad: " ", startingAt: 0))
                    renderer.write("???".padding(toLength: 20, withPad: " ", startingAt: 0))
                    
                    if isSelected {
                        renderer.resetColors()
                    }
                }
            }
        } else {
            renderer.renderAt(row: startRow + 4, column: 4) {
                renderer.setForegroundColor(.brightBlack)
                renderer.write("No match history available.")
                renderer.resetColors()
            }
        }
    }
    
    /// Render the performance section.
    /// - Parameters:
    ///   - renderer: The terminal renderer.
    ///   - startRow: The row to start rendering at.
    ///   - width: The width of the terminal.
    ///   - height: The height of the section.
    private func renderPerformanceSection(renderer: TerminalRenderer, startRow: Int, width: Int, height: Int) {
        // Draw header
        renderer.renderAt(row: startRow, column: 2) {
            renderer.setForegroundColor(.brightCyan)
            renderer.write("Performance Metrics")
            renderer.resetColors()
        }
        
        // Draw KDA ratio
        renderer.renderAt(row: startRow + 2, column: 4) {
            renderer.write("KDA Ratio: ")
            renderer.setForegroundColor(.brightYellow)
            renderer.write(String(format: "%.2f", stats.seasonStats.kdaRatio))
            renderer.resetColors()
        }
        
        // Draw damage metrics
        renderer.renderAt(row: startRow + 4, column: 4) {
            renderer.write("Average Damage: ")
            renderer.setForegroundColor(.brightRed)
            renderer.write("\(stats.seasonStats.averageDamage)")
            renderer.resetColors()
        }
        
        // Draw healing metrics
        renderer.renderAt(row: startRow + 5, column: 4) {
            renderer.write("Average Healing: ")
            renderer.setForegroundColor(.brightGreen)
            renderer.write("\(stats.seasonStats.averageHealing)")
            renderer.resetColors()
        }
        
        // Draw win rate over time (sparkline)
        if let matchHistory = stats.matchHistory, !matchHistory.isEmpty {
            // Calculate win rates for the last 10 matches
            var winRates: [Double] = []
            var wins = 0
            
            for (i, match) in matchHistory.prefix(10).enumerated() {
                if match.result.lowercased().contains("win") {
                    wins += 1
                }
                
                let winRate = Double(wins) / Double(i + 1)
                winRates.append(winRate)
            }
            
            renderer.renderAt(row: startRow + 7, column: 4) {
                renderer.write("Win Rate Trend: ")
                
                let sparkline = ASCIIArt.sparkline(values: winRates, width: 30)
                renderer.setForegroundColor(.brightCyan)
                renderer.write(sparkline)
                renderer.resetColors()
            }
            
            // Draw win/loss streak
            var currentStreak = 1
            let streakType = matchHistory[0].result.lowercased().contains("win") ? "Win" : "Loss"
            
            for i in 1..<min(matchHistory.count, 10) {
                let isWin = matchHistory[i].result.lowercased().contains("win")
                let currentStreakIsWin = streakType == "Win"
                
                if isWin == currentStreakIsWin {
                    currentStreak += 1
                } else {
                    break
                }
            }
            
            renderer.renderAt(row: startRow + 9, column: 4) {
                renderer.write("Current Streak: ")
                
                if streakType == "Win" {
                    renderer.setForegroundColor(.green)
                } else {
                    renderer.setForegroundColor(.red)
                }
                
                renderer.write("\(currentStreak) \(streakType)\(currentStreak > 1 ? "s" : "")")
                renderer.resetColors()
            }
        } else {
            renderer.renderAt(row: startRow + 7, column: 4) {
                renderer.setForegroundColor(.brightBlack)
                renderer.write("Not enough match history to show performance trends.")
                renderer.resetColors()
            }
        }
        
        // Draw per-hero performance if available
        if !stats.heroStats.isEmpty {
            renderer.renderAt(row: startRow + 11, column: 4) {
                renderer.write("Per-Hero Performance:")
            }
            
            // Sort heroes by matches played
            let sortedHeroStats = stats.heroStats.sorted { $0.matchesPlayed > $1.matchesPlayed }
            
            for (i, heroStat) in sortedHeroStats.prefix(min(5, height - 15)).enumerated() {
                renderer.renderAt(row: startRow + 13 + i, column: 6) {
                    renderer.write(heroStat.heroName.padding(toLength: 15, withPad: " ", startingAt: 0))
                    
                    // Win rate bar
                    renderer.write("Win Rate: ")
                    let winRateBar = ASCIIArt.bar(value: heroStat.winRate, maxValue: 1.0, width: 20)
                    renderer.setForegroundColor(.green)
                    renderer.write(winRateBar)
                    renderer.resetColors()
                }
                
                renderer.renderAt(row: startRow + 14 + i, column: 6) {
                    renderer.write("".padding(toLength: 15, withPad: " ", startingAt: 0))
                    
                    // KDA bar
                    renderer.write("KDA: ")
                    let kdaBar = ASCIIArt.bar(
                        value: min(heroStat.kdaRatio, 5.0), // Cap at 5.0 for display
                        maxValue: 5.0,
                        width: 20
                    )
                    renderer.setForegroundColor(.brightYellow)
                    renderer.write(kdaBar)
                    renderer.resetColors()
                }
                
                // Add a blank line between heroes
                if i < sortedHeroStats.prefix(5).count - 1 {
                    renderer.renderAt(row: startRow + 15 + i, column: 6) {
                        renderer.write("")
                    }
                }
            }
        }
    }
    
    /// Format play time in minutes to a human-readable string.
    /// - Parameter minutes: The play time in minutes.
    /// - Returns: A human-readable string.
    private func formatPlayTime(minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            return "\(hours)h \(mins)m"
        }
    }
    
    /// Handle a key press.
    /// - Parameter key: The key that was pressed.
    mutating func handleKey(_ key: Key) {
        switch key {
        case .left, .character("h"):
            // Switch to the previous section
            if let currentIndex = Section.allCases.firstIndex(of: selectedSection), currentIndex > 0 {
                selectedSection = Section.allCases[currentIndex - 1]
                selectedRow = 0
            }
            
        case .right, .character("l"):
            // Switch to the next section
            if let currentIndex = Section.allCases.firstIndex(of: selectedSection), currentIndex < Section.allCases.count - 1 {
                selectedSection = Section.allCases[currentIndex + 1]
                selectedRow = 0
            }
            
        case .up, .character("k"):
            // Move up in the current section
            if selectedRow > 0 {
                selectedRow -= 1
            }
            
        case .down, .character("j"):
            // Move down in the current section
            selectedRow += 1
            
        case .character("r"), .character("R"):
            // Refresh the player data
            onRefresh()
            
        case .escape, .character("b"), .character("B"):
            // Go back to the previous screen
            onBack()
            
        default:
            break
        }
    }
}