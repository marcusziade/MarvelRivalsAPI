import Foundation
import MarvelRivalsAPI

/// Screen for displaying the hero explorer.
struct HeroExplorerScreen: ScreenProtocol {
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
    
    /// Initialize a hero explorer screen.
    /// - Parameters:
    ///   - heroes: The heroes to display.
    ///   - onSelect: Callback for selecting a hero.
    ///   - onBack: Callback for going back to the previous screen.
    ///   - selectedIndex: The selected hero index. Default is 0.
    ///   - scrollOffset: The scroll offset for the hero list. Default is 0.
    ///   - filterText: The filter text for hero search. Default is empty string.
    ///   - inputMode: The input mode. Default is normal.
    ///   - cursorPosition: The cursor position in the filter input. Default is 0.
    init(
        heroes: [Hero],
        onSelect: @escaping (Hero) -> Void,
        onBack: @escaping () -> Void,
        selectedIndex: Int = 0,
        scrollOffset: Int = 0,
        filterText: String = "",
        inputMode: InputMode = .normal,
        cursorPosition: Int = 0
    ) {
        self.heroes = heroes
        self.onSelect = onSelect
        self.onBack = onBack
        self.selectedIndex = selectedIndex
        self.scrollOffset = scrollOffset
        self.filterText = filterText
        self.inputMode = inputMode
        self.cursorPosition = cursorPosition
    }
    
    /// Input modes.
    enum InputMode {
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
    mutating func render(in context: ScreenContext) {
        let renderer = context.renderer
        let width = context.terminalSize.columns
        let height = context.terminalSize.rows
        
        // Clear the screen
        renderer.clearScreen()
        
        // Draw header
        let headerText = "Hero Explorer"
        renderer.renderAt(row: 1, column: max(0, (width - headerText.count) / 2)) {
            renderer.setForegroundColor(.brightYellow)
            renderer.write(headerText)
            renderer.resetColors()
        }
        
        // Draw search bar
        let searchBarWidth = min(width - 20, 60)
        let searchBarStartColumn = max(0, (width - searchBarWidth) / 2)
        
        renderer.renderAt(row: 3, column: searchBarStartColumn) {
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
            
            renderer.renderAt(row: 3, column: cursorColumn) {
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
        renderer.renderAt(row: 4, column: 0) {
            renderer.drawHorizontalLine(row: 4, startColumn: 0, width: width)
        }
        
        // Draw column headers
        renderer.renderAt(row: 6, column: 2) {
            renderer.setForegroundColor(.brightBlack)
            renderer.write("Hero".padding(toLength: 20, withPad: " ", startingAt: 0))
            renderer.write("Role".padding(toLength: 15, withPad: " ", startingAt: 0))
            renderer.write("Difficulty".padding(toLength: 15, withPad: " ", startingAt: 0))
            renderer.resetColors()
        }
        
        // Draw horizontal line
        renderer.renderAt(row: 7, column: 0) {
            renderer.drawHorizontalLine(row: 7, startColumn: 0, width: width)
        }
        
        // Calculate visible rows
        let visibleRows = height - 10 // Accounting for header, search, and footer
        
        // Adjust scroll offset if necessary
        if selectedIndex < scrollOffset {
            scrollOffset = selectedIndex
        } else if selectedIndex >= scrollOffset + visibleRows {
            scrollOffset = selectedIndex - visibleRows + 1
        }
        
        // Draw heroes
        let heroes = filteredHeroes
        if heroes.isEmpty {
            renderer.renderAt(row: 9, column: 2) {
                renderer.setForegroundColor(.brightBlack)
                renderer.write("No heroes match your search criteria.")
                renderer.resetColors()
            }
        } else {
            for i in 0..<min(visibleRows, heroes.count - scrollOffset) {
                let heroIndex = i + scrollOffset
                let hero = heroes[heroIndex]
                let isSelected = heroIndex == selectedIndex
                
                renderer.renderAt(row: 9 + i, column: 2) {
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
                renderer.renderAt(row: 8, column: width - 5) {
                    renderer.setForegroundColor(.brightBlack)
                    renderer.write("▲")
                    renderer.resetColors()
                }
            }
            
            if scrollOffset + visibleRows < heroes.count {
                renderer.renderAt(row: 8 + visibleRows, column: width - 5) {
                    renderer.setForegroundColor(.brightBlack)
                    renderer.write("▼")
                    renderer.resetColors()
                }
            }
        }
        
        // Draw selected hero details
        if !heroes.isEmpty && selectedIndex < heroes.count {
            let selectedHero = heroes[selectedIndex]
            let detailsStartRow = 9 + visibleRows + 1
            
            // Draw horizontal line
            renderer.renderAt(row: detailsStartRow - 1, column: 0) {
                renderer.drawHorizontalLine(row: detailsStartRow - 1, startColumn: 0, width: width)
            }
            
            // Draw hero name and role
            renderer.renderAt(row: detailsStartRow, column: 2) {
                renderer.setForegroundColor(.brightCyan)
                renderer.write("\(selectedHero.name) - \(selectedHero.role)")
                renderer.resetColors()
            }
            
            // Draw hero description
            let descriptionLines = wrapText(selectedHero.description, width: width - 4)
            for (i, line) in descriptionLines.enumerated().prefix(3) {
                renderer.renderAt(row: detailsStartRow + 2 + i, column: 2) {
                    renderer.write(line)
                }
            }
            
            // Draw hero abilities
            renderer.renderAt(row: detailsStartRow + 6, column: 2) {
                renderer.setForegroundColor(.brightYellow)
                renderer.write("Abilities:")
                renderer.resetColors()
            }
            
            // Draw only the first ability if there's not enough space
            if selectedHero.abilities.count > 0 {
                let ability = selectedHero.abilities[0]
                renderer.renderAt(row: detailsStartRow + 7, column: 4) {
                    renderer.setForegroundColor(.brightWhite)
                    renderer.write(ability.name)
                    renderer.resetColors()
                    if let cooldown = ability.cooldown {
                        renderer.write(" (CD: \(cooldown))")
                    }
                }
                
                let abilityDescLines = wrapText(ability.description, width: width - 6)
                if abilityDescLines.count > 0 {
                    renderer.renderAt(row: detailsStartRow + 8, column: 4) {
                        renderer.write(abilityDescLines[0])
                    }
                }
            }
        }
        
        // Draw navigation help
        let navHelp = "j/k to navigate, / to search, Enter to select, Esc to go back"
        renderer.renderAt(row: height - 2, column: max(0, (width - navHelp.count) / 2)) {
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
        case .search:
            handleSearchModeKey(key)
        }
    }
    
    /// Handle a key press in normal mode.
    /// - Parameter key: The key that was pressed.
    private mutating func handleNormalModeKey(_ key: Key) {
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
            
        case .escape, .character("q"):
            // Go back
            onBack()
            
        default:
            break
        }
    }
    
    /// Handle a key press in search mode.
    /// - Parameter key: The key that was pressed.
    private mutating func handleSearchModeKey(_ key: Key) {
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