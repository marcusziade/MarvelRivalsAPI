import Foundation
import Logging

/// Screen for displaying and editing settings.
struct SettingsScreen: ScreenProtocol {
    /// The current configuration.
    let config: AppConfig
    
    /// Callback for saving changes.
    let onSave: (AppConfig) -> Void
    
    /// Callback for canceling changes.
    let onCancel: () -> Void
    
    /// Callback for resetting the API key.
    let onResetAPIKey: () -> Void
    
    /// The selected setting index.
    private var selectedIndex: Int = 0
    
    /// Initialize a settings screen.
    /// - Parameters:
    ///   - config: The current configuration.
    ///   - onSave: Callback for saving changes.
    ///   - onCancel: Callback for canceling changes.
    ///   - onResetAPIKey: Callback for resetting the API key.
    ///   - selectedIndex: The selected setting index. Default is 0.
    init(
        config: AppConfig,
        onSave: @escaping (AppConfig) -> Void,
        onCancel: @escaping () -> Void,
        onResetAPIKey: @escaping () -> Void,
        selectedIndex: Int = 0
    ) {
        self.config = config
        self.onSave = onSave
        self.onCancel = onCancel
        self.onResetAPIKey = onResetAPIKey
        self.selectedIndex = selectedIndex
        self.editedConfig = config
    }
    
    /// The edited configuration.
    private var editedConfig: AppConfig
    
    /// Whether the screen is in edit mode.
    private var isEditing: Bool = false
    
    /// Whether to show the confirmation for API key reset.
    private var showResetConfirmation: Bool = false
    
    /// Initialize the settings screen.
    /// - Parameters:
    ///   - config: The current configuration.
    ///   - onSave: Callback for saving changes.
    ///   - onCancel: Callback for canceling changes.
    ///   - onResetAPIKey: Callback for resetting the API key.
    init(config: AppConfig, onSave: @escaping (AppConfig) -> Void, onCancel: @escaping () -> Void, onResetAPIKey: @escaping () -> Void) {
        self.config = config
        self.editedConfig = config
        self.onSave = onSave
        self.onCancel = onCancel
        self.onResetAPIKey = onResetAPIKey
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
        let headerText = "Settings"
        renderer.renderAt(row: 1, column: max(0, (width - headerText.count) / 2)) {
            renderer.setForegroundColor(.brightYellow)
            renderer.write(headerText)
            renderer.resetColors()
        }
        
        // Draw settings
        let settingsStartRow = 3
        let settingsStartColumn = 4
        let settingLabelWidth = 20
        let settingValueColumn = settingsStartColumn + settingLabelWidth + 2
        
        // Draw log level setting
        let logLevelRow = settingsStartRow + 1
        
        renderer.renderAt(row: logLevelRow, column: settingsStartColumn) {
            if selectedIndex == 0 {
                renderer.setForegroundColor(.brightCyan)
                renderer.write("> Log Level:")
                renderer.resetColors()
            } else {
                renderer.write("  Log Level:")
            }
        }
        
        renderer.renderAt(row: logLevelRow, column: settingValueColumn) {
            if selectedIndex == 0 && isEditing {
                renderer.setForegroundColor(.brightWhite)
                renderer.setBackgroundColor(.blue)
            }
            
            renderer.write(String(describing: editedConfig.logLevel))
            
            if selectedIndex == 0 && isEditing {
                renderer.resetColors()
            }
        }
        
        // Draw refresh interval setting
        let refreshIntervalRow = settingsStartRow + 3
        
        renderer.renderAt(row: refreshIntervalRow, column: settingsStartColumn) {
            if selectedIndex == 1 {
                renderer.setForegroundColor(.brightCyan)
                renderer.write("> Refresh Interval:")
                renderer.resetColors()
            } else {
                renderer.write("  Refresh Interval:")
            }
        }
        
        renderer.renderAt(row: refreshIntervalRow, column: settingValueColumn) {
            if selectedIndex == 1 && isEditing {
                renderer.setForegroundColor(.brightWhite)
                renderer.setBackgroundColor(.blue)
            }
            
            renderer.write("\(Int(editedConfig.refreshInterval)) seconds")
            
            if selectedIndex == 1 && isEditing {
                renderer.resetColors()
            }
        }
        
        // Draw vim keybindings setting
        let vimBindingsRow = settingsStartRow + 5
        
        renderer.renderAt(row: vimBindingsRow, column: settingsStartColumn) {
            if selectedIndex == 2 {
                renderer.setForegroundColor(.brightCyan)
                renderer.write("> Vim Keybindings:")
                renderer.resetColors()
            } else {
                renderer.write("  Vim Keybindings:")
            }
        }
        
        renderer.renderAt(row: vimBindingsRow, column: settingValueColumn) {
            if selectedIndex == 2 && isEditing {
                renderer.setForegroundColor(.brightWhite)
                renderer.setBackgroundColor(.blue)
            }
            
            renderer.write(editedConfig.useVimBindings ? "Enabled" : "Disabled")
            
            if selectedIndex == 2 && isEditing {
                renderer.resetColors()
            }
        }
        
        // Draw color theme setting
        let colorThemeRow = settingsStartRow + 7
        
        renderer.renderAt(row: colorThemeRow, column: settingsStartColumn) {
            if selectedIndex == 3 {
                renderer.setForegroundColor(.brightCyan)
                renderer.write("> Color Theme:")
                renderer.resetColors()
            } else {
                renderer.write("  Color Theme:")
            }
        }
        
        renderer.renderAt(row: colorThemeRow, column: settingValueColumn) {
            if selectedIndex == 3 && isEditing {
                renderer.setForegroundColor(.brightWhite)
                renderer.setBackgroundColor(.blue)
            }
            
            renderer.write(editedConfig.colorTheme.rawValue)
            
            if selectedIndex == 3 && isEditing {
                renderer.resetColors()
            }
        }
        
        // Draw reset API key option
        let resetAPIKeyRow = settingsStartRow + 9
        
        renderer.renderAt(row: resetAPIKeyRow, column: settingsStartColumn) {
            if selectedIndex == 4 {
                renderer.setForegroundColor(.brightCyan)
                renderer.write("> Reset API Key")
                renderer.resetColors()
            } else {
                renderer.write("  Reset API Key")
            }
        }
        
        // Draw reset API key confirmation if showing
        if showResetConfirmation {
            renderer.renderAt(row: resetAPIKeyRow + 2, column: settingsStartColumn + 2) {
                renderer.setForegroundColor(.brightRed)
                renderer.write("Are you sure you want to reset your API key?")
                renderer.resetColors()
            }
            
            renderer.renderAt(row: resetAPIKeyRow + 3, column: settingsStartColumn + 2) {
                renderer.write("This will require restarting the application.")
            }
            
            renderer.renderAt(row: resetAPIKeyRow + 5, column: settingsStartColumn + 2) {
                renderer.write("Press Y to confirm, N to cancel.")
            }
        }
        
        // Draw save and cancel options
        let saveRow = settingsStartRow + 12
        
        renderer.renderAt(row: saveRow, column: settingsStartColumn) {
            if selectedIndex == 5 {
                renderer.setForegroundColor(.brightCyan)
                renderer.write("> Save Changes")
                renderer.resetColors()
            } else {
                renderer.write("  Save Changes")
            }
        }
        
        let cancelRow = settingsStartRow + 13
        
        renderer.renderAt(row: cancelRow, column: settingsStartColumn) {
            if selectedIndex == 6 {
                renderer.setForegroundColor(.brightCyan)
                renderer.write("> Cancel")
                renderer.resetColors()
            } else {
                renderer.write("  Cancel")
            }
        }
        
        // Draw editing help
        let helpRow = height - 3
        let helpText = isEditing
            ? "Use ←/→ to change value, Enter to confirm, Esc to cancel editing"
            : "Use j/k to navigate, Enter to edit, Esc to go back"
        
        renderer.renderAt(row: helpRow, column: max(0, (width - helpText.count) / 2)) {
            renderer.setForegroundColor(.brightBlack)
            renderer.write(helpText)
            renderer.resetColors()
        }
    }
    
    /// Handle a key press.
    /// - Parameter key: The key that was pressed.
    mutating func handleKey(_ key: Key) {
        // Handle reset API key confirmation
        if showResetConfirmation {
            switch key {
            case .character("y"), .character("Y"):
                onResetAPIKey()
                return
            case .character("n"), .character("N"), .escape:
                showResetConfirmation = false
                return
            default:
                return
            }
        }
        
        // Handle editing mode
        if isEditing {
            handleEditingModeKey(key)
            return
        }
        
        // Handle normal mode
        switch key {
        case .up, .character("k"):
            // Move up
            if selectedIndex > 0 {
                selectedIndex -= 1
            }
            
        case .down, .character("j"):
            // Move down
            if selectedIndex < 6 {
                selectedIndex += 1
            }
            
        case .enter, .character(" "):
            // Edit the selected setting or trigger action
            switch selectedIndex {
            case 0, 1, 2, 3:
                // Edit setting
                isEditing = true
            case 4:
                // Reset API key
                showResetConfirmation = true
            case 5:
                // Save changes
                onSave(editedConfig)
            case 6:
                // Cancel
                onCancel()
            default:
                break
            }
            
        case .escape:
            // Go back
            onCancel()
            
        default:
            break
        }
    }
    
    /// Handle a key press in editing mode.
    /// - Parameter key: The key that was pressed.
    private mutating func handleEditingModeKey(_ key: Key) {
        switch key {
        case .escape:
            // Exit editing mode
            isEditing = false
            
        case .enter:
            // Confirm edit
            isEditing = false
            
        case .left, .character("h"):
            // Decrease value
            decreaseSelectedValue()
            
        case .right, .character("l"):
            // Increase value
            increaseSelectedValue()
            
        default:
            break
        }
    }
    
    /// Decrease the value of the selected setting.
    private mutating func decreaseSelectedValue() {
        switch selectedIndex {
        case 0:
            // Decrease log level
            let logLevels: [Logger.Level] = [.trace, .debug, .info, .notice, .warning, .error, .critical]
            if let currentIndex = logLevels.firstIndex(of: editedConfig.logLevel), currentIndex > 0 {
                editedConfig.logLevel = logLevels[currentIndex - 1]
            }
            
        case 1:
            // Decrease refresh interval (minimum 10 seconds)
            editedConfig.refreshInterval = max(10, editedConfig.refreshInterval - 10)
            
        case 2:
            // Toggle vim bindings
            editedConfig.useVimBindings.toggle()
            
        case 3:
            // Decrease color theme
            let themes = ColorTheme.allCases
            if let currentIndex = themes.firstIndex(of: editedConfig.colorTheme), currentIndex > 0 {
                editedConfig.colorTheme = themes[currentIndex - 1]
            }
            
        default:
            break
        }
    }
    
    /// Increase the value of the selected setting.
    private mutating func increaseSelectedValue() {
        switch selectedIndex {
        case 0:
            // Increase log level
            let logLevels: [Logger.Level] = [.trace, .debug, .info, .notice, .warning, .error, .critical]
            if let currentIndex = logLevels.firstIndex(of: editedConfig.logLevel), currentIndex < logLevels.count - 1 {
                editedConfig.logLevel = logLevels[currentIndex + 1]
            }
            
        case 1:
            // Increase refresh interval (maximum 300 seconds)
            editedConfig.refreshInterval = min(300, editedConfig.refreshInterval + 10)
            
        case 2:
            // Toggle vim bindings
            editedConfig.useVimBindings.toggle()
            
        case 3:
            // Increase color theme
            let themes = ColorTheme.allCases
            if let currentIndex = themes.firstIndex(of: editedConfig.colorTheme), currentIndex < themes.count - 1 {
                editedConfig.colorTheme = themes[currentIndex + 1]
            }
            
        default:
            break
        }
    }
}