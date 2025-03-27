import XCTest
import Logging
@testable import MarvelRivalsAPI

final class MarvelRivalsAPITests: XCTestCase {
    var client: MarvelRivalsAPI!
    var mockSession: MockNetworkSession!
    
    override func setUp() {
        super.setUp()
        mockSession = MockNetworkSession()
        client = MarvelRivalsAPI(
            apiKey: "test-api-key",
            baseURL: "https://marvelrivalsapi.com/api/v1",
            session: mockSession,
            logLevel: .critical // Minimize logging in tests
        )
    }
    
    override func tearDown() {
        client = nil
        mockSession = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    func validateRequest(path: String, method: String = "GET") {
        XCTAssertNotNil(mockSession.lastRequest)
        XCTAssertEqual(mockSession.lastRequest?.httpMethod, method)
        XCTAssertTrue(mockSession.lastRequest?.url?.absoluteString.contains(path) ?? false)
        XCTAssertEqual(mockSession.lastRequest?.value(forHTTPHeaderField: "x-api-key"), "test-api-key")
    }
    
    // MARK: - Test Cases
    
    func testGetAllHeroes() async throws {
        // Setup
        mockSession.data = mockHeroesResponse
        mockSession.response = mockSuccessResponse
        
        // Execute
        let heroes = try await client.getAllHeroes()
        
        // Verify
        validateRequest(path: "/heroes")
        XCTAssertEqual(heroes.count, 1)
        XCTAssertEqual(heroes.first?.name, "Iron Man")
        XCTAssertEqual(heroes.first?.role, "Damage")
        XCTAssertEqual(heroes.first?.abilities.first?.name, "Repulsor Blast")
    }
    
    func testGetHeroStats() async throws {
        // Setup
        mockSession.data = mockHeroStatsResponse
        mockSession.response = mockSuccessResponse
        
        // Execute
        let stats = try await client.getHeroStats(byQuery: "ironman")
        
        // Verify
        validateRequest(path: "/heroes/hero/ironman/stats")
        XCTAssertEqual(stats.heroName, "Iron Man")
        XCTAssertEqual(stats.pickRate, 15.5)
        XCTAssertEqual(stats.counters.first?.heroName, "Captain America")
    }
    
    func testGetBattlePass() async throws {
        // Setup
        mockSession.data = mockBattlePassResponse
        mockSession.response = mockSuccessResponse
        
        // Execute
        let battlePass = try await client.getBattlePass(season: 1)
        
        // Verify
        validateRequest(path: "/battlepass")
        XCTAssertEqual(battlePass.season, 1)
        XCTAssertEqual(battlePass.seasonName, "Cosmic Arrival")
        XCTAssertEqual(battlePass.items.first?.name, "Iron Man Cosmic Skin")
        XCTAssertTrue(battlePass.items.first?.isLuxury ?? false)
    }
    
    func testUnauthorizedError() async {
        // Setup
        mockSession.data = mockErrorResponse
        mockSession.response = mockUnauthorizedResponse
        
        // Execute and verify
        do {
            _ = try await client.getAllHeroes()
            XCTFail("Expected error but got success")
        } catch let error as APIError {
            switch error {
            case .unauthorized(let message):
                XCTAssertEqual(message, "API key is invalid")
            default:
                XCTFail("Expected unauthorized error but got \(error)")
            }
        } catch {
            XCTFail("Expected APIError but got \(error)")
        }
    }
    
    func testNetworkError() async {
        // Setup
        mockSession.error = MockError.networkError
        
        // Execute and verify
        do {
            _ = try await client.getAllHeroes()
            XCTFail("Expected error but got success")
        } catch let error as APIError {
            switch error {
            case .networkError:
                // Success
                break
            default:
                XCTFail("Expected network error but got \(error)")
            }
        } catch {
            XCTFail("Expected APIError but got \(error)")
        }
    }
    
    func testURLConstruction() async {
        // Setup
        mockSession.data = mockHeroesResponse
        mockSession.response = mockSuccessResponse
        
        // Execute
        _ = try? await client.getHeroLeaderboard(query: "ironman", platform: "pc")
        
        // Verify
        XCTAssertNotNil(mockSession.lastRequest?.url)
        let urlString = mockSession.lastRequest?.url?.absoluteString ?? ""
        XCTAssertTrue(urlString.contains("/heroes/leaderboard/ironman"))
        XCTAssertTrue(urlString.contains("platform=pc"))
    }
    
    // Additional test cases for edge cases
    
    func testInvalidURL() async {
        // Setup - create client with invalid URL
        client = MarvelRivalsAPI(
            apiKey: "test-api-key",
            baseURL: "ht tp://invalid-url",
            session: mockSession
        )
        
        // Execute and verify
        do {
            _ = try await client.getAllHeroes()
            XCTFail("Expected error but got success")
        } catch let error as APIError {
            switch error {
            case .invalidURL:
                // Success
                break
            default:
                XCTFail("Expected invalidURL error but got \(error)")
            }
        } catch {
            XCTFail("Expected APIError but got \(error)")
        }
    }
    
    func testDecodingError() async {
        // Setup - provide invalid JSON
        mockSession.data = "This is not valid JSON".data(using: .utf8)
        mockSession.response = mockSuccessResponse
        
        // Execute and verify
        do {
            _ = try await client.getAllHeroes()
            XCTFail("Expected error but got success")
        } catch let error as APIError {
            switch error {
            case .decodingError:
                // Success
                break
            default:
                XCTFail("Expected decodingError error but got \(error)")
            }
        } catch {
            XCTFail("Expected APIError but got \(error)")
        }
    }
}

// MARK: - API Error Tests

final class APIErrorTests: XCTestCase {
    func testAPIErrorEquality() {
        XCTAssertEqual(APIError.invalidURL, APIError.invalidURL)
        XCTAssertEqual(APIError.badRequest("Error"), APIError.badRequest("Error"))
        XCTAssertNotEqual(APIError.badRequest("Error"), APIError.badRequest("Different"))
        XCTAssertNotEqual(APIError.badRequest("Error"), APIError.notFound("Error"))
    }
    
    func testAPIErrorDescription() {
        XCTAssertFalse(APIError.invalidURL.localizedDescription.isEmpty)
        XCTAssertFalse(APIError.badRequest("Custom message").localizedDescription.isEmpty)
        XCTAssertTrue(APIError.badRequest("Custom message").localizedDescription.contains("Custom message"))
    }
}