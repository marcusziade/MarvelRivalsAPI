import Foundation

/// Errors that can occur when using the MarvelRivalsAPI.
public enum APIError: Error, Equatable {
    /// The URL for the request is not valid.
    case invalidURL
    
    /// The response from the server is not valid.
    case invalidResponse
    
    /// The request was not valid (HTTP 400).
    case badRequest(String?)
    
    /// Authentication failed (HTTP 401).
    case unauthorized(String?)
    
    /// The requested resource was not found (HTTP 404).
    case notFound(String?)
    
    /// The server encountered an error (HTTP 500).
    case serverError(String?)
    
    /// Rate limit exceeded (HTTP 429).
    case rateLimitExceeded(String?)
    
    /// An unexpected status code was returned.
    case unexpectedStatusCode(Int, String?)
    
    /// Couldn't decode the response.
    case decodingError(String)
    
    /// Network error occurred.
    case networkError(Error)
    
    /// Another type of error occurred.
    case unknown(String?)
    
    // Equatable conformance
    public static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse):
            return true
        case (.badRequest(let lhsMsg), .badRequest(let rhsMsg)),
             (.unauthorized(let lhsMsg), .unauthorized(let rhsMsg)),
             (.notFound(let lhsMsg), .notFound(let rhsMsg)),
             (.serverError(let lhsMsg), .serverError(let rhsMsg)),
             (.rateLimitExceeded(let lhsMsg), .rateLimitExceeded(let rhsMsg)),
             (.unknown(let lhsMsg), .unknown(let rhsMsg)):
            return lhsMsg == rhsMsg
        case (.unexpectedStatusCode(let lhsCode, let lhsMsg), .unexpectedStatusCode(let rhsCode, let rhsMsg)):
            return lhsCode == rhsCode && lhsMsg == rhsMsg
        case (.decodingError(let lhsMsg), .decodingError(let rhsMsg)):
            return lhsMsg == rhsMsg
        case (.networkError(let lhsErr), .networkError(let rhsErr)):
            return lhsErr.localizedDescription == rhsErr.localizedDescription
        default:
            return false
        }
    }
    
    /// A human-readable description of the error.
    public var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "The URL for the request is invalid."
        case .invalidResponse:
            return "The response from the server is invalid."
        case .badRequest(let message):
            return message ?? "The request was invalid."
        case .unauthorized(let message):
            return message ?? "Authentication failed. Please check your API key."
        case .notFound(let message):
            return message ?? "The requested resource was not found."
        case .serverError(let message):
            return message ?? "The server encountered an error. Please try again later."
        case .rateLimitExceeded(let message):
            return message ?? "Rate limit exceeded. Please try again later."
        case .unexpectedStatusCode(let code, let message):
            return message ?? "Unexpected status code: \(code)"
        case .decodingError(let message):
            return "Failed to decode the response: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknown(let message):
            return message ?? "An unknown error occurred."
        }
    }
}

/// Represents an error response from the Marvel Rivals API.
public struct APIErrorResponse: Decodable {
    /// The error message returned by the API.
    public let message: String?
    
    /// The error code returned by the API.
    public let statusCode: Int?
    
    /// The error type returned by the API.
    public let error: String?
}