import Foundation
import Logging

/// Application configuration.
struct AppConfig: Codable {
    /// The log level.
    var logLevel: Logger.Level
    
    /// The last used player username.
    var lastUsedPlayer: String?
    
    /// The refresh interval for auto-refresh features.
    var refreshInterval: TimeInterval
    
    /// Whether to use vim-style keybindings.
    var useVimBindings: Bool
    
    /// The color theme.
    var colorTheme: ColorTheme
    
    /// Default configuration.
    static let `default` = AppConfig(
        logLevel: .info,
        lastUsedPlayer: nil,
        refreshInterval: 60.0,
        useVimBindings: true,
        colorTheme: .default
    )
    
    /// Load the configuration from disk.
    /// - Returns: The loaded configuration, or the default if no configuration exists.
    static func load() -> AppConfig {
        guard let url = configURL(),
              let data = try? Data(contentsOf: url),
              let config = try? JSONDecoder().decode(AppConfig.self, from: data) else {
            return .default
        }
        
        return config
    }
    
    /// Save the configuration to disk.
    func save() {
        guard let url = AppConfig.configURL(),
              let data = try? JSONEncoder().encode(self) else {
            return
        }
        
        try? data.write(to: url)
    }
    
    /// Get the URL for the configuration file.
    /// - Returns: The URL for the configuration file.
    private static func configURL() -> URL? {
        guard let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let appDirectory = appSupportURL.appendingPathComponent("RivalTracker", isDirectory: true)
        
        // Create the directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: appDirectory.path) {
            try? FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        }
        
        return appDirectory.appendingPathComponent("config.json")
    }
}

/// Color theme for the application.
enum ColorTheme: String, Codable, CaseIterable {
    /// Default theme.
    case `default` = "Default"
    
    /// Dark theme.
    case dark = "Dark"
    
    /// Light theme.
    case light = "Light"
    
    /// High contrast theme.
    case highContrast = "High Contrast"
    
    /// Get the terminal colors for the theme.
    var colors: ThemeColors {
        switch self {
        case .default:
            return ThemeColors(
                primary: .cyan,
                secondary: .magenta,
                accent: .brightYellow,
                success: .green,
                warning: .brightYellow,
                error: .brightRed,
                background: .black,
                text: .white
            )
        case .dark:
            return ThemeColors(
                primary: .blue,
                secondary: .brightMagenta,
                accent: .brightCyan,
                success: .brightGreen,
                warning: .yellow,
                error: .red,
                background: .black,
                text: .brightWhite
            )
        case .light:
            return ThemeColors(
                primary: .blue,
                secondary: .magenta,
                accent: .brightCyan,
                success: .green,
                warning: .brightYellow,
                error: .red,
                background: .white,
                text: .black
            )
        case .highContrast:
            return ThemeColors(
                primary: .brightWhite,
                secondary: .brightCyan,
                accent: .brightYellow,
                success: .brightGreen,
                warning: .brightYellow,
                error: .brightRed,
                background: .black,
                text: .brightWhite
            )
        }
    }
}

/// Theme colors.
struct ThemeColors {
    /// Primary color.
    let primary: AnsiColor
    
    /// Secondary color.
    let secondary: AnsiColor
    
    /// Accent color.
    let accent: AnsiColor
    
    /// Success color.
    let success: AnsiColor
    
    /// Warning color.
    let warning: AnsiColor
    
    /// Error color.
    let error: AnsiColor
    
    /// Background color.
    let background: AnsiColor
    
    /// Text color.
    let text: AnsiColor
}