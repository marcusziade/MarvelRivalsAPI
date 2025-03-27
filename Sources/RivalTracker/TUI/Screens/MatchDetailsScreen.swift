import Foundation
import MarvelRivalsAPI

/// Screen for displaying match details.
struct MatchDetailsScreen: ScreenProtocol {
    /// The match to display.
    let match: Match
    
    /// Callback for going back to the previous screen.
    let onBack: () -> Void
    
    /// The selected tab.
    private var selectedTab: Tab = .overview
    
    /// The selected player index.
    private var selectedPlayerIndex: Int = 0
    
    /// Tabs for match details.
    private enum Tab: Int, CaseIterable {
        case overview
        case playerStats
        case teamAnalysis
        
        /// Title for the tab.
        var title: String {
            switch self {
            case .overview:
                return "Overview"
            case .playerStats:
                return "Player Stats"
            case .teamAnalysis:
                return "Team Analysis"
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
        let headerText = "Match Details: \(match.matchDetails.matchUid)"
        renderer.renderAt(row: 1, column: max(0, (width - headerText.count) / 2)) {
            renderer.setForegroundColor(.brightYellow)
            renderer.write(headerText)
            renderer.resetColors()
        }
        
        // Draw game mode
        let gameModeText = "Game Mode: \(match.matchDetails.gameMode.gameModeName)"
        renderer.renderAt(row: 2, column: max(0, (width - gameModeText.count) / 2)) {
            renderer.write(gameModeText)
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
        case .playerStats:
            renderPlayerStatsTab(renderer: renderer, startRow: contentStartRow, width: width, height: contentHeight)
        case .teamAnalysis:
            renderTeamAnalysisTab(renderer: renderer, startRow: contentStartRow, width: width, height: contentHeight)
        }
        
        // Draw navigation help
        let navHelp = "h/l to switch tabs, j/k to navigate players, b or Esc to go back"
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
        let matchDetails = match.matchDetails
        
        // Draw MVP and SVP
        renderer.renderAt(row: startRow, column: 2) {
            renderer.setForegroundColor(.brightCyan)
            renderer.write("Match MVP: ")
            renderer.resetColors()
            
            let mvpPlayer = matchDetails.matchPlayers.first { $0.playerUid == matchDetails.mvpUid }
            if let mvpPlayer = mvpPlayer {
                renderer.write("\(mvpPlayer.nickName) (Hero ID: \(matchDetails.mvpHeroId))")
            } else {
                renderer.write("Unknown")
            }
        }
        
        renderer.renderAt(row: startRow + 1, column: 2) {
            renderer.setForegroundColor(.brightCyan)
            renderer.write("Match SVP: ")
            renderer.resetColors()
            
            let svpPlayer = matchDetails.matchPlayers.first { $0.playerUid == matchDetails.svpUid }
            if let svpPlayer = svpPlayer {
                renderer.write("\(svpPlayer.nickName) (Hero ID: \(matchDetails.svpHeroId))")
            } else {
                renderer.write("Unknown")
            }
        }
        
        // Draw replay ID
        renderer.renderAt(row: startRow + 3, column: 2) {
            renderer.write("Replay ID: \(matchDetails.replayId)")
        }
        
        // Draw team information
        let team1Players = matchDetails.matchPlayers.filter { $0.camp == "Team 1" || $0.camp == "Blue" }
        let team2Players = matchDetails.matchPlayers.filter { $0.camp == "Team 2" || $0.camp == "Red" }
        
        // Draw Team 1
        renderer.renderAt(row: startRow + 5, column: 2) {
            renderer.setForegroundColor(.brightCyan)
            renderer.write("Team 1:")
            renderer.resetColors()
        }
        
        // Draw column headers for team 1
        renderer.renderAt(row: startRow + 6, column: 4) {
            renderer.setForegroundColor(.brightBlack)
            renderer.write("Player".padding(toLength: 20, withPad: " ", startingAt: 0))
            renderer.write("Hero".padding(toLength: 15, withPad: " ", startingAt: 0))
            renderer.write("K/D/A".padding(toLength: 10, withPad: " ", startingAt: 0))
            renderer.write("Damage".padding(toLength: 10, withPad: " ", startingAt: 0))
            renderer.write("Healing".padding(toLength: 10, withPad: " ", startingAt: 0))
            renderer.write("Result".padding(toLength: 10, withPad: " ", startingAt: 0))
            renderer.resetColors()
        }
        
        // Draw team 1 players
        for (i, player) in team1Players.enumerated() {
            renderer.renderAt(row: startRow + 7 + i, column: 4) {
                renderer.write(player.nickName.padding(toLength: 20, withPad: " ", startingAt: 0))
                renderer.write("Hero #\(player.curHeroId)".padding(toLength: 15, withPad: " ", startingAt: 0))
                renderer.write("\(player.kills)/\(player.deaths)/\(player.assists)".padding(toLength: 10, withPad: " ", startingAt: 0))
                renderer.write("\(player.totalHeroDamage)".padding(toLength: 10, withPad: " ", startingAt: 0))
                renderer.write("\(player.totalHeroHeal)".padding(toLength: 10, withPad: " ", startingAt: 0))
                
                if player.isWin {
                    renderer.setForegroundColor(.green)
                    renderer.write("Win".padding(toLength: 10, withPad: " ", startingAt: 0))
                } else {
                    renderer.setForegroundColor(.red)
                    renderer.write("Loss".padding(toLength: 10, withPad: " ", startingAt: 0))
                }
                renderer.resetColors()
            }
        }
        
        let team1EndRow = startRow + 7 + team1Players.count
        
        // Draw Team 2
        renderer.renderAt(row: team1EndRow + 1, column: 2) {
            renderer.setForegroundColor(.brightCyan)
            renderer.write("Team 2:")
            renderer.resetColors()
        }
        
        // Draw column headers for team 2
        renderer.renderAt(row: team1EndRow + 2, column: 4) {
            renderer.setForegroundColor(.brightBlack)
            renderer.write("Player".padding(toLength: 20, withPad: " ", startingAt: 0))
            renderer.write("Hero".padding(toLength: 15, withPad: " ", startingAt: 0))
            renderer.write("K/D/A".padding(toLength: 10, withPad: " ", startingAt: 0))
            renderer.write("Damage".padding(toLength: 10, withPad: " ", startingAt: 0))
            renderer.write("Healing".padding(toLength: 10, withPad: " ", startingAt: 0))
            renderer.write("Result".padding(toLength: 10, withPad: " ", startingAt: 0))
            renderer.resetColors()
        }
        
        // Draw team 2 players
        for (i, player) in team2Players.enumerated() {
            renderer.renderAt(row: team1EndRow + 3 + i, column: 4) {
                renderer.write(player.nickName.padding(toLength: 20, withPad: " ", startingAt: 0))
                renderer.write("Hero #\(player.curHeroId)".padding(toLength: 15, withPad: " ", startingAt: 0))
                renderer.write("\(player.kills)/\(player.deaths)/\(player.assists)".padding(toLength: 10, withPad: " ", startingAt: 0))
                renderer.write("\(player.totalHeroDamage)".padding(toLength: 10, withPad: " ", startingAt: 0))
                renderer.write("\(player.totalHeroHeal)".padding(toLength: 10, withPad: " ", startingAt: 0))
                
                if player.isWin {
                    renderer.setForegroundColor(.green)
                    renderer.write("Win".padding(toLength: 10, withPad: " ", startingAt: 0))
                } else {
                    renderer.setForegroundColor(.red)
                    renderer.write("Loss".padding(toLength: 10, withPad: " ", startingAt: 0))
                }
                renderer.resetColors()
            }
        }
    }
    
    /// Render the player stats tab.
    /// - Parameters:
    ///   - renderer: The terminal renderer.
    ///   - startRow: The row to start rendering at.
    ///   - width: The width of the terminal.
    ///   - height: The height of the content area.
    private func renderPlayerStatsTab(renderer: TerminalRenderer, startRow: Int, width: Int, height: Int) {
        let matchDetails = match.matchDetails
        let players = matchDetails.matchPlayers
        
        // Ensure selected player is valid
        let validSelectedIndex = min(max(0, selectedPlayerIndex), players.count - 1)
        
        // Draw player list
        renderer.renderAt(row: startRow, column: 2) {
            renderer.setForegroundColor(.brightCyan)
            renderer.write("Select a player:")
            renderer.resetColors()
        }
        
        for (i, player) in players.enumerated() {
            let isSelected = i == validSelectedIndex
            
            renderer.renderAt(row: startRow + 2 + i, column: 4) {
                if isSelected {
                    renderer.setForegroundColor(.brightWhite)
                    renderer.setBackgroundColor(.blue)
                }
                
                renderer.write(player.nickName)
                
                if player.isWin {
                    renderer.write(" (Win)")
                } else {
                    renderer.write(" (Loss)")
                }
                
                if isSelected {
                    renderer.resetColors()
                }
            }
        }
        
        // Draw vertical separator
        for i in 0..<min(height, 20) {
            renderer.renderAt(row: startRow + i, column: width / 3) {
                renderer.write("│")
            }
        }
        
        // Draw selected player details
        if !players.isEmpty {
            let player = players[validSelectedIndex]
            let detailsStartColumn = width / 3 + 2
            
            // Draw player name and result
            renderer.renderAt(row: startRow, column: detailsStartColumn) {
                renderer.setForegroundColor(.brightCyan)
                renderer.write("Player: \(player.nickName)")
                renderer.resetColors()
            }
            
            renderer.renderAt(row: startRow + 1, column: detailsStartColumn) {
                renderer.write("Result: ")
                if player.isWin {
                    renderer.setForegroundColor(.green)
                    renderer.write("Win")
                } else {
                    renderer.setForegroundColor(.red)
                    renderer.write("Loss")
                }
                renderer.resetColors()
            }
            
            // Draw KDA
            renderer.renderAt(row: startRow + 3, column: detailsStartColumn) {
                renderer.write("Kills: \(player.kills)   Deaths: \(player.deaths)   Assists: \(player.assists)")
            }
            
            // Draw KDA ratio
            let kdaRatio = player.deaths > 0 ? Double(player.kills + player.assists) / Double(player.deaths) : Double(player.kills + player.assists)
            
            renderer.renderAt(row: startRow + 4, column: detailsStartColumn) {
                renderer.write("KDA Ratio: ")
                renderer.setForegroundColor(.brightYellow)
                renderer.write(String(format: "%.2f", kdaRatio))
                renderer.resetColors()
            }
            
            // Draw damage and healing
            renderer.renderAt(row: startRow + 6, column: detailsStartColumn) {
                renderer.write("Damage Dealt: ")
                renderer.setForegroundColor(.brightRed)
                renderer.write("\(player.totalHeroDamage)")
                renderer.resetColors()
            }
            
            renderer.renderAt(row: startRow + 7, column: detailsStartColumn) {
                renderer.write("Healing Done: ")
                renderer.setForegroundColor(.brightGreen)
                renderer.write("\(player.totalHeroHeal)")
                renderer.resetColors()
            }
            
            renderer.renderAt(row: startRow + 8, column: detailsStartColumn) {
                renderer.write("Damage Taken: ")
                renderer.setForegroundColor(.brightMagenta)
                renderer.write("\(player.totalDamageTaken)")
                renderer.resetColors()
            }
            
            // Draw heroes used
            renderer.renderAt(row: startRow + 10, column: detailsStartColumn) {
                renderer.setForegroundColor(.brightCyan)
                renderer.write("Heroes Used:")
                renderer.resetColors()
            }
            
            for (i, hero) in player.playerHeroes.enumerated() {
                renderer.renderAt(row: startRow + 11 + i, column: detailsStartColumn + 2) {
                    renderer.write("Hero #\(hero.heroId)")
                    renderer.write(" - Play Time: \(formatPlayTime(seconds: hero.playTime))")
                    renderer.write(" - KDA: \(hero.kills)/\(hero.deaths)/\(hero.assists)")
                    
                    if hero.sessionHitRate > 0 {
                        renderer.write(" - Hit Rate: \(Int(hero.sessionHitRate * 100))%")
                    }
                }
            }
        }
    }
    
    /// Render the team analysis tab.
    /// - Parameters:
    ///   - renderer: The terminal renderer.
    ///   - startRow: The row to start rendering at.
    ///   - width: The width of the terminal.
    ///   - height: The height of the content area.
    private func renderTeamAnalysisTab(renderer: TerminalRenderer, startRow: Int, width: Int, height: Int) {
        let matchDetails = match.matchDetails
        let team1Players = matchDetails.matchPlayers.filter { $0.camp == "Team 1" || $0.camp == "Blue" }
        let team2Players = matchDetails.matchPlayers.filter { $0.camp == "Team 2" || $0.camp == "Red" }
        
        // Calculate team stats
        let team1Kills = team1Players.reduce(0) { $0 + $1.kills }
        let team1Deaths = team1Players.reduce(0) { $0 + $1.deaths }
        let team1Assists = team1Players.reduce(0) { $0 + $1.assists }
        let team1Damage = team1Players.reduce(0) { $0 + $1.totalHeroDamage }
        let team1Healing = team1Players.reduce(0) { $0 + $1.totalHeroHeal }
        
        let team2Kills = team2Players.reduce(0) { $0 + $1.kills }
        let team2Deaths = team2Players.reduce(0) { $0 + $1.deaths }
        let team2Assists = team2Players.reduce(0) { $0 + $1.assists }
        let team2Damage = team2Players.reduce(0) { $0 + $1.totalHeroDamage }
        let team2Healing = team2Players.reduce(0) { $0 + $1.totalHeroHeal }
        
        // Draw team comparison title
        renderer.renderAt(row: startRow, column: 2) {
            renderer.setForegroundColor(.brightCyan)
            renderer.write("Team Comparison")
            renderer.resetColors()
        }
        
        // Draw team headers
        let teamWidth = (width - 10) / 2
        
        renderer.renderAt(row: startRow + 2, column: 5) {
            renderer.setForegroundColor(.brightYellow)
            renderer.write("Team 1")
            renderer.resetColors()
        }
        
        renderer.renderAt(row: startRow + 2, column: 5 + teamWidth) {
            renderer.setForegroundColor(.brightYellow)
            renderer.write("Team 2")
            renderer.resetColors()
        }
        
        // Draw horizontal separator
        renderer.renderAt(row: startRow + 3, column: 2) {
            renderer.drawHorizontalLine(row: startRow + 3, startColumn: 2, width: width - 4)
        }
        
        // Draw comparison metrics
        renderer.renderAt(row: startRow + 5, column: 3) {
            renderer.write("K/D/A:")
            
            // Team 1 KDA
            renderer.setForegroundColor(.brightWhite)
            renderer.write(String(format: "%d/%d/%d", team1Kills, team1Deaths, team1Assists).padding(toLength: teamWidth - 10, withPad: " ", startingAt: 0))
            
            // Comparison indicator
            let teamKDARatio1 = team1Deaths > 0 ? Double(team1Kills + team1Assists) / Double(team1Deaths) : Double.infinity
            let teamKDARatio2 = team2Deaths > 0 ? Double(team2Kills + team2Assists) / Double(team2Deaths) : Double.infinity
            
            if teamKDARatio1 > teamKDARatio2 {
                renderer.setForegroundColor(.green)
                renderer.write(" > ")
            } else if teamKDARatio1 < teamKDARatio2 {
                renderer.setForegroundColor(.red)
                renderer.write(" < ")
            } else {
                renderer.setForegroundColor(.brightYellow)
                renderer.write(" = ")
            }
            
            // Team 2 KDA
            renderer.setForegroundColor(.brightWhite)
            renderer.write(String(format: "%d/%d/%d", team2Kills, team2Deaths, team2Assists))
            renderer.resetColors()
        }
        
        // Draw total damage
        renderer.renderAt(row: startRow + 7, column: 3) {
            renderer.write("Total Damage:")
            
            // Team 1 damage
            renderer.setForegroundColor(.brightWhite)
            renderer.write(String(format: "%d", team1Damage).padding(toLength: teamWidth - 15, withPad: " ", startingAt: 0))
            
            // Comparison indicator
            if team1Damage > team2Damage {
                renderer.setForegroundColor(.green)
                renderer.write(" > ")
            } else if team1Damage < team2Damage {
                renderer.setForegroundColor(.red)
                renderer.write(" < ")
            } else {
                renderer.setForegroundColor(.brightYellow)
                renderer.write(" = ")
            }
            
            // Team 2 damage
            renderer.setForegroundColor(.brightWhite)
            renderer.write(String(format: "%d", team2Damage))
            renderer.resetColors()
        }
        
        // Draw total healing
        renderer.renderAt(row: startRow + 9, column: 3) {
            renderer.write("Total Healing:")
            
            // Team 1 healing
            renderer.setForegroundColor(.brightWhite)
            renderer.write(String(format: "%d", team1Healing).padding(toLength: teamWidth - 15, withPad: " ", startingAt: 0))
            
            // Comparison indicator
            if team1Healing > team2Healing {
                renderer.setForegroundColor(.green)
                renderer.write(" > ")
            } else if team1Healing < team2Healing {
                renderer.setForegroundColor(.red)
                renderer.write(" < ")
            } else {
                renderer.setForegroundColor(.brightYellow)
                renderer.write(" = ")
            }
            
            // Team 2 healing
            renderer.setForegroundColor(.brightWhite)
            renderer.write(String(format: "%d", team2Healing))
            renderer.resetColors()
        }
        
        // Draw winner
        let team1Won = team1Players.first?.isWin ?? false
        
        renderer.renderAt(row: startRow + 11, column: 3) {
            renderer.write("Result:")
            
            // Team 1 result
            if team1Won {
                renderer.setForegroundColor(.green)
                renderer.write("Win".padding(toLength: teamWidth - 10, withPad: " ", startingAt: 0))
            } else {
                renderer.setForegroundColor(.red)
                renderer.write("Loss".padding(toLength: teamWidth - 10, withPad: " ", startingAt: 0))
            }
            
            renderer.write("   ")
            
            // Team 2 result
            if !team1Won {
                renderer.setForegroundColor(.green)
                renderer.write("Win")
            } else {
                renderer.setForegroundColor(.red)
                renderer.write("Loss")
            }
            renderer.resetColors()
        }
        
        // Draw team composition analysis
        renderer.renderAt(row: startRow + 13, column: 2) {
            renderer.setForegroundColor(.brightCyan)
            renderer.write("Team Composition Analysis")
            renderer.resetColors()
        }
        
        // This would be more detailed with access to hero data
        renderer.renderAt(row: startRow + 15, column: 3) {
            renderer.write("Team 1 Heroes: ")
            for (i, player) in team1Players.enumerated() {
                if i > 0 {
                    renderer.write(", ")
                }
                renderer.write("Hero #\(player.curHeroId)")
            }
        }
        
        renderer.renderAt(row: startRow + 16, column: 3) {
            renderer.write("Team 2 Heroes: ")
            for (i, player) in team2Players.enumerated() {
                if i > 0 {
                    renderer.write(", ")
                }
                renderer.write("Hero #\(player.curHeroId)")
            }
        }
    }
    
    /// Format play time in seconds to a human-readable string.
    /// - Parameter seconds: The play time in seconds.
    /// - Returns: A human-readable string.
    private func formatPlayTime(seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return "\(mins)m \(secs)s"
    }
    
    /// Handle a key press.
    /// - Parameter key: The key that was pressed.
    func handleKey(_ key: Key) {
        let matchDetails = match.matchDetails
        
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
            // Move up in player selection
            if selectedTab == .playerStats && selectedPlayerIndex > 0 {
                selectedPlayerIndex -= 1
            }
            
        case .down, .character("j"):
            // Move down in player selection
            if selectedTab == .playerStats && selectedPlayerIndex < matchDetails.matchPlayers.count - 1 {
                selectedPlayerIndex += 1
            }
            
        case .escape, .character("b"), .character("q"):
            // Go back
            onBack()
            
        default:
            break
        }
    }
}