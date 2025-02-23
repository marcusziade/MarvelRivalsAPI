import Foundation

extension MarvelRivalsAPI {
    /// Battle Pass
    public func getBattlePass(season: Int? = nil) async throws -> BattlePass {
        try await makeRequest(.battlePass(season: season))
    }

    /// Dev Diaries
    public func getDevDiaries(page: Int = 1, limit: Int = 10) async throws -> DevDiariesResponse {
        try await makeRequest(.devDiaries(page: page, limit: limit))
    }

    public func getDevDiary(id: String) async throws -> DevDiary {
        try await makeRequest(.devDiary(id: id))
    }

    /// Heroes (additional endpoints)
    public func getHeroLeaderboard(query: String, platform: String = "pc") async throws
        -> HeroLeaderboard
    {
        try await makeRequest(.heroLeaderboard(query: query, platform: platform))
    }

    public func getHeroCostumes(query: String) async throws -> [HeroCostume] {
        try await makeRequest(.heroCostumes(query: query))
    }

    public func getHeroCostume(heroQuery: String, costumeQuery: String) async throws -> HeroCostume
    {
        try await makeRequest(.heroCostume(heroQuery: heroQuery, costumeQuery: costumeQuery))
    }

    /// Items
    public func getItems(type: String? = nil, page: Int = 1, limit: Int = 10) async throws
        -> ItemsResponse
    {
        try await makeRequest(.items(type: type, page: page, limit: limit))
    }

    public func getItem(query: String) async throws -> ItemsResponse.Item {
        try await makeRequest(.item(query: query))
    }

    /// Maps
    public func getMaps(page: Int = 1, limit: Int = 10) async throws -> MapsResponse {
        try await makeRequest(.maps(page: page, limit: limit))
    }

    /// Match History
    public func getMatch(matchUid: String) async throws -> Match {
        try await makeRequest(.match(matchUid: matchUid))
    }

    public func getPlayerMatchHistory(
        query: String, season: Int? = nil, skip: Int = 20, gameMode: Int = 0
    ) async throws -> [Match] {
        try await makeRequest(
            .playerMatchHistory(query: query, season: season, skip: skip, gameMode: gameMode))
    }

    /// Patch Notes
    public func getPatchNotes(page: Int = 1, limit: Int = 10) async throws -> PatchNotesResponse {
        try await makeRequest(.patchNotes(page: page, limit: limit))
    }

    public func getPatchNote(id: String) async throws -> PatchNote {
        try await makeRequest(.patchNote(id: id))
    }
}
