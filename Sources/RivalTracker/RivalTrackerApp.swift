import Foundation
import MarvelRivalsAPI
import Logging

/// Main application class for RivalTracker.
final class RivalTrackerApp {
    // MARK: - Properties
    
    /// The API client for Marvel Rivals API.
    private var apiClient: MarvelRivalsAPIService?
    
    /// The application configuration.
    private var config: AppConfig
    
    /// The terminal UI manager.
    private var tuiManager: TUIManager
    
    /// The keyboard input handler.
    private var inputHandler: InputHandler
    
    /// The credential manager for secure storage.
    private var credentialManager: CredentialManager
    
    /// Flag indicating if the application is running.
    private var isRunning = false
    
    // MARK: - Initialization
    
    /// Initialize the application.
    init() {
        self.config = AppConfig.load()
        self.credentialManager = CredentialManager()
        self.tuiManager = TUIManager()
        self.inputHandler = InputHandler()
        
        // Set the input handler delegate to self
        self.inputHandler.delegate = self
        
        // Check if API key exists and initialize API client
        if let apiKey = credentialManager.retrieveAPIKey() {
            setupAPIClient(with: apiKey)
        }
    }
    
    // MARK: - Application Lifecycle
    
    /// Run the application.
    func run() {
        // Set up the terminal
        setupTerminal()
        
        // Show the initial screen
        if apiClient != nil {
            showMainMenu()
        } else {
            showWelcomeScreen()
        }
        
        // Start the application loop
        applicationLoop()
    }
    
    /// Set up the terminal.
    private func setupTerminal() {
        // Enter raw mode
        tuiManager.enterRawMode()
        
        // Clear the screen
        tuiManager.clearScreen()
        
        // Hide the cursor
        tuiManager.setCursorVisible(false)
        
        // Set up signal handlers for clean exit
        setupSignalHandlers()
    }
    
    /// Set up signal handlers for clean application exit.
    private func setupSignalHandlers() {
        // Handle SIGINT (Ctrl+C)
        Signal.trap(signal: .int) { [weak self] _ in
            self?.shutdown()
            exit(0)
        }
        
        // Handle SIGTERM
        Signal.trap(signal: .term) { [weak self] _ in
            self?.shutdown()
            exit(0)
        }
    }
    
    /// Application main loop.
    private func applicationLoop() {
        isRunning = true
        
        // Start input handling
        inputHandler.startHandlingInput()
        
        // Run the application until stopped
        while isRunning {
            // Process input events (handled by InputHandler)
            Thread.sleep(forTimeInterval: 0.01)
        }
    }
    
    /// Shutdown the application.
    func shutdown() {
        // Stop the running flag
        isRunning = false
        
        // Clear the screen
        tuiManager.clearScreen()
        
        // Show the cursor
        tuiManager.setCursorVisible(true)
        
        // Exit raw mode
        tuiManager.exitRawMode()
        
        print("Thank you for using RivalTracker!")
    }
    
    // MARK: - API Setup
    
    /// Set up the API client with the given API key.
    private func setupAPIClient(with apiKey: String) {
        apiClient = MarvelRivalsAPI(
            apiKey: apiKey,
            logLevel: config.logLevel
        )
    }
    
    // MARK: - Screen Navigation
    
    /// Show the welcome screen for first-time users.
    private func showWelcomeScreen() {
        tuiManager.renderScreen(.welcome(onboarding: { [weak self] apiKey in
            self?.setupAPIClient(with: apiKey)
            self?.credentialManager.storeAPIKey(apiKey)
            self?.showMainMenu()
        }))
    }
    
    /// Show the main menu.
    private func showMainMenu() {
        tuiManager.renderScreen(.mainMenu(
            onPlayerDashboard: { [weak self] in self?.showPlayerDashboard() },
            onHeroExplorer: { [weak self] in self?.showHeroExplorer() },
            onMatchAnalysis: { [weak self] in self?.showMatchAnalysis() },
            onLeaderboards: { [weak self] in self?.showLeaderboards() },
            onSettings: { [weak self] in self?.showSettings() },
            onHelp: { [weak self] in self?.showHelp() },
            onExit: { [weak self] in self?.shutdown() }
        ))
    }
    
    /// Show the player dashboard.
    private func showPlayerDashboard() {
        guard let api = apiClient else {
            tuiManager.showError("API client not initialized")
            return
        }
        
        // Get the player username from config or prompt
        let playerUsername = config.lastUsedPlayer ?? ""
        
        if playerUsername.isEmpty {
            tuiManager.renderScreen(.playerSearch(
                onSearch: { [weak self] username in
                    self?.loadPlayerDashboard(username: username)
                },
                onCancel: { [weak self] in
                    self?.showMainMenu()
                }
            ))
        } else {
            loadPlayerDashboard(username: playerUsername)
        }
    }
    
    /// Load the player dashboard for the given username.
    private func loadPlayerDashboard(username: String) {
        guard let api = apiClient else {
            tuiManager.showError("API client not initialized")
            return
        }
        
        Task {
            do {
                tuiManager.showLoadingIndicator("Loading player data...")
                
                let player = try await api.findPlayer(username: username)
                let stats = try await api.getPlayerStats(query: player.id, season: nil)
                let matches = try await api.getPlayerMatchHistory(query: player.id, season: nil, skip: 0, gameMode: 0)
                
                // Save the player username to config for next time
                config.lastUsedPlayer = username
                config.save()
                
                // Hide loading indicator
                tuiManager.hideLoadingIndicator()
                
                // Render the player dashboard
                tuiManager.renderScreen(.playerDashboard(
                    player: player,
                    stats: stats,
                    matches: matches,
                    onRefresh: { [weak self] in
                        self?.loadPlayerDashboard(username: username)
                    },
                    onBack: { [weak self] in
                        self?.showMainMenu()
                    }
                ))
            } catch {
                tuiManager.hideLoadingIndicator()
                tuiManager.showError("Failed to load player data: \(error.localizedDescription)")
                
                // Return to main menu after a brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                    self?.showMainMenu()
                }
            }
        }
    }
    
    /// Show the hero explorer.
    private func showHeroExplorer() {
        guard let api = apiClient else {
            tuiManager.showError("API client not initialized")
            return
        }
        
        Task {
            do {
                tuiManager.showLoadingIndicator("Loading heroes...")
                
                let heroes = try await api.getAllHeroes()
                
                // Hide loading indicator
                tuiManager.hideLoadingIndicator()
                
                // Render the hero explorer
                tuiManager.renderScreen(.heroExplorer(
                    heroes: heroes,
                    onSelect: { [weak self] hero in
                        self?.showHeroDetails(hero: hero)
                    },
                    onBack: { [weak self] in
                        self?.showMainMenu()
                    }
                ))
            } catch {
                tuiManager.hideLoadingIndicator()
                tuiManager.showError("Failed to load heroes: \(error.localizedDescription)")
                
                // Return to main menu after a brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                    self?.showMainMenu()
                }
            }
        }
    }
    
    /// Show the hero details.
    private func showHeroDetails(hero: Hero) {
        guard let api = apiClient else {
            tuiManager.showError("API client not initialized")
            return
        }
        
        Task {
            do {
                tuiManager.showLoadingIndicator("Loading hero details...")
                
                // Load hero stats and leaderboard in parallel
                async let statsTask = api.getHeroStats(byQuery: hero.id)
                async let leaderboardTask = api.getHeroLeaderboard(query: hero.id, platform: "pc")
                
                let stats = try await statsTask
                let leaderboard = try await leaderboardTask
                
                // Hide loading indicator
                tuiManager.hideLoadingIndicator()
                
                // Render the hero details
                tuiManager.renderScreen(.heroDetails(
                    hero: hero,
                    stats: stats,
                    leaderboard: leaderboard,
                    onBack: { [weak self] in
                        self?.showHeroExplorer()
                    }
                ))
            } catch {
                tuiManager.hideLoadingIndicator()
                tuiManager.showError("Failed to load hero details: \(error.localizedDescription)")
                
                // Return to hero explorer after a brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                    self?.showHeroExplorer()
                }
            }
        }
    }
    
    /// Show the match analysis screen.
    private func showMatchAnalysis() {
        tuiManager.renderScreen(.matchSearch(
            onSearch: { [weak self] matchId in
                self?.loadMatchDetails(matchId: matchId)
            },
            onCancel: { [weak self] in
                self?.showMainMenu()
            }
        ))
    }
    
    /// Load match details for the given match ID.
    private func loadMatchDetails(matchId: String) {
        guard let api = apiClient else {
            tuiManager.showError("API client not initialized")
            return
        }
        
        Task {
            do {
                tuiManager.showLoadingIndicator("Loading match details...")
                
                let match = try await api.getMatch(matchUid: matchId)
                
                // Hide loading indicator
                tuiManager.hideLoadingIndicator()
                
                // Render the match details
                tuiManager.renderScreen(.matchDetails(
                    match: match,
                    onBack: { [weak self] in
                        self?.showMatchAnalysis()
                    }
                ))
            } catch {
                tuiManager.hideLoadingIndicator()
                tuiManager.showError("Failed to load match details: \(error.localizedDescription)")
                
                // Return to match search after a brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                    self?.showMatchAnalysis()
                }
            }
        }
    }
    
    /// Show the leaderboards screen.
    private func showLeaderboards() {
        guard let api = apiClient else {
            tuiManager.showError("API client not initialized")
            return
        }
        
        Task {
            do {
                tuiManager.showLoadingIndicator("Loading heroes for leaderboards...")
                
                let heroes = try await api.getAllHeroes()
                
                // Hide loading indicator
                tuiManager.hideLoadingIndicator()
                
                // Render the leaderboards selection screen
                tuiManager.renderScreen(.leaderboardSelection(
                    heroes: heroes,
                    onSelect: { [weak self] hero in
                        self?.showHeroLeaderboard(hero: hero)
                    },
                    onBack: { [weak self] in
                        self?.showMainMenu()
                    }
                ))
            } catch {
                tuiManager.hideLoadingIndicator()
                tuiManager.showError("Failed to load heroes: \(error.localizedDescription)")
                
                // Return to main menu after a brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                    self?.showMainMenu()
                }
            }
        }
    }
    
    /// Show the hero leaderboard.
    private func showHeroLeaderboard(hero: Hero) {
        guard let api = apiClient else {
            tuiManager.showError("API client not initialized")
            return
        }
        
        Task {
            do {
                tuiManager.showLoadingIndicator("Loading leaderboard...")
                
                let leaderboard = try await api.getHeroLeaderboard(query: hero.id, platform: "pc")
                
                // Hide loading indicator
                tuiManager.hideLoadingIndicator()
                
                // Render the hero leaderboard
                tuiManager.renderScreen(.heroLeaderboard(
                    hero: hero,
                    leaderboard: leaderboard,
                    onBack: { [weak self] in
                        self?.showLeaderboards()
                    }
                ))
            } catch {
                tuiManager.hideLoadingIndicator()
                tuiManager.showError("Failed to load leaderboard: \(error.localizedDescription)")
                
                // Return to leaderboards after a brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                    self?.showLeaderboards()
                }
            }
        }
    }
    
    /// Show the settings screen.
    private func showSettings() {
        tuiManager.renderScreen(.settings(
            config: config,
            onSave: { [weak self] updatedConfig in
                guard let self = self else { return }
                
                // Update the config
                self.config = updatedConfig
                self.config.save()
                
                // Update API client log level if needed
                if let api = self.apiClient as? MarvelRivalsAPI {
                    APILogger.logLevel = self.config.logLevel
                }
                
                // Show confirmation
                self.tuiManager.showNotification("Settings saved successfully.")
                
                // Return to main menu after a brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.showMainMenu()
                }
            },
            onCancel: { [weak self] in
                self?.showMainMenu()
            },
            onResetAPIKey: { [weak self] in
                guard let self = self else { return }
                
                // Clear the API key
                self.credentialManager.clearAPIKey()
                self.apiClient = nil
                
                // Show confirmation
                self.tuiManager.showNotification("API key cleared. Please restart the application.")
                
                // Shutdown the application
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.shutdown()
                    exit(0)
                }
            }
        ))
    }
    
    /// Show the help screen.
    private func showHelp() {
        tuiManager.renderScreen(.help(
            onBack: { [weak self] in
                self?.showMainMenu()
            }
        ))
    }
}

// MARK: - InputHandlerDelegate

extension RivalTrackerApp: InputHandlerDelegate {
    /// Handle keyboard input events.
    func inputHandler(_ handler: InputHandler, didReceiveKey key: Key) {
        tuiManager.handleKey(key)
    }
}