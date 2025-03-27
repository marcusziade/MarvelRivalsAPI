import Foundation
import MarvelRivalsAPI

/// Cache for API responses.
actor APICache {
    /// A cached API response.
    private struct CachedResponse<T> {
        /// The cached data.
        let data: T
        
        /// The timestamp when the data was cached.
        let timestamp: Date
        
        /// Check if the cached data is valid.
        /// - Parameter validity: The validity period in seconds.
        /// - Returns: Whether the cached data is valid.
        func isValid(validity: TimeInterval) -> Bool {
            let now = Date()
            return now.timeIntervalSince(timestamp) < validity
        }
    }
    
    /// The cache storage.
    private var cache: [String: Any] = [:]
    
    /// Get a cached response.
    /// - Parameters:
    ///   - key: The cache key.
    ///   - validity: The validity period in seconds.
    /// - Returns: The cached response, or nil if not found or expired.
    func get<T>(_ key: String, validity: TimeInterval) -> T? {
        if let cached = cache[key] as? CachedResponse<T>, cached.isValid(validity: validity) {
            return cached.data
        }
        return nil
    }
    
    /// Set a cached response.
    /// - Parameters:
    ///   - key: The cache key.
    ///   - value: The value to cache.
    func set<T>(_ key: String, value: T) {
        let cached = CachedResponse(data: value, timestamp: Date())
        cache[key] = cached
    }
    
    /// Clear the cache.
    func clear() {
        cache.removeAll()
    }
    
    /// Clear expired cache entries.
    /// - Parameter validity: The validity period in seconds.
    func clearExpired(validity: TimeInterval) {
        let keys = cache.keys
        
        for key in keys {
            if let cached = cache[key] as? CachedResponse<Any>, !cached.isValid(validity: validity) {
                cache.removeValue(forKey: key)
            }
        }
    }
}

/// Extension to add caching to the Marvel Rivals API service.
final class CachedAPIService {
    /// The underlying API service.
    private let api: MarvelRivalsAPIService
    
    /// The cache for API responses.
    private let cache = APICache()
    
    /// The validity period for cached data in seconds.
    private let cacheValidity: TimeInterval
    
    /// Initialize the cached API service.
    /// - Parameters:
    ///   - api: The underlying API service.
    ///   - cacheValidity: The validity period for cached data in seconds.
    init(api: MarvelRivalsAPIService, cacheValidity: TimeInterval = 300) {
        self.api = api
        self.cacheValidity = cacheValidity
    }
    
    /// Get all heroes with caching.
    /// - Returns: An array of heroes.
    func getAllHeroes() async throws -> [Hero] {
        if let cached: [Hero] = await cache.get("allHeroes", validity: cacheValidity) {
            return cached
        }
        
        let heroes = try await api.getAllHeroes()
        await cache.set("allHeroes", value: heroes)
        return heroes
    }
    
    /// Get a hero by query with caching.
    /// - Parameter query: The hero query.
    /// - Returns: The hero.
    func getHero(byQuery query: String) async throws -> Hero {
        let cacheKey = "hero_\(query)"
        if let cached: Hero = await cache.get(cacheKey, validity: cacheValidity) {
            return cached
        }
        
        let hero = try await api.getHero(byQuery: query)
        await cache.set(cacheKey, value: hero)
        return hero
    }
    
    /// Get hero stats by query with caching.
    /// - Parameter query: The hero query.
    /// - Returns: The hero stats.
    func getHeroStats(byQuery query: String) async throws -> HeroStats {
        let cacheKey = "heroStats_\(query)"
        if let cached: HeroStats = await cache.get(cacheKey, validity: cacheValidity) {
            return cached
        }
        
        let stats = try await api.getHeroStats(byQuery: query)
        await cache.set(cacheKey, value: stats)
        return stats
    }
    
    /// Get hero leaderboard with caching.
    /// - Parameters:
    ///   - query: The hero query.
    ///   - platform: The platform.
    /// - Returns: The hero leaderboard.
    func getHeroLeaderboard(query: String, platform: String = "pc") async throws -> HeroLeaderboard {
        let cacheKey = "heroLeaderboard_\(query)_\(platform)"
        if let cached: HeroLeaderboard = await cache.get(cacheKey, validity: cacheValidity) {
            return cached
        }
        
        let leaderboard = try await api.getHeroLeaderboard(query: query, platform: platform)
        await cache.set(cacheKey, value: leaderboard)
        return leaderboard
    }
    
    /// Find a player by username with caching.
    /// - Parameter username: The player username.
    /// - Returns: The player.
    func findPlayer(username: String) async throws -> Player {
        let cacheKey = "player_\(username)"
        if let cached: Player = await cache.get(cacheKey, validity: cacheValidity) {
            return cached
        }
        
        let player = try await api.findPlayer(username: username)
        await cache.set(cacheKey, value: player)
        return player
    }
    
    /// Get player stats with caching.
    /// - Parameters:
    ///   - query: The player query.
    ///   - season: The season.
    /// - Returns: The player stats.
    func getPlayerStats(query: String, season: Int? = nil) async throws -> PlayerStats {
        let cacheKey = "playerStats_\(query)_\(season ?? 0)"
        if let cached: PlayerStats = await cache.get(cacheKey, validity: cacheValidity) {
            return cached
        }
        
        let stats = try await api.getPlayerStats(query: query, season: season)
        await cache.set(cacheKey, value: stats)
        return stats
    }
    
    /// Get player match history with caching.
    /// - Parameters:
    ///   - query: The player query.
    ///   - season: The season.
    ///   - skip: The number of matches to skip.
    ///   - gameMode: The game mode.
    /// - Returns: The player's match history.
    func getPlayerMatchHistory(
        query: String,
        season: Int? = nil,
        skip: Int = 20,
        gameMode: Int = 0
    ) async throws -> [Match] {
        let cacheKey = "playerMatchHistory_\(query)_\(season ?? 0)_\(skip)_\(gameMode)"
        if let cached: [Match] = await cache.get(cacheKey, validity: cacheValidity) {
            return cached
        }
        
        let matches = try await api.getPlayerMatchHistory(
            query: query,
            season: season,
            skip: skip,
            gameMode: gameMode
        )
        await cache.set(cacheKey, value: matches)
        return matches
    }
    
    /// Get a match by ID with caching.
    /// - Parameter matchUid: The match UID.
    /// - Returns: The match.
    func getMatch(matchUid: String) async throws -> Match {
        let cacheKey = "match_\(matchUid)"
        if let cached: Match = await cache.get(cacheKey, validity: cacheValidity) {
            return cached
        }
        
        let match = try await api.getMatch(matchUid: matchUid)
        await cache.set(cacheKey, value: match)
        return match
    }
    
    /// Get battle pass with caching.
    /// - Parameter season: The season.
    /// - Returns: The battle pass.
    func getBattlePass(season: Int? = nil) async throws -> BattlePass {
        let cacheKey = "battlePass_\(season ?? 0)"
        if let cached: BattlePass = await cache.get(cacheKey, validity: cacheValidity) {
            return cached
        }
        
        let battlePass = try await api.getBattlePass(season: season)
        await cache.set(cacheKey, value: battlePass)
        return battlePass
    }
    
    /// Get patch notes with caching.
    /// - Parameters:
    ///   - page: The page number.
    ///   - limit: The page limit.
    /// - Returns: The patch notes.
    func getPatchNotes(page: Int = 1, limit: Int = 10) async throws -> PatchNotesResponse {
        let cacheKey = "patchNotes_\(page)_\(limit)"
        if let cached: PatchNotesResponse = await cache.get(cacheKey, validity: cacheValidity) {
            return cached
        }
        
        let patchNotes = try await api.getPatchNotes(page: page, limit: limit)
        await cache.set(cacheKey, value: patchNotes)
        return patchNotes
    }
    
    /// Clear the cache.
    func clearCache() async {
        await cache.clear()
    }
    
    /// Clear expired cache entries.
    func clearExpiredCache() async {
        await cache.clearExpired(validity: cacheValidity)
    }
}