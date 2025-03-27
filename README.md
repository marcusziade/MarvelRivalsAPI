# Marvel Rivals API

A Swift Package SDK for the Marvel Rivals API. This package provides a type-safe way to interact with the Marvel Rivals API, with robust error handling, logging, and comprehensive test coverage.

## Features

- ✅ Full API coverage for all Marvel Rivals endpoints
- ✅ Swift concurrency support with async/await
- ✅ Comprehensive error handling
- ✅ Detailed logging with configurable log levels
- ✅ Protocol-based architecture for easy testing
- ✅ Extensive documentation

## Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Swift 5.5+

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift` file:

```swift
.package(url: "https://github.com/yourusername/MarvelRivalsAPI.git", from: "1.0.0")
```

Or add it through Xcode:
1. Go to File > Swift Packages > Add Package Dependency
2. Enter the package URL: `https://github.com/yourusername/MarvelRivalsAPI.git`
3. Select the version you want to use

## Usage

### Initialization

```swift
import MarvelRivalsAPI

// Initialize with just an API key
let api = MarvelRivalsAPI(apiKey: "your-api-key")

// Or with custom configuration
let api = MarvelRivalsAPI(
    apiKey: "your-api-key",
    baseURL: "https://marvelrivalsapi.com/api/v1", // Default value shown for clarity
    logLevel: .debug // Enable debug logging
)
```

### Basic Examples

#### Get All Heroes

```swift
do {
    let heroes = try await api.getAllHeroes()
    print("Found \(heroes.count) heroes")
    heroes.forEach { hero in
        print("Hero: \(hero.name), Role: \(hero.role)")
    }
} catch {
    print("Error fetching heroes: \(error)")
}
```

#### Get Hero Details

```swift
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
```

#### Get Battle Pass Information

```swift
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
```

### Error Handling

The SDK provides detailed error information through the `APIError` enum:

```swift
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
```

### Advanced Usage

See the `Examples.swift` file for more advanced usage examples, including:
- Concurrent requests
- Custom network sessions
- Pagination
- Logging configuration

## API Documentation

### Heroes

```swift
// Get all heroes
func getAllHeroes() async throws -> [Hero]

// Get a specific hero by name or ID
func getHero(byQuery query: String) async throws -> Hero

// Get the stats for a specific hero
func getHeroStats(byQuery query: String) async throws -> HeroStats

// Get the leaderboard for a specific hero
func getHeroLeaderboard(query: String, platform: String = "pc") async throws -> HeroLeaderboard

// Get the costumes for a specific hero
func getHeroCostumes(query: String) async throws -> [HeroCostume]

// Get a specific costume for a hero
func getHeroCostume(heroQuery: String, costumeQuery: String) async throws -> HeroCostume
```

### Players

```swift
// Find a player by username
func findPlayer(username: String) async throws -> Player

// Get a player's stats
func getPlayerStats(query: String, season: Int? = nil) async throws -> PlayerStats

// Get a player's match history
func getPlayerMatchHistory(query: String, season: Int? = nil, skip: Int = 20, gameMode: Int = 0) async throws -> [Match]

// Update a player's data
func updatePlayer(query: String) async throws -> Player
```

### Battle Pass and Game Content

```swift
// Get battle pass information
func getBattlePass(season: Int? = nil) async throws -> BattlePass

// Get dev diary entries
func getDevDiaries(page: Int = 1, limit: Int = 10) async throws -> DevDiariesResponse

// Get a specific dev diary entry
func getDevDiary(id: String) async throws -> DevDiary

// Get items
func getItems(type: String? = nil, page: Int = 1, limit: Int = 10) async throws -> ItemsResponse

// Get a specific item
func getItem(query: String) async throws -> ItemsResponse.Item

// Get maps
func getMaps(page: Int = 1, limit: Int = 10) async throws -> MapsResponse

// Get a specific match
func getMatch(matchUid: String) async throws -> Match

// Get patch notes
func getPatchNotes(page: Int = 1, limit: Int = 10) async throws -> PatchNotesResponse

// Get a specific patch note
func getPatchNote(id: String) async throws -> PatchNote
```

## Testing

The SDK includes comprehensive unit tests using mock network sessions. Run tests using:

```bash
swift test
```

Or through Xcode's Test Navigator.

## License

This project is available under the MIT license. See the LICENSE file for more info.