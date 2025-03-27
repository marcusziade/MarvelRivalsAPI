import Foundation
import MarvelRivalsAPI

/// Context for rendering a screen.
struct ScreenContext {
    /// The size of the terminal.
    let terminalSize: TerminalSize
    
    /// The terminal renderer.
    let renderer: TerminalRenderer
}

/// Protocol for a screen in the application.
protocol ScreenProtocol {
    /// Render the screen.
    /// - Parameter context: The screen context.
    mutating func render(in context: ScreenContext)
    
    /// Handle a key press.
    /// - Parameter key: The key that was pressed.
    mutating func handleKey(_ key: Key)
}

/// Represents a screen in the application.
enum Screen {
    // MARK: - Welcome Screen
    
    /// Welcome screen for first-time users.
    case welcome(onboarding: (String) -> Void)
    
    // MARK: - Main Menu
    
    /// Main menu screen.
    case mainMenu(
        onPlayerDashboard: () -> Void,
        onHeroExplorer: () -> Void,
        onMatchAnalysis: () -> Void,
        onLeaderboards: () -> Void,
        onSettings: () -> Void,
        onHelp: () -> Void,
        onExit: () -> Void
    )
    
    // MARK: - Player Screens
    
    /// Player search screen.
    case playerSearch(
        onSearch: (String) -> Void,
        onCancel: () -> Void
    )
    
    /// Player dashboard screen.
    case playerDashboard(
        player: Player,
        stats: PlayerStats,
        matches: [Match],
        onRefresh: () -> Void,
        onBack: () -> Void
    )
    
    // MARK: - Hero Screens
    
    /// Hero explorer screen.
    case heroExplorer(
        heroes: [Hero],
        onSelect: (Hero) -> Void,
        onBack: () -> Void
    )
    
    /// Hero details screen.
    case heroDetails(
        hero: Hero,
        stats: HeroStats,
        leaderboard: HeroLeaderboard,
        onBack: () -> Void
    )
    
    // MARK: - Match Screens
    
    /// Match search screen.
    case matchSearch(
        onSearch: (String) -> Void,
        onCancel: () -> Void
    )
    
    /// Match details screen.
    case matchDetails(
        match: Match,
        onBack: () -> Void
    )
    
    // MARK: - Leaderboard Screens
    
    /// Leaderboard selection screen.
    case leaderboardSelection(
        heroes: [Hero],
        onSelect: (Hero) -> Void,
        onBack: () -> Void
    )
    
    /// Hero leaderboard screen.
    case heroLeaderboard(
        hero: Hero,
        leaderboard: HeroLeaderboard,
        onBack: () -> Void
    )
    
    // MARK: - Settings Screen
    
    /// Settings screen.
    case settings(
        config: AppConfig,
        onSave: (AppConfig) -> Void,
        onCancel: () -> Void,
        onResetAPIKey: () -> Void
    )
    
    // MARK: - Help Screen
    
    /// Help screen.
    case help(
        onBack: () -> Void
    )
}

// MARK: - ScreenProtocol Conformance

extension Screen: ScreenProtocol {
    /// Render the screen.
    /// - Parameter context: The screen context.
    mutating func render(in context: ScreenContext) {
        switch self {
        case .welcome(let onboarding):
            var screen = WelcomeScreen(onboarding: onboarding)
            screen.render(in: context)
            
        case let .mainMenu(onPlayerDashboard, onHeroExplorer, onMatchAnalysis, onLeaderboards, onSettings, onHelp, onExit):
            var screen = MainMenuScreen(
                onPlayerDashboard: onPlayerDashboard,
                onHeroExplorer: onHeroExplorer,
                onMatchAnalysis: onMatchAnalysis,
                onLeaderboards: onLeaderboards,
                onSettings: onSettings,
                onHelp: onHelp,
                onExit: onExit
            )
            screen.render(in: context)
            
        case let .playerSearch(onSearch, onCancel):
            var screen = PlayerSearchScreen(
                onSearch: onSearch,
                onCancel: onCancel
            )
            screen.render(in: context)
            
        case let .playerDashboard(player, stats, matches, onRefresh, onBack):
            var screen = PlayerDashboardScreen(
                player: player,
                stats: stats,
                matches: matches,
                onRefresh: onRefresh,
                onBack: onBack
            )
            screen.render(in: context)
            
        case let .heroExplorer(heroes, onSelect, onBack):
            var screen = HeroExplorerScreen(
                heroes: heroes,
                onSelect: onSelect,
                onBack: onBack
            )
            screen.render(in: context)
            
        case let .heroDetails(hero, stats, leaderboard, onBack):
            var screen = HeroDetailsScreen(
                hero: hero,
                stats: stats,
                leaderboard: leaderboard,
                onBack: onBack
            )
            screen.render(in: context)
            
        case let .matchSearch(onSearch, onCancel):
            var screen = MatchSearchScreen(
                onSearch: onSearch,
                onCancel: onCancel
            )
            screen.render(in: context)
            
        case let .matchDetails(match, onBack):
            var screen = MatchDetailsScreen(
                match: match,
                onBack: onBack
            )
            screen.render(in: context)
            
        case let .leaderboardSelection(heroes, onSelect, onBack):
            var screen = LeaderboardSelectionScreen(
                heroes: heroes,
                onSelect: onSelect,
                onBack: onBack
            )
            screen.render(in: context)
            
        case let .heroLeaderboard(hero, leaderboard, onBack):
            var screen = HeroLeaderboardScreen(
                hero: hero,
                leaderboard: leaderboard,
                onBack: onBack
            )
            screen.render(in: context)
            
        case let .settings(config, onSave, onCancel, onResetAPIKey):
            var screen = SettingsScreen(
                config: config,
                onSave: onSave,
                onCancel: onCancel,
                onResetAPIKey: onResetAPIKey
            )
            screen.render(in: context)
            
        case let .help(onBack):
            var screen = HelpScreen(
                onBack: onBack
            )
            screen.render(in: context)
        }
    }
    
    /// Handle a key press.
    /// - Parameter key: The key that was pressed.
    mutating func handleKey(_ key: Key) {
        switch self {
        case .welcome(let onboarding):
            var screen = WelcomeScreen(onboarding: onboarding)
            screen.handleKey(key)
            
        case let .mainMenu(onPlayerDashboard, onHeroExplorer, onMatchAnalysis, onLeaderboards, onSettings, onHelp, onExit):
            var screen = MainMenuScreen(
                onPlayerDashboard: onPlayerDashboard,
                onHeroExplorer: onHeroExplorer,
                onMatchAnalysis: onMatchAnalysis,
                onLeaderboards: onLeaderboards,
                onSettings: onSettings,
                onHelp: onHelp,
                onExit: onExit
            )
            screen.handleKey(key)
            
        case let .playerSearch(onSearch, onCancel):
            var screen = PlayerSearchScreen(
                onSearch: onSearch,
                onCancel: onCancel
            )
            screen.handleKey(key)
            
        case let .playerDashboard(player, stats, matches, onRefresh, onBack):
            var screen = PlayerDashboardScreen(
                player: player,
                stats: stats,
                matches: matches,
                onRefresh: onRefresh,
                onBack: onBack
            )
            screen.handleKey(key)
            
        case let .heroExplorer(heroes, onSelect, onBack):
            var screen = HeroExplorerScreen(
                heroes: heroes,
                onSelect: onSelect,
                onBack: onBack
            )
            screen.handleKey(key)
            
        case let .heroDetails(hero, stats, leaderboard, onBack):
            var screen = HeroDetailsScreen(
                hero: hero,
                stats: stats,
                leaderboard: leaderboard,
                onBack: onBack
            )
            screen.handleKey(key)
            
        case let .matchSearch(onSearch, onCancel):
            var screen = MatchSearchScreen(
                onSearch: onSearch,
                onCancel: onCancel
            )
            screen.handleKey(key)
            
        case let .matchDetails(match, onBack):
            var screen = MatchDetailsScreen(
                match: match,
                onBack: onBack
            )
            screen.handleKey(key)
            
        case let .leaderboardSelection(heroes, onSelect, onBack):
            var screen = LeaderboardSelectionScreen(
                heroes: heroes,
                onSelect: onSelect,
                onBack: onBack
            )
            screen.handleKey(key)
            
        case let .heroLeaderboard(hero, leaderboard, onBack):
            var screen = HeroLeaderboardScreen(
                hero: hero,
                leaderboard: leaderboard,
                onBack: onBack
            )
            screen.handleKey(key)
            
        case let .settings(config, onSave, onCancel, onResetAPIKey):
            var screen = SettingsScreen(
                config: config,
                onSave: onSave,
                onCancel: onCancel,
                onResetAPIKey: onResetAPIKey
            )
            screen.handleKey(key)
            
        case let .help(onBack):
            var screen = HelpScreen(
                onBack: onBack
            )
            screen.handleKey(key)
        }
    }
}