import Foundation

/// Manages the terminal user interface (TUI) for the application.
final class TUIManager {
    // MARK: - Properties
    
    /// The current screen being displayed.
    private var currentScreen: Screen?
    
    /// The terminal size.
    private var terminalSize: TerminalSize
    
    /// Flag indicating if the application is in raw mode.
    private var isInRawMode = false
    
    /// The renderer for terminal output.
    private let renderer: TerminalRenderer
    
    // MARK: - Initialization
    
    /// Initialize the TUI manager.
    init() {
        self.terminalSize = Terminal.size()
        self.renderer = TerminalRenderer()
        
        // Set up terminal resize handling
        setupResizeHandler()
    }
    
    // MARK: - Terminal Setup
    
    /// Set up the terminal resize handler.
    private func setupResizeHandler() {
        Signal.trap(signal: .winch) { [weak self] _ in
            guard let self = self else { return }
            
            // Update terminal size
            self.terminalSize = Terminal.size()
            
            // Re-render the current screen
            if let screen = self.currentScreen {
                self.renderScreen(screen)
            }
        }
    }
    
    /// Enter raw mode for terminal input.
    func enterRawMode() {
        if !isInRawMode {
            Terminal.enterRawMode()
            isInRawMode = true
        }
    }
    
    /// Exit raw mode for terminal input.
    func exitRawMode() {
        if isInRawMode {
            Terminal.exitRawMode()
            isInRawMode = false
        }
    }
    
    /// Clear the screen.
    func clearScreen() {
        renderer.clearScreen()
    }
    
    /// Set the cursor visibility.
    /// - Parameter visible: Whether the cursor should be visible.
    func setCursorVisible(_ visible: Bool) {
        renderer.setCursorVisible(visible)
    }
    
    // MARK: - Screen Rendering
    
    /// Render a screen.
    /// - Parameter screen: The screen to render.
    func renderScreen(_ screen: Screen) {
        // Store the current screen
        currentScreen = screen
        
        // Clear the screen
        clearScreen()
        
        // Create a screen context
        let context = ScreenContext(
            terminalSize: terminalSize,
            renderer: renderer
        )
        
        // Render the screen
        var mutableScreen = screen
        mutableScreen.render(in: context)
    }
    
    /// Show an error message.
    /// - Parameter message: The error message to show.
    func showError(_ message: String) {
        renderer.renderAt(row: terminalSize.rows - 2, column: 0) {
            renderer.setForegroundColor(.red)
            renderer.write("Error: \(message)")
            renderer.resetColors()
        }
    }
    
    /// Show a notification message.
    /// - Parameter message: The notification message to show.
    func showNotification(_ message: String) {
        renderer.renderAt(row: terminalSize.rows - 2, column: 0) {
            renderer.setForegroundColor(.green)
            renderer.write("✓ \(message)")
            renderer.resetColors()
        }
    }
    
    /// Show a loading indicator.
    /// - Parameter message: The loading message to show.
    func showLoadingIndicator(_ message: String) {
        Task {
            for symbol in ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"] {
                renderer.renderAt(row: terminalSize.rows - 2, column: 0) {
                    renderer.setForegroundColor(.cyan)
                    renderer.write("\(symbol) \(message)")
                    renderer.resetColors()
                }
                
                try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
                
                // Check if the task has been cancelled
                if Task.isCancelled {
                    break
                }
            }
        }
    }
    
    /// Hide the loading indicator.
    func hideLoadingIndicator() {
        renderer.renderAt(row: terminalSize.rows - 2, column: 0) {
            renderer.clearLine()
        }
    }
    
    // MARK: - Input Handling
    
    /// Handle a key press.
    /// - Parameter key: The key that was pressed.
    func handleKey(_ key: Key) {
        guard var screen = currentScreen else {
            return
        }
        
        // Pass the key to the current screen
        screen.handleKey(key)
        
        // Update the current screen
        currentScreen = screen
        
        // Re-render the screen
        renderScreen(screen)
    }
}