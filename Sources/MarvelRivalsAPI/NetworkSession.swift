import Foundation

#if os(Linux) || os(Windows)
import FoundationNetworking
#endif

/// A protocol defining the networking capability required by MarvelRivalsAPI.
///
/// This protocol specifies the minimal interface needed to fetch data from URLs,
/// allowing for dependency injection of different networking implementations.
public protocol NetworkSession {
    /// Asynchronously fetches data from a URL.
    /// - Parameter request: The URLRequest to use for the data task.
    /// - Returns: A tuple containing the data and response.
    /// - Throws: An error if the request fails.
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

// Make URLSession conform to NetworkSession
extension URLSession: NetworkSession {
    /// Explicitly bridge the existing data(for:) method to satisfy the protocol
    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request, delegate: nil)
    }
}