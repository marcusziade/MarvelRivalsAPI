import Foundation

enum Endpoint {
    // Existing endpoints
    case heroes
    case hero(query: String)
    case heroStats(query: String)
    case findPlayer(username: String)
    case playerStats(query: String, season: Int?)
    case updatePlayer(query: String)

    // New endpoints
    case battlePass(season: Int?)
    case devDiaries(page: Int, limit: Int)
    case devDiary(id: String)
    case heroLeaderboard(query: String, platform: String)
    case heroCostumes(query: String)
    case heroCostume(heroQuery: String, costumeQuery: String)
    case items(type: String?, page: Int, limit: Int)
    case item(query: String)
    case maps(page: Int, limit: Int)
    case match(matchUid: String)
    case playerMatchHistory(query: String, season: Int?, skip: Int, gameMode: Int)
    case patchNotes(page: Int, limit: Int)
    case patchNote(id: String)

    var path: String {
        switch self {
        // Existing paths
        case .heroes:
            return "/heroes"
        case .hero(let query):
            return "/heroes/hero/\(query)"
        case .heroStats(let query):
            return "/heroes/hero/\(query)/stats"
        case .findPlayer(let username):
            return "/find-player/\(username)"
        case .playerStats(let query, _):
            return "/player/\(query)"
        case .updatePlayer(let query):
            return "/player/\(query)/update"

        // New paths
        case .battlePass:
            return "/battlepass"
        case .devDiaries:
            return "/dev-diaries"
        case .devDiary(let id):
            return "/dev-diary/\(id)"
        case .heroLeaderboard(let query, _):
            return "/heroes/leaderboard/\(query)"
        case .heroCostumes(let query):
            return "/heroes/hero/\(query)/costumes"
        case .heroCostume(let heroQuery, let costumeQuery):
            return "/heroes/hero/\(heroQuery)/costume/\(costumeQuery)"
        case .items:
            return "/items"
        case .item(let query):
            return "/item/\(query)"
        case .maps:
            return "/maps"
        case .match(let matchUid):
            return "/match/\(matchUid)"
        case .playerMatchHistory(let query, _, _, _):
            return "/player/\(query)/match-history"
        case .patchNotes:
            return "/patch-notes"
        case .patchNote(let id):
            return "/patch-note/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .updatePlayer:
            return .post
        default:
            return .get
        }
    }

    var queryItems: [URLQueryItem]? {
        var items: [URLQueryItem] = []

        switch self {
        case .battlePass(let season):
            if let season = season {
                items.append(URLQueryItem(name: "season", value: String(season)))
            }
        case .devDiaries(let page, let limit):
            items.append(URLQueryItem(name: "page", value: String(page)))
            items.append(URLQueryItem(name: "limit", value: String(limit)))
        case .heroLeaderboard(_, let platform):
            items.append(URLQueryItem(name: "platform", value: platform))
        case .items(let type, let page, let limit):
            if let type = type {
                items.append(URLQueryItem(name: "type", value: type))
            }
            items.append(URLQueryItem(name: "page", value: String(page)))
            items.append(URLQueryItem(name: "limit", value: String(limit)))
        case .maps(let page, let limit):
            items.append(URLQueryItem(name: "page", value: String(page)))
            items.append(URLQueryItem(name: "limit", value: String(limit)))
        case .playerMatchHistory(_, let season, let skip, let gameMode):
            if let season = season {
                items.append(URLQueryItem(name: "season", value: String(season)))
            }
            items.append(URLQueryItem(name: "skip", value: String(skip)))
            items.append(URLQueryItem(name: "game_mode", value: String(gameMode)))
        case .patchNotes(let page, let limit):
            items.append(URLQueryItem(name: "page", value: String(page)))
            items.append(URLQueryItem(name: "limit", value: String(limit)))
        default:
            return nil
        }

        return items.isEmpty ? nil : items
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case badRequest
    case unauthorized
    case notFound
    case serverError
    case unknown
}
