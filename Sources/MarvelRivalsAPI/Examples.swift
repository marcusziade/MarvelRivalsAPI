import Foundation

/// This file provides examples of how to use the MarvelRivalsAPI SDK.
/// - Note: This is not part of the public API and is only used for documentation.

// MARK: - Basic Usage

/**
 ```swift
 import MarvelRivalsAPI
 
 // Initialize the API client with your API key
 let api = MarvelRivalsAPI(apiKey: "your-api-key")
 
 // Example 1: Get all heroes
 Task {
     do {
         let heroes = try await api.getAllHeroes()
         print("Found \(heroes.count) heroes")
         heroes.forEach { hero in
             print("Hero: \(hero.name), Role: \(hero.role)")
         }
     } catch {
         print("Error fetching heroes: \(error)")
     }
 }
 
 // Example 2: Get hero details
 Task {
     do {
         let ironMan = try await api.getHero(byQuery: "ironman")
         print("Name: \(ironMan.name)")
         print("Role: \(ironMan.role)")
         print("Abilities:")
         ironMan.abilities.forEach { ability in
             print("- \(ability.name): \(ability.description)")
         }
     } catch {
         print("Error fetching hero: \(error)")
     }
 }
 
 // Example 3: Get battle pass information
 Task {
     do {
         let battlePass = try await api.getBattlePass(season: 1)
         print("Season \(battlePass.season): \(battlePass.seasonName)")
         print("Items:")
         battlePass.items.forEach { item in
             let type = item.isLuxury ? "Luxury" : "Standard"
             print("- \(item.name) (\(type)): Cost \(item.cost)")
         }
     } catch {
         print("Error fetching battle pass: \(error)")
     }
 }
 
 // Example 4: Find player and get stats
 Task {
     do {
         let player = try await api.findPlayer(username: "ProGamer123")
         print("Found player: \(player.username), Level: \(player.level)")
         
         let stats = try await api.getPlayerStats(query: player.id)
         print("Win Rate: \(stats.seasonStats.winRate)%")
         print("Top Heroes:")
         stats.heroStats.sorted(by: { $0.winRate > $1.winRate }).prefix(3).forEach { hero in
             print("- \(hero.heroName): \(hero.winRate)% win rate over \(hero.matchesPlayed) matches")
         }
     } catch {
         print("Error finding player: \(error)")
     }
 }
 
 // Example 5: Error handling
 Task {
     do {
         let hero = try await api.getHero(byQuery: "nonexistentHero")
         print("Hero: \(hero.name)")
     } catch let error as APIError {
         switch error {
         case .notFound(let message):
             print("Hero not found. \(message ?? "")")
         case .unauthorized(let message):
             print("Authentication failed. \(message ?? "Please check your API key.")")
         case .networkError(let underlyingError):
             print("Network error: \(underlyingError.localizedDescription)")
         default:
             print("Other error: \(error.localizedDescription)")
         }
     } catch {
         print("Unexpected error: \(error)")
     }
 }
 ```
 */

// MARK: - Advanced Usage

/**
 ```swift
 import MarvelRivalsAPI
 import Logging
 
 // Configure logging
 LoggingSystem.bootstrap { label in
     var logger = StreamLogHandler.standardOutput(label: label)
     logger.logLevel = .debug
     return logger
 }
 
 // Initialize with custom configuration
 let api = MarvelRivalsAPI(
     apiKey: "your-api-key",
     baseURL: "https://marvelrivalsapi.com/api/v1", // Default value shown for clarity
     session: URLSession.shared, // Default value shown for clarity
     logLevel: .debug // Enable debug logging for API requests and responses
 )
 
 // Example 6: Custom URLSession
 let config = URLSessionConfiguration.default
 config.timeoutIntervalForRequest = 30 // Set a 30 second timeout
 let customSession = URLSession(configuration: config)
 
 let apiWithCustomSession = MarvelRivalsAPI(
     apiKey: "your-api-key",
     session: customSession
 )
 
 // Example 7: Mock session for testing or demo purposes
 class MyMockSession: NetworkSession {
     func data(for request: URLRequest) async throws -> (Data, URLResponse) {
         // Return mock data based on the request
         if request.url?.path.contains("/heroes") == true {
             let mockData = """
             [{"id":"1","name":"Iron Man","role":"Damage","difficulty":2,"description":"...","abilities":[],"image":"","backstory":""}]
             """.data(using: .utf8)!
             let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
             return (mockData, response)
         }
         throw NSError(domain: "MyMockError", code: 404)
     }
 }
 
 let mockApi = MarvelRivalsAPI(
     apiKey: "test-key",
     session: MyMockSession()
 )
 
 Task {
     let heroes = try? await mockApi.getAllHeroes()
     print("Mock heroes: \(heroes?.first?.name ?? "none")")
 }
 
 // Example 8: Pagination for listings
 Task {
     do {
         // Get first page of items
         let page1 = try await api.getItems(type: "Weapon", page: 1, limit: 10)
         print("Total items: \(page1.totalItems)")
         print("Page 1 items:")
         page1.items.forEach { item in
             print("- \(item.name)")
         }
         
         // If there are more items, get the second page
         if page1.totalItems > 10 {
             let page2 = try await api.getItems(type: "Weapon", page: 2, limit: 10)
             print("Page 2 items:")
             page2.items.forEach { item in
                 print("- \(item.name)")
             }
         }
     } catch {
         print("Error fetching items: \(error)")
     }
 }
 
 // Example 9: Concurrent requests
 Task {
     do {
         async let heroesTask = api.getAllHeroes()
         async let mapsTask = api.getMaps()
         async let battlePassTask = api.getBattlePass()
         
         let (heroes, maps, battlePass) = try await (heroesTask, mapsTask, battlePassTask)
         
         print("Loaded \(heroes.count) heroes, \(maps.maps.count) maps, and \(battlePass.items.count) battle pass items")
     } catch {
         print("Error with concurrent requests: \(error)")
     }
 }
 ```
 */