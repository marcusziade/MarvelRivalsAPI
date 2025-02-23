#if os(Linux) || os(Windows)
    import FoundationNetworking
    import Foundation
#else
    import Foundation
#endif

/*
let api = MarvelRivalsAPI(apiKey: "your-api-key")

// Get all heroes
do {
    let heroes = try await api.getAllHeroes()
    print(heroes)
} catch {
    print("Error: \(error)")
}

// Get specific hero stats
do {
    let stats = try await api.getHeroStats(byQuery: "ironman")
    print(stats)
} catch {
    print("Error: \(error)")
}

let api = MarvelRivalsAPI(apiKey: "your-api-key")

// Get battle pass info
let battlePass = try await api.getBattlePass(season: 1)

// Get dev diaries
let devDiaries = try await api.getDevDiaries(page: 1, limit: 10)

// Get hero costumes
let costumes = try await api.getHeroCostumes(query: "ironman")

// Get maps
let maps = try await api.getMaps()
*/
public class MarvelRivalsAPI {
    private let baseURL = "https://marvelrivalsapi.com/api/v1"
    private let apiKey: String
    private let session: URLSession

    public init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    func makeRequest<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        var urlComponents = URLComponents(string: baseURL + endpoint.path)
        urlComponents?.queryItems = endpoint.queryItems

        guard let url = urlComponents?.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            return try JSONDecoder().decode(T.self, from: data)
        case 400:
            throw APIError.badRequest
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        case 500:
            throw APIError.serverError
        default:
            throw APIError.unknown
        }
    }
}
