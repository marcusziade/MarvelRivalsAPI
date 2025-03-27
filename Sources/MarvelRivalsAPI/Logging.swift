import Foundation
import Logging

#if os(Linux) || os(Windows)
    import FoundationNetworking
#endif

/// A logging manager for the MarvelRivalsAPI.
public class APILogger {
    /// The global logger instance.
    internal static var logger = Logger(label: "com.marvelrivalsapi")

    /// The log level for the logger.
    public static var logLevel: Logger.Level {
        get { logger.logLevel }
        set { logger.logLevel = newValue }
    }

    /// Log a message at the trace level.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - metadata: Optional metadata to include with the log message.
    ///   - file: The file where the log message originated.
    ///   - function: The function where the log message originated.
    ///   - line: The line where the log message originated.
    internal static func trace(
        _ message: String, metadata: Logger.Metadata? = nil, file: String = #file,
        function: String = #function, line: UInt = #line
    ) {
        logger.trace(
            Logger.Message(stringLiteral: message), metadata: metadata, file: file,
            function: function, line: line)
    }

    /// Log a message at the debug level.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - metadata: Optional metadata to include with the log message.
    ///   - file: The file where the log message originated.
    ///   - function: The function where the log message originated.
    ///   - line: The line where the log message originated.
    internal static func debug(
        _ message: String, metadata: Logger.Metadata? = nil, file: String = #file,
        function: String = #function, line: UInt = #line
    ) {
        logger.debug(
            Logger.Message(stringLiteral: message), metadata: metadata, file: file,
            function: function, line: line)
    }

    /// Log a message at the info level.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - metadata: Optional metadata to include with the log message.
    ///   - file: The file where the log message originated.
    ///   - function: The function where the log message originated.
    ///   - line: The line where the log message originated.
    internal static func info(
        _ message: String, metadata: Logger.Metadata? = nil, file: String = #file,
        function: String = #function, line: UInt = #line
    ) {
        logger.info(
            Logger.Message(stringLiteral: message), metadata: metadata, file: file,
            function: function, line: line)
    }

    /// Log a message at the notice level.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - metadata: Optional metadata to include with the log message.
    ///   - file: The file where the log message originated.
    ///   - function: The function where the log message originated.
    ///   - line: The line where the log message originated.
    internal static func notice(
        _ message: String, metadata: Logger.Metadata? = nil, file: String = #file,
        function: String = #function, line: UInt = #line
    ) {
        logger.notice(
            Logger.Message(stringLiteral: message), metadata: metadata, file: file,
            function: function, line: line)
    }

    /// Log a message at the warning level.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - metadata: Optional metadata to include with the log message.
    ///   - file: The file where the log message originated.
    ///   - function: The function where the log message originated.
    ///   - line: The line where the log message originated.
    internal static func warning(
        _ message: String, metadata: Logger.Metadata? = nil, file: String = #file,
        function: String = #function, line: UInt = #line
    ) {
        logger.warning(
            Logger.Message(stringLiteral: message), metadata: metadata, file: file,
            function: function, line: line)
    }

    /// Log a message at the error level.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - metadata: Optional metadata to include with the log message.
    ///   - file: The file where the log message originated.
    ///   - function: The function where the log message originated.
    ///   - line: The line where the log message originated.
    internal static func logError(
        _ message: String, metadata: Logger.Metadata? = nil, file: String = #file,
        function: String = #function, line: UInt = #line
    ) {
        logger.error(
            Logger.Message(stringLiteral: message), metadata: metadata, file: file,
            function: function, line: line)
    }

    /// Log a message at the critical level.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - metadata: Optional metadata to include with the log message.
    ///   - file: The file where the log message originated.
    ///   - function: The function where the log message originated.
    ///   - line: The line where the log message originated.
    internal static func critical(
        _ message: String, metadata: Logger.Metadata? = nil, file: String = #file,
        function: String = #function, line: UInt = #line
    ) {
        logger.critical(
            Logger.Message(stringLiteral: message), metadata: metadata, file: file,
            function: function, line: line)
    }

    /// Log an API request.
    /// - Parameters:
    ///   - request: The request being made.
    ///   - endpoint: The endpoint being accessed.
    internal static func logRequest(_ request: URLRequest, endpoint: Endpoint) {
        var metadata: Logger.Metadata = [
            "url": .string(request.url?.absoluteString ?? "unknown"),
            "method": .string(request.httpMethod ?? "unknown"),
            "endpoint": .string("\(endpoint)"),
        ]

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            var sanitizedHeaders = headers
            sanitizedHeaders["x-api-key"] = "REDACTED"
            metadata["headers"] = .dictionary(
                sanitizedHeaders.mapValues { Logger.MetadataValue.string($0) })
        }

        debug("API Request", metadata: metadata)
    }

    /// Log an API response.
    /// - Parameters:
    ///   - data: The data received.
    ///   - response: The response metadata.
    ///   - endpoint: The endpoint that was accessed.
    internal static func logResponse(_ data: Data, _ response: URLResponse, endpoint: Endpoint) {
        guard let httpResponse = response as? HTTPURLResponse else {
            warning("Non-HTTP response received")
            return
        }

        var metadata: Logger.Metadata = [
            "url": .string(response.url?.absoluteString ?? "unknown"),
            "statusCode": .string("\(httpResponse.statusCode)"),
            "endpoint": .string("\(endpoint)"),
        ]

        if let headers = httpResponse.allHeaderFields as? [String: String], !headers.isEmpty {
            metadata["headers"] = .dictionary(headers.mapValues { Logger.MetadataValue.string($0) })
        }

        if httpResponse.statusCode >= 400 {
            let responseString =
                String(data: data, encoding: .utf8) ?? "Unable to decode response data"
            metadata["response"] = .string(responseString)
            logError("API Error Response", metadata: metadata)
        } else {
            if logger.logLevel <= .trace {
                let responseString =
                    String(data: data, encoding: .utf8) ?? "Unable to decode response data"
                metadata["response"] = .string(responseString)
            }
            debug("API Response", metadata: metadata)
        }
    }

    /// Log an error that occurred during an API request.
    /// - Parameters:
    ///   - error: The error that occurred.
    ///   - endpoint: The endpoint that was being accessed.
    internal static func logError(_ error: Error, endpoint: Endpoint) {
        let metadata: Logger.Metadata = [
            "error": .string("\(error)"),
            "endpoint": .string("\(endpoint)"),
        ]
        logError("API Error", metadata: metadata)
    }
}

