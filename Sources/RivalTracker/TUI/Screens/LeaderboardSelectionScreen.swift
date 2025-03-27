import Foundation
import MarvelRivalsAPI

/// Screen for selecting a hero leaderboard.
struct LeaderboardSelectionScreen: ScreenProtocol {
    /// The heroes to display.
    let heroes: [Hero]
    
    /// Callback for selecting a hero.
    let onSelect: (Hero) -> Void
    
    /// Callback for going back to the previous screen.
    let onBack: () -> Void
    
    /// The selected hero index.
    private var selectedIndex: Int = 0
    
    /// The scroll offset for the hero list.
    private var scrollOffset: Int = 0
    
    /// The filter text for hero search.
    private var filterText: String = ""
    
    /// The input mode.
    private var inputMode: InputMode = .normal
    
    /// The cursor position in the filter input.
    private var cursorPosition: Int = 0
    
    /// Input modes.
    private enum InputMode {
        case normal
        case search
    }
    
    /// Filtered heroes based on the filter text.
    private var filteredHeroes: [Hero] {
        if filterText.isEmpty {
            return heroes
        } else {
            return heroes.filter { hero in
                hero.name.lowercased().contains(filterText.lowercased()) ||
                hero.role.lowercased().contains(filterText.lowercased())
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
        let headerText = "Leaderboard Selection"
        renderer.renderAt(row: 1, column: max(0, (width - headerText.count) / 2)) {
            renderer.setForegroundColor(.brightYellow)
            renderer.write(headerText)
            renderer.resetColors()
        }
        
        // Draw instructions
        let instructions = "Select a hero to view its leaderboard"
        renderer.renderAt(row: 2, column: max(0, (width - instructions.count) / 2)) {
            renderer.write(instructions)
        }
        
        // Draw search bar
        let searchBarWidth = min(width - 20, 60)
        let searchBarStartColumn = max(0, (width - searchBarWidth) / 2)
        
        renderer.renderAt(row: 4, column: searchBarStartColumn) {
            renderer.write("Search: ")
            
            if inputMode == .search {
                renderer.setForegroundColor(.brightWhite)
            }
            
            renderer.write(filterText.isEmpty ? "<type to search>" : filterText)
            renderer.resetColors()
        }
        
        // Draw the cursor in search mode
        if inputMode == .search {
            let cursorColumn = searchBarStartColumn + 8 + cursorPosition // "Search: " is 8 characters
            
            renderer.renderAt(row: 4, column: cursorColumn) {
                renderer.setForegroundColor(.brightWhite)
                renderer.setBackgroundColor(.brightBlack)
                
                if cursorPosition < filterText.count {
                    let charIndex = filterText.index(filterText.startIndex, offsetBy: cursorPosition)
                    renderer.write(String(filterText[charIndex]))
                } else {
                    renderer.write(" ")
                }
                
                renderer.resetColors()
            }
        }
        
        // Draw horizontal line
        renderer.renderAt(row: 5, column: 0) {
            renderer.drawHorizontalLine(row: 5, startColumn: 0, width: width)
        }
        
        // Draw column headers
        renderer.renderAt(row: 7, column: 2) {
            renderer.setForegroundColor(.brightBlack)
            renderer.write("Hero".padding(toLength: 20, withPad: " ", startingAt: 0))
            renderer.write("Role".padding(toLength: 15, withPad: " ", startingAt: 0))
            renderer.write("Difficulty".padding(toLength: 15, withPad: " ", startingAt: 0))
            renderer.resetColors()
        }
        
        // Draw horizontal line
        renderer.renderAt(row: 8, column: 0) {
            renderer.drawHorizontalLine(row: 8, startColumn: 0, width: width)
        }
        
        // Calculate visible rows
        let visibleRows = height - 12 // Accounting for header, search, and footer
        
        // Adjust scroll offset if necessary
        if selectedIndex < scrollOffset {
            scrollOffset = selectedIndex
        } else if selectedIndex >= scrollOffset + visibleRows {
            scrollOffset = selectedIndex - visibleRows + 1
        }
        
        // Draw heroes
        let heroes = filteredHeroes
        if heroes.isEmpty {
            renderer.renderAt(row: 10, column: 2) {
                renderer.setForegroundColor(.brightBlack)
                renderer.write("No heroes match your search criteria.")
                renderer.resetColors()
            }
        } else {
            for i in 0..<min(visibleRows, heroes.count - scrollOffset) {
                let heroIndex = i + scrollOffset
                let hero = heroes[heroIndex]
                let isSelected = heroIndex == selectedIndex
                
                renderer.renderAt(row: 10 + i, column: 2) {
                    if isSelected {
                        renderer.setForegroundColor(.brightWhite)
                        renderer.setBackgroundColor(.blue)
                    }
                    
                    renderer.write(hero.name.padding(toLength: 20, withPad: " ", startingAt: 0))
                    renderer.write(hero.role.padding(toLength: 15, withPad: " ", startingAt: 0))
                    
                    // Display difficulty as stars
                    let difficultyStars = String(repeating: "★", count: hero.difficulty)
                    let difficultyEmpty = String(repeating: "☆", count: 5 - hero.difficulty)
                    renderer.write((difficultyStars + difficultyEmpty).padding(toLength: 15, withPad: " ", startingAt: 0))
                    
                    if isSelected {
                        renderer.resetColors()
                    }
                }
            }
        }
        
        // Draw scroll indicators if necessary
        if heroes.count > visibleRows {
            if scrollOffset > 0 {
                renderer.renderAt(row: 9, column: width - 5) {
                    renderer.setForegroundColor(.brightBlack)
                    renderer.write("▲")
                    renderer.resetColors()
                }
            }
            
            if scrollOffset + visibleRows < heroes.count {
                renderer.renderAt(row: 9 + visibleRows, column: width - 5) {
                    renderer.setForegroundColor(.brightBlack)
                    renderer.write("▼")
                    renderer.resetColors()
                }
            }
        }
        
        // Draw navigation help
        let navHelp = inputMode == .normal
            ? "j/k to navigate, / to search, Enter to select, Esc to go back"
            : "Type to search, Esc to exit search mode"
        
        renderer.renderAt(row: height - 2, column: max(0, (width - navHelp.count) / 2)) {
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
        case .search:
            handleSearchModeKey(key)
        }
    }
    
    /// Handle a key press in normal mode.
    /// - Parameter key: The key that was pressed.
    private func handleNormalModeKey(_ key: Key) {
        switch key {
        case .up, .character("k"):
            // Move up
            if selectedIndex > 0 {
                selectedIndex -= 1
            }
            
        case .down, .character("j"):
            // Move down
            if selectedIndex < filteredHeroes.count - 1 {
                selectedIndex += 1
            }
            
        case .pageUp:
            // Move up a page
            selectedIndex = max(0, selectedIndex - 10)
            
        case .pageDown:
            // Move down a page
            selectedIndex = min(filteredHeroes.count - 1, selectedIndex + 10)
            
        case .home:
            // Move to the start
            selectedIndex = 0
            
        case .end:
            // Move to the end
            selectedIndex = max(0, filteredHeroes.count - 1)
            
        case .enter, .character(" "):
            // Select the hero
            if !filteredHeroes.isEmpty && selectedIndex < filteredHeroes.count {
                onSelect(filteredHeroes[selectedIndex])
            }
            
        case .character("/"):
            // Enter search mode
            inputMode = .search
            cursorPosition = filterText.count
            
        case .escape, .character("b"), .character("q"):
            // Go back
            onBack()
            
        default:
            break
        }
    }
    
    /// Handle a key press in search mode.
    /// - Parameter key: The key that was pressed.
    private func handleSearchModeKey(_ key: Key) {
        switch key {
        case .escape:
            // Exit search mode
            inputMode = .normal
            
        case .enter:
            // Exit search mode
            inputMode = .normal
            
            // Reset selection if we have results
            if !filteredHeroes.isEmpty {
                selectedIndex = 0
            }
            
        case .backspace:
            // Delete the character before the cursor
            if cursorPosition > 0 {
                let before = filterText.index(filterText.startIndex, offsetBy: cursorPosition - 1)
                let after = filterText.index(filterText.startIndex, offsetBy: cursorPosition)
                filterText.removeSubrange(before..<after)
                cursorPosition -= 1
            }
            
        case .delete:
            // Delete the character at the cursor
            if cursorPosition < filterText.count {
                let before = filterText.index(filterText.startIndex, offsetBy: cursorPosition)
                let after = filterText.index(filterText.startIndex, offsetBy: cursorPosition + 1)
                filterText.removeSubrange(before..<after)
            }
            
        case .left:
            // Move the cursor left
            if cursorPosition > 0 {
                cursorPosition -= 1
            }
            
        case .right:
            // Move the cursor right
            if cursorPosition < filterText.count {
                cursorPosition += 1
            }
            
        case .home:
            // Move the cursor to the start
            cursorPosition = 0
            
        case .end:
            // Move the cursor to the end
            cursorPosition = filterText.count
            
        case .character(let char):
            // Add the character to the filter text
            let before = filterText.index(filterText.startIndex, offsetBy: cursorPosition)
            filterText.insert(char, at: before)
            cursorPosition += 1
            
            // Reset selection if we have results after filtering
            if !filteredHeroes.isEmpty {
                selectedIndex = 0
            }
            
        default:
            break
        }
    }
}