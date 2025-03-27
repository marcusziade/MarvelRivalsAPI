#if os(Linux) || os(Windows)
    import FoundationNetworking
    import Foundation
#else
    import Foundation
#endif
import Logging

/// Main client for the Marvel Rivals API.
///
/// This class provides access to the Marvel Rivals API endpoints and handles
/// authentication, network requests, and response parsing.
///
/// Usage:
/// ```swift
/// let api = MarvelRivalsAPI(apiKey: "your-api-key")
///
/// // Get all heroes
/// do {
///     let heroes = try await api.getAllHeroes()
///     print(heroes)
/// } catch {
///     print("Error: \(error)")
/// }
///
/// // Get specific hero stats
/// do {
///     let stats = try await api.getHeroStats(byQuery: "ironman")
///     print(stats)
/// } catch {
///     print("Error: \(error)")
/// }
/// ```
public final class MarvelRivalsAPI: MarvelRivalsAPIService {
    /// The base URL for the Marvel Rivals API.
    private let baseURL: String
    
    /// The API key used for authentication.
    private let apiKey: String
    
    /// The network session used for making requests.
    private let session: NetworkSession
    
    /// The JSON decoder used for parsing responses.
    private let decoder: JSONDecoder
    
    /// Creates a new instance of the Marvel Rivals API client.
    /// - Parameters:
    ///   - apiKey: Your Marvel Rivals API key.
    ///   - baseURL: The base URL for the API. Defaults to "https://marvelrivalsapi.com/api/v1".
    ///   - session: The network session to use for requests. Defaults to URLSession.shared.
    ///   - logLevel: The log level for API requests and responses. Defaults to .info.
    public init(
        apiKey: String,
        baseURL: String = "https://marvelrivalsapi.com/api/v1",
        session: NetworkSession = URLSession.shared,
        logLevel: Logger.Level = .info
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.session = session
        self.decoder = JSONDecoder()
        
        // Set up decoder with date formatting
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        // Configure logging
        APILogger.logLevel = logLevel
    }
    
    /// Makes a request to the API and decodes the response.
    /// - Parameter endpoint: The endpoint to request.
    /// - Returns: The decoded response.
    /// - Throws: An `APIError` if the request fails or the response can't be decoded.
    internal func makeRequest<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let url = endpoint.buildURL(with: baseURL) else {
            APILogger.logError("Invalid URL for endpoint: \(endpoint)")
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        APILogger.logRequest(request, endpoint: endpoint)
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
            APILogger.logResponse(data, response, endpoint: endpoint)
        } catch {
            APILogger.logError(error, endpoint: endpoint)
            throw APIError.networkError(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            APILogger.logError("Invalid response type for endpoint: \(endpoint)")
            throw APIError.invalidResponse
        }
        
        // Process HTTP status code
        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decodedResponse = try decoder.decode(T.self, from: data)
                return decodedResponse
            } catch {
                APILogger.logError("Decoding error for endpoint \(endpoint): \(error.localizedDescription)")
                throw APIError.decodingError(error.localizedDescription)
            }
        default:
            // Try to decode the error response
            let errorMessage = try? decoder.decode(APIErrorResponse.self, from: data)
            
            switch httpResponse.statusCode {
            case 400:
                throw APIError.badRequest(errorMessage?.message)
            case 401:
                throw APIError.unauthorized(errorMessage?.message)
            case 404:
                throw APIError.notFound(errorMessage?.message)
            case 429:
                throw APIError.rateLimitExceeded(errorMessage?.message)
            case 500...599:
                throw APIError.serverError(errorMessage?.message)
            default:
                throw APIError.unexpectedStatusCode(httpResponse.statusCode, errorMessage?.message)
            }
        }
    }
    
    // MARK: - Hero Endpoints
    
    /// Get all heroes.
    /// - Returns: An array of heroes.
    /// - Throws: An error if the request fails.
    public func getAllHeroes() async throws -> [Hero] {
        return try await makeRequest(.heroes)
    }
    
    /// Get a specific hero by name or ID.
    /// - Parameter query: The hero name or ID.
    /// - Returns: The hero details.
    /// - Throws: An error if the request fails.
    public func getHero(byQuery query: String) async throws -> Hero {
        return try await makeRequest(.hero(query: query))
    }
    
    /// Get the stats for a specific hero.
    /// - Parameter query: The hero name or ID.
    /// - Returns: The hero stats.
    /// - Throws: An error if the request fails.
    public func getHeroStats(byQuery query: String) async throws -> HeroStats {
        return try await makeRequest(.heroStats(query: query))
    }
    
    /// Get the leaderboard for a specific hero.
    /// - Parameters:
    ///   - query: The hero name or ID.
    ///   - platform: The platform to get the leaderboard for. Default is "pc".
    /// - Returns: The hero leaderboard.
    /// - Throws: An error if the request fails.
    public func getHeroLeaderboard(query: String, platform: String = "pc") async throws -> HeroLeaderboard {
        return try await makeRequest(.heroLeaderboard(query: query, platform: platform))
    }
    
    /// Get the costumes for a specific hero.
    /// - Parameter query: The hero name or ID.
    /// - Returns: An array of hero costumes.
    /// - Throws: An error if the request fails.
    public func getHeroCostumes(query: String) async throws -> [HeroCostume] {
        return try await makeRequest(.heroCostumes(query: query))
    }
    
    /// Get a specific costume for a hero.
    /// - Parameters:
    ///   - heroQuery: The hero name or ID.
    ///   - costumeQuery: The costume name or ID.
    /// - Returns: The hero costume details.
    /// - Throws: An error if the request fails.
    public func getHeroCostume(heroQuery: String, costumeQuery: String) async throws -> HeroCostume {
        return try await makeRequest(.heroCostume(heroQuery: heroQuery, costumeQuery: costumeQuery))
    }
    
    // MARK: - Player Endpoints
    
    /// Find a player by username.
    /// - Parameter username: The player's username.
    /// - Returns: The player details.
    /// - Throws: An error if the request fails.
    public func findPlayer(username: String) async throws -> Player {
        return try await makeRequest(.findPlayer(username: username))
    }
    
    /// Get a player's stats.
    /// - Parameters:
    ///   - query: The player's ID or username.
    ///   - season: Optional season to filter stats by.
    /// - Returns: The player's stats.
    /// - Throws: An error if the request fails.
    public func getPlayerStats(query: String, season: Int? = nil) async throws -> PlayerStats {
        return try await makeRequest(.playerStats(query: query, season: season))
    }
    
    /// Get a player's match history.
    /// - Parameters:
    ///   - query: The player's ID or username.
    ///   - season: Optional season to filter matches by.
    ///   - skip: Number of matches to skip. Default is 20.
    ///   - gameMode: Game mode to filter matches by. Default is 0 (all modes).
    /// - Returns: An array of matches.
    /// - Throws: An error if the request fails.
    public func getPlayerMatchHistory(
        query: String, 
        season: Int? = nil, 
        skip: Int = 20, 
        gameMode: Int = 0
    ) async throws -> [Match] {
        return try await makeRequest(.playerMatchHistory(
            query: query, 
            season: season, 
            skip: skip, 
            gameMode: gameMode
        ))
    }
    
    /// Update a player's data.
    /// - Parameter query: The player's ID or username.
    /// - Returns: The updated player details.
    /// - Throws: An error if the request fails.
    public func updatePlayer(query: String) async throws -> Player {
        return try await makeRequest(.updatePlayer(query: query))
    }
    
    // MARK: - Content Endpoints
    
    /// Get battle pass information.
    /// - Parameter season: Optional season number.
    /// - Returns: The battle pass details.
    /// - Throws: An error if the request fails.
    public func getBattlePass(season: Int? = nil) async throws -> BattlePass {
        return try await makeRequest(.battlePass(season: season))
    }
    
    /// Get dev diary entries.
    /// - Parameters:
    ///   - page: The page number. Default is 1.
    ///   - limit: The number of entries per page. Default is 10.
    /// - Returns: The dev diary response.
    /// - Throws: An error if the request fails.
    public func getDevDiaries(page: Int = 1, limit: Int = 10) async throws -> DevDiariesResponse {
        return try await makeRequest(.devDiaries(page: page, limit: limit))
    }
    
    /// Get a specific dev diary entry.
    /// - Parameter id: The dev diary ID.
    /// - Returns: The dev diary details.
    /// - Throws: An error if the request fails.
    public func getDevDiary(id: String) async throws -> DevDiary {
        return try await makeRequest(.devDiary(id: id))
    }
    
    /// Get items.
    /// - Parameters:
    ///   - type: Optional item type filter.
    ///   - page: The page number. Default is 1.
    ///   - limit: The number of items per page. Default is 10.
    /// - Returns: The items response.
    /// - Throws: An error if the request fails.
    public func getItems(type: String? = nil, page: Int = 1, limit: Int = 10) async throws -> ItemsResponse {
        return try await makeRequest(.items(type: type, page: page, limit: limit))
    }
    
    /// Get a specific item.
    /// - Parameter query: The item name or ID.
    /// - Returns: The item details.
    /// - Throws: An error if the request fails.
    public func getItem(query: String) async throws -> ItemsResponse.Item {
        return try await makeRequest(.item(query: query))
    }
    
    /// Get maps.
    /// - Parameters:
    ///   - page: The page number. Default is 1.
    ///   - limit: The number of maps per page. Default is 10.
    /// - Returns: The maps response.
    /// - Throws: An error if the request fails.
    public func getMaps(page: Int = 1, limit: Int = 10) async throws -> MapsResponse {
        return try await makeRequest(.maps(page: page, limit: limit))
    }
    
    /// Get a specific match.
    /// - Parameter matchUid: The match UID.
    /// - Returns: The match details.
    /// - Throws: An error if the request fails.
    public func getMatch(matchUid: String) async throws -> Match {
        return try await makeRequest(.match(matchUid: matchUid))
    }
    
    /// Get patch notes.
    /// - Parameters:
    ///   - page: The page number. Default is 1.
    ///   - limit: The number of patch notes per page. Default is 10.
    /// - Returns: The patch notes response.
    /// - Throws: An error if the request fails.
    public func getPatchNotes(page: Int = 1, limit: Int = 10) async throws -> PatchNotesResponse {
        return try await makeRequest(.patchNotes(page: page, limit: limit))
    }
    
    /// Get a specific patch note.
    /// - Parameter id: The patch note ID.
    /// - Returns: The patch note details.
    /// - Throws: An error if the request fails.
    public func getPatchNote(id: String) async throws -> PatchNote {
        return try await makeRequest(.patchNote(id: id))
    }
}