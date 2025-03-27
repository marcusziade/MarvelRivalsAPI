import Foundation
import MarvelRivalsAPI

/// Screen for displaying a hero's leaderboard.
struct HeroLeaderboardScreen: ScreenProtocol {
    /// The hero whose leaderboard is being displayed.
    let hero: Hero
    
    /// The leaderboard data.
    let leaderboard: HeroLeaderboard
    
    /// Callback for going back to the previous screen.
    let onBack: () -> Void
    
    /// The scroll offset for the leaderboard entries.
    private var scrollOffset: Int = 0
    
    /// The selected platform filter (pc, mobile).
    private var platformFilter: String = "all"
    
    /// The number of displayed entries per page.
    private let entriesPerPage = 15
    
    /// The filtered leaderboard entries based on the platform filter.
    private var filteredEntries: [HeroLeaderboard.LeaderboardEntry] {
        if platformFilter == "all" {
            return leaderboard.leaderboard
        } else {
            return leaderboard.leaderboard.filter { $0.platform.lowercased() == platformFilter.lowercased() }
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
        let headerText = "\(hero.name) Leaderboard"
        renderer.renderAt(row: 1, column: max(0, (width - headerText.count) / 2)) {
            renderer.setForegroundColor(.brightYellow)
            renderer.write(headerText)
            renderer.resetColors()
        }
        
        // Draw hero role and platform
        let subHeaderText = "Role: \(hero.role) | Platform: \(leaderboard.platform)"
        renderer.renderAt(row: 2, column: max(0, (width - subHeaderText.count) / 2)) {
            renderer.write(subHeaderText)
        }
        
        // Draw platform filter
        let platformFilterRow = 4
        renderer.renderAt(row: platformFilterRow, column: 2) {
            renderer.write("Filter: ")
            
            for (index, platform) in ["all", "pc", "mobile"].enumerated() {
                if platform == platformFilter {
                    renderer.setForegroundColor(.brightWhite)
                    renderer.setBackgroundColor(.blue)
                }
                
                renderer.write(" \(platform) ")
                renderer.resetColors()
                
                if index < 2 {
                    renderer.write(" | ")
                }
            }
        }
        
        // Draw horizontal line
        renderer.renderAt(row: platformFilterRow + 2, column: 0) {
            renderer.drawHorizontalLine(row: platformFilterRow + 2, startColumn: 0, width: width)
        }
        
        // Draw column headers
        let headerRow = platformFilterRow + 4
        renderer.renderAt(row: headerRow, column: 2) {
            renderer.setForegroundColor(.brightBlack)
            renderer.write("Rank".padding(toLength: 8, withPad: " ", startingAt: 0))
            renderer.write("Player".padding(toLength: 25, withPad: " ", startingAt: 0))
            renderer.write("Score".padding(toLength: 15, withPad: " ", startingAt: 0))
            renderer.write("Platform".padding(toLength: 15, withPad: " ", startingAt: 0))
            renderer.resetColors()
        }
        
        // Draw horizontal line
        renderer.renderAt(row: headerRow + 1, column: 0) {
            renderer.drawHorizontalLine(row: headerRow + 1, startColumn: 0, width: width)
        }
        
        // Calculate visible rows
        let leaderboardStartRow = headerRow + 2
        let visibleRows = min(entriesPerPage, height - leaderboardStartRow - 4)
        
        // Draw leaderboard entries
        let entries = filteredEntries
        if entries.isEmpty {
            renderer.renderAt(row: leaderboardStartRow, column: 2) {
                renderer.setForegroundColor(.brightBlack)
                renderer.write("No leaderboard entries found for this hero and platform.")
                renderer.resetColors()
            }
        } else {
            // Adjust scroll offset if necessary
            scrollOffset = min(max(0, scrollOffset), max(0, entries.count - visibleRows))
            
            // Draw entries
            for i in 0..<min(visibleRows, entries.count - scrollOffset) {
                let entryIndex = i + scrollOffset
                let entry = entries[entryIndex]
                
                renderer.renderAt(row: leaderboardStartRow + i, column: 2) {
                    // Rank with special styling for top 3
                    if entry.rank <= 3 {
                        renderer.setForegroundColor(rankColor(for: entry.rank))
                        renderer.write("#\(entry.rank)".padding(toLength: 8, withPad: " ", startingAt: 0))
                        renderer.resetColors()
                    } else {
                        renderer.write("#\(entry.rank)".padding(toLength: 8, withPad: " ", startingAt: 0))
                    }
                    
                    // Player name
                    renderer.write(entry.playerName.padding(toLength: 25, withPad: " ", startingAt: 0))
                    
                    // Score
                    renderer.write(formatScore(entry.score).padding(toLength: 15, withPad: " ", startingAt: 0))
                    
                    // Platform with icon
                    let platformIcon = platformSymbol(for: entry.platform)
                    renderer.write("\(platformIcon) \(entry.platform)".padding(toLength: 15, withPad: " ", startingAt: 0))
                }
            }
        }
        
        // Draw scroll indicators if necessary
        if entries.count > visibleRows {
            if scrollOffset > 0 {
                renderer.renderAt(row: leaderboardStartRow - 1, column: width - 5) {
                    renderer.setForegroundColor(.brightBlack)
                    renderer.write("▲")
                    renderer.resetColors()
                }
            }
            
            if scrollOffset + visibleRows < entries.count {
                renderer.renderAt(row: leaderboardStartRow + visibleRows, column: width - 5) {
                    renderer.setForegroundColor(.brightBlack)
                    renderer.write("▼")
                    renderer.resetColors()
                }
            }
            
            // Draw scroll position indicator
            let scrollText = "[\(scrollOffset + 1)-\(min(scrollOffset + visibleRows, entries.count))/\(entries.count)]"
            renderer.renderAt(row: leaderboardStartRow + visibleRows + 1, column: max(0, (width - scrollText.count) / 2)) {
                renderer.setForegroundColor(.brightBlack)
                renderer.write(scrollText)
                renderer.resetColors()
            }
        }
        
        // Draw navigation help
        let navHelp = "j/k or ↑/↓: Navigate | h/l: Change platform filter | Esc/b/q: Back"
        renderer.renderAt(row: height - 2, column: max(0, (width - navHelp.count) / 2)) {
            renderer.setForegroundColor(.brightBlack)
            renderer.write(navHelp)
            renderer.resetColors()
        }
    }
    
    /// Handle a key press.
    /// - Parameter key: The key that was pressed.
    func handleKey(_ key: Key) {
        switch key {
        case .up, .character("k"):
            // Scroll up
            if scrollOffset > 0 {
                scrollOffset -= 1
            }
            
        case .down, .character("j"):
            // Scroll down
            if scrollOffset < max(0, filteredEntries.count - entriesPerPage) {
                scrollOffset += 1
            }
            
        case .pageUp:
            // Scroll up a page
            scrollOffset = max(0, scrollOffset - entriesPerPage)
            
        case .pageDown:
            // Scroll down a page
            scrollOffset = min(max(0, filteredEntries.count - entriesPerPage), scrollOffset + entriesPerPage)
            
        case .home:
            // Scroll to the top
            scrollOffset = 0
            
        case .end:
            // Scroll to the bottom
            scrollOffset = max(0, filteredEntries.count - entriesPerPage)
            
        case .left, .character("h"):
            // Cycle platform filter backward
            switch platformFilter {
            case "all":
                platformFilter = "mobile"
            case "pc":
                platformFilter = "all"
            case "mobile":
                platformFilter = "pc"
            default:
                platformFilter = "all"
            }
            // Reset scroll position when filter changes
            scrollOffset = 0
            
        case .right, .character("l"):
            // Cycle platform filter forward
            switch platformFilter {
            case "all":
                platformFilter = "pc"
            case "pc":
                platformFilter = "mobile"
            case "mobile":
                platformFilter = "all"
            default:
                platformFilter = "all"
            }
            // Reset scroll position when filter changes
            scrollOffset = 0
            
        case .escape, .character("b"), .character("q"):
            // Go back
            onBack()
            
        default:
            break
        }
    }
    
    /// Get color for the rank.
    /// - Parameter rank: The rank.
    /// - Returns: The color for the rank.
    private func rankColor(for rank: Int) -> AnsiColor {
        switch rank {
        case 1:
            return .brightYellow // Gold
        case 2:
            return .brightCyan // Silver
        case 3:
            return .brightRed // Bronze
        default:
            return .white
        }
    }
    
    /// Format the score with thousands separators.
    /// - Parameter score: The score to format.
    /// - Returns: The formatted score.
    private func formatScore(_ score: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: score)) ?? "\(score)"
    }
    
    /// Get the platform symbol.
    /// - Parameter platform: The platform.
    /// - Returns: The platform symbol.
    private func platformSymbol(for platform: String) -> String {
        switch platform.lowercased() {
        case "pc":
            return "🖥️"
        case "mobile":
            return "📱"
        default:
            return "🎮"
        }
    }
}