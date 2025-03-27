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
    func render(in context: ScreenContext)
    
    /// Handle a key press.
    /// - Parameter key: The key that was pressed.
    func handleKey(_ key: Key)
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
    func render(in context: ScreenContext) {
        switch self {
        case .welcome(let onboarding):
            WelcomeScreen(onboarding: onboarding).render(in: context)
            
        case let .mainMenu(onPlayerDashboard, onHeroExplorer, onMatchAnalysis, onLeaderboards, onSettings, onHelp, onExit):
            MainMenuScreen(
                onPlayerDashboard: onPlayerDashboard,
                onHeroExplorer: onHeroExplorer,
                onMatchAnalysis: onMatchAnalysis,
                onLeaderboards: onLeaderboards,
                onSettings: onSettings,
                onHelp: onHelp,
                onExit: onExit
            ).render(in: context)
            
        case let .playerSearch(onSearch, onCancel):
            PlayerSearchScreen(
                onSearch: onSearch,
                onCancel: onCancel
            ).render(in: context)
            
        case let .playerDashboard(player, stats, matches, onRefresh, onBack):
            PlayerDashboardScreen(
                player: player,
                stats: stats,
                matches: matches,
                onRefresh: onRefresh,
                onBack: onBack
            ).render(in: context)
            
        case let .heroExplorer(heroes, onSelect, onBack):
            HeroExplorerScreen(
                heroes: heroes,
                onSelect: onSelect,
                onBack: onBack
            ).render(in: context)
            
        case let .heroDetails(hero, stats, leaderboard, onBack):
            HeroDetailsScreen(
                hero: hero,
                stats: stats,
                leaderboard: leaderboard,
                onBack: onBack
            ).render(in: context)
            
        case let .matchSearch(onSearch, onCancel):
            MatchSearchScreen(
                onSearch: onSearch,
                onCancel: onCancel
            ).render(in: context)
            
        case let .matchDetails(match, onBack):
            MatchDetailsScreen(
                match: match,
                onBack: onBack
            ).render(in: context)
            
        case let .leaderboardSelection(heroes, onSelect, onBack):
            LeaderboardSelectionScreen(
                heroes: heroes,
                onSelect: onSelect,
                onBack: onBack
            ).render(in: context)
            
        case let .heroLeaderboard(hero, leaderboard, onBack):
            HeroLeaderboardScreen(
                hero: hero,
                leaderboard: leaderboard,
                onBack: onBack
            ).render(in: context)
            
        case let .settings(config, onSave, onCancel, onResetAPIKey):
            SettingsScreen(
                config: config,
                onSave: onSave,
                onCancel: onCancel,
                onResetAPIKey: onResetAPIKey
            ).render(in: context)
            
        case let .help(onBack):
            HelpScreen(
                onBack: onBack
            ).render(in: context)
        }
    }
    
    /// Handle a key press.
    /// - Parameter key: The key that was pressed.
    func handleKey(_ key: Key) {
        switch self {
        case .welcome(let onboarding):
            WelcomeScreen(onboarding: onboarding).handleKey(key)
            
        case let .mainMenu(onPlayerDashboard, onHeroExplorer, onMatchAnalysis, onLeaderboards, onSettings, onHelp, onExit):
            MainMenuScreen(
                onPlayerDashboard: onPlayerDashboard,
                onHeroExplorer: onHeroExplorer,
                onMatchAnalysis: onMatchAnalysis,
                onLeaderboards: onLeaderboards,
                onSettings: onSettings,
                onHelp: onHelp,
                onExit: onExit
            ).handleKey(key)
            
        case let .playerSearch(onSearch, onCancel):
            PlayerSearchScreen(
                onSearch: onSearch,
                onCancel: onCancel
            ).handleKey(key)
            
        case let .playerDashboard(player, stats, matches, onRefresh, onBack):
            PlayerDashboardScreen(
                player: player,
                stats: stats,
                matches: matches,
                onRefresh: onRefresh,
                onBack: onBack
            ).handleKey(key)
            
        case let .heroExplorer(heroes, onSelect, onBack):
            HeroExplorerScreen(
                heroes: heroes,
                onSelect: onSelect,
                onBack: onBack
            ).handleKey(key)
            
        case let .heroDetails(hero, stats, leaderboard, onBack):
            HeroDetailsScreen(
                hero: hero,
                stats: stats,
                leaderboard: leaderboard,
                onBack: onBack
            ).handleKey(key)
            
        case let .matchSearch(onSearch, onCancel):
            MatchSearchScreen(
                onSearch: onSearch,
                onCancel: onCancel
            ).handleKey(key)
            
        case let .matchDetails(match, onBack):
            MatchDetailsScreen(
                match: match,
                onBack: onBack
            ).handleKey(key)
            
        case let .leaderboardSelection(heroes, onSelect, onBack):
            LeaderboardSelectionScreen(
                heroes: heroes,
                onSelect: onSelect,
                onBack: onBack
            ).handleKey(key)
            
        case let .heroLeaderboard(hero, leaderboard, onBack):
            HeroLeaderboardScreen(
                hero: hero,
                leaderboard: leaderboard,
                onBack: onBack
            ).handleKey(key)
            
        case let .settings(config, onSave, onCancel, onResetAPIKey):
            SettingsScreen(
                config: config,
                onSave: onSave,
                onCancel: onCancel,
                onResetAPIKey: onResetAPIKey
            ).handleKey(key)
            
        case let .help(onBack):
            HelpScreen(
                onBack: onBack
            ).handleKey(key)
        }
    }
}