import Foundation

/// A protocol defining methods to interact with the Marvel Rivals API.
///
/// This protocol provides interfaces to fetch data from the Marvel Rivals API, including
/// heroes, players, matches, battle passes, and other game content.
public protocol MarvelRivalsAPIService {
    // MARK: - Hero Endpoints
    
    /// Get all heroes.
    /// - Returns: An array of heroes.
    /// - Throws: An error if the request fails.
    func getAllHeroes() async throws -> [Hero]
    
    /// Get a specific hero by name or ID.
    /// - Parameter query: The hero name or ID.
    /// - Returns: The hero details.
    /// - Throws: An error if the request fails.
    func getHero(byQuery query: String) async throws -> Hero
    
    /// Get the stats for a specific hero.
    /// - Parameter query: The hero name or ID.
    /// - Returns: The hero stats.
    /// - Throws: An error if the request fails.
    func getHeroStats(byQuery query: String) async throws -> HeroStats
    
    /// Get the leaderboard for a specific hero.
    /// - Parameters:
    ///   - query: The hero name or ID.
    ///   - platform: The platform to get the leaderboard for. Default is "pc".
    /// - Returns: The hero leaderboard.
    /// - Throws: An error if the request fails.
    func getHeroLeaderboard(query: String, platform: String) async throws -> HeroLeaderboard
    
    /// Get the costumes for a specific hero.
    /// - Parameter query: The hero name or ID.
    /// - Returns: An array of hero costumes.
    /// - Throws: An error if the request fails.
    func getHeroCostumes(query: String) async throws -> [HeroCostume]
    
    /// Get a specific costume for a hero.
    /// - Parameters:
    ///   - heroQuery: The hero name or ID.
    ///   - costumeQuery: The costume name or ID.
    /// - Returns: The hero costume details.
    /// - Throws: An error if the request fails.
    func getHeroCostume(heroQuery: String, costumeQuery: String) async throws -> HeroCostume
    
    // MARK: - Player Endpoints
    
    /// Find a player by username.
    /// - Parameter username: The player's username.
    /// - Returns: The player details.
    /// - Throws: An error if the request fails.
    func findPlayer(username: String) async throws -> Player
    
    /// Get a player's stats.
    /// - Parameters:
    ///   - query: The player's ID or username.
    ///   - season: Optional season to filter stats by.
    /// - Returns: The player's stats.
    /// - Throws: An error if the request fails.
    func getPlayerStats(query: String, season: Int?) async throws -> PlayerStats
    
    /// Get a player's match history.
    /// - Parameters:
    ///   - query: The player's ID or username.
    ///   - season: Optional season to filter matches by.
    ///   - skip: Number of matches to skip. Default is 20.
    ///   - gameMode: Game mode to filter matches by. Default is 0 (all modes).
    /// - Returns: An array of matches.
    /// - Throws: An error if the request fails.
    func getPlayerMatchHistory(query: String, season: Int?, skip: Int, gameMode: Int) async throws -> [Match]
    
    /// Update a player's data.
    /// - Parameter query: The player's ID or username.
    /// - Returns: The updated player details.
    /// - Throws: An error if the request fails.
    func updatePlayer(query: String) async throws -> Player
    
    // MARK: - Content Endpoints
    
    /// Get battle pass information.
    /// - Parameter season: Optional season number.
    /// - Returns: The battle pass details.
    /// - Throws: An error if the request fails.
    func getBattlePass(season: Int?) async throws -> BattlePass
    
    /// Get dev diary entries.
    /// - Parameters:
    ///   - page: The page number. Default is 1.
    ///   - limit: The number of entries per page. Default is 10.
    /// - Returns: The dev diary response.
    /// - Throws: An error if the request fails.
    func getDevDiaries(page: Int, limit: Int) async throws -> DevDiariesResponse
    
    /// Get a specific dev diary entry.
    /// - Parameter id: The dev diary ID.
    /// - Returns: The dev diary details.
    /// - Throws: An error if the request fails.
    func getDevDiary(id: String) async throws -> DevDiary
    
    /// Get items.
    /// - Parameters:
    ///   - type: Optional item type filter.
    ///   - page: The page number. Default is 1.
    ///   - limit: The number of items per page. Default is 10.
    /// - Returns: The items response.
    /// - Throws: An error if the request fails.
    func getItems(type: String?, page: Int, limit: Int) async throws -> ItemsResponse
    
    /// Get a specific item.
    /// - Parameter query: The item name or ID.
    /// - Returns: The item details.
    /// - Throws: An error if the request fails.
    func getItem(query: String) async throws -> ItemsResponse.Item
    
    /// Get maps.
    /// - Parameters:
    ///   - page: The page number. Default is 1.
    ///   - limit: The number of maps per page. Default is 10.
    /// - Returns: The maps response.
    /// - Throws: An error if the request fails.
    func getMaps(page: Int, limit: Int) async throws -> MapsResponse
    
    /// Get a specific match.
    /// - Parameter matchUid: The match UID.
    /// - Returns: The match details.
    /// - Throws: An error if the request fails.
    func getMatch(matchUid: String) async throws -> Match
    
    /// Get patch notes.
    /// - Parameters:
    ///   - page: The page number. Default is 1.
    ///   - limit: The number of patch notes per page. Default is 10.
    /// - Returns: The patch notes response.
    /// - Throws: An error if the request fails.
    func getPatchNotes(page: Int, limit: Int) async throws -> PatchNotesResponse
    
    /// Get a specific patch note.
    /// - Parameter id: The patch note ID.
    /// - Returns: The patch note details.
    /// - Throws: An error if the request fails.
    func getPatchNote(id: String) async throws -> PatchNote
}