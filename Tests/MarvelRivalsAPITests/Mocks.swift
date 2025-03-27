import Foundation
import XCTest
@testable import MarvelRivalsAPI

#if os(Linux) || os(Windows)
import FoundationNetworking
#endif

/// A mock implementation of `NetworkSession` for testing.
final class MockNetworkSession: NetworkSession {
    /// The response data to return.
    var data: Data?
    
    /// The response object to return.
    var response: HTTPURLResponse?
    
    /// The error to throw.
    var error: Error?
    
    /// The last request made through this session.
    var lastRequest: URLRequest?
    
    /// Creates a new mock network session.
    init() {}
    
    /// Mock implementation of `data(for:)` that returns predefined data or errors.
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        lastRequest = request
        
        if let error = error {
            throw error
        }
        
        let defaultResponse = HTTPURLResponse(
            url: request.url ?? URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        return (data ?? Data(), response ?? defaultResponse)
    }
}

/// Test error for mock network session.
enum MockError: Error {
    case networkError
    case serverError
}

/// Sample hero response for testing.
let mockHeroesResponse = """
[
    {
        "id": "1",
        "name": "Iron Man",
        "role": "Damage",
        "difficulty": 2,
        "description": "Genius billionaire with advanced armor.",
        "abilities": [
            {
                "name": "Repulsor Blast",
                "description": "Fire repulsor beams at enemies.",
                "cooldown": "5s",
                "icon": "repulsor.png",
                "video": "repulsor.mp4"
            }
        ],
        "image": "ironman.png",
        "backstory": "Tony Stark became Iron Man after being captured."
    }
]
""".data(using: .utf8)!

/// Sample hero stats response for testing.
let mockHeroStatsResponse = """
{
    "heroId": "1",
    "heroName": "Iron Man",
    "pickRate": 15.5,
    "winRate": 52.3,
    "banRate": 5.2,
    "role": "Damage",
    "tierRating": "A",
    "playStyle": ["Ranged", "Mobile"],
    "counters": [
        {
            "heroId": "2",
            "heroName": "Captain America",
            "reason": "Shield blocks repulsors",
            "icon": "cap.png"
        }
    ],
    "strongAgainst": [
        {
            "heroId": "3",
            "heroName": "Loki",
            "reason": "Can track invisibility",
            "icon": "loki.png"
        }
    ]
}
""".data(using: .utf8)!

/// Sample battle pass response for testing.
let mockBattlePassResponse = """
{
    "season": 1,
    "seasonName": "Cosmic Arrival",
    "items": [
        {
            "name": "Iron Man Cosmic Skin",
            "image": "ironman_cosmic.png",
            "cost": "1000",
            "isLuxury": true
        }
    ]
}
""".data(using: .utf8)!

/// Sample error response for testing.
let mockErrorResponse = """
{
    "message": "API key is invalid",
    "statusCode": 401,
    "error": "Unauthorized"
}
""".data(using: .utf8)!

/// An error HTTP response
let mockUnauthorizedResponse = HTTPURLResponse(
    url: URL(string: "https://marvelrivalsapi.com/api/v1/heroes")!,
    statusCode: 401,
    httpVersion: nil,
    headerFields: nil
)!

/// A success HTTP response
let mockSuccessResponse = HTTPURLResponse(
    url: URL(string: "https://marvelrivalsapi.com/api/v1/heroes")!,
    statusCode: 200,
    httpVersion: nil,
    headerFields: nil
)!