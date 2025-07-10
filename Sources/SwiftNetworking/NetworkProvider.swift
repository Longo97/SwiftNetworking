//
//  NetworkClient.swift
//  SwiftNetworking
//
//  Created by Marco Longobardi on 08/07/25.
//

import Foundation

/// # NetworkProvider
/// A generic, asynchronous network client that sends requests using `URLSession` and decodes responses into strongly-typed models.
///
/// `NetworkProvider` supports:
/// - Custom decoding error mapping via a user-defined `NetworkErrorConvertible`
/// - Asynchronous networking with backward compatibility to macOS 10.15 / iOS 13
/// - Customizable configuration including base URL, session, and decoder
///
/// ## Generics
/// - `ErrorType`: A type conforming to `NetworkErrorConvertible`, used to map decoding and unknown errors into app-specific error cases.
///
/// ## Initialization
/// Create an instance by providing a `NetworkConfiguration`:
///
/// ```swift
/// let config = NetworkConfiguration(baseURL: URL(string: "https://api.example.com")!)
/// let provider = NetworkProvider<MyCustomError>(configuration: config)
/// ```
///
/// ## Conforms to
/// - `NetworkClientProtocol`
///
/// ## Usage
/// Use the `send(_:as:)` method to make a network request and decode the response:
///
/// ```swift
/// struct Response: Decodable {
///     let message: String
/// }
///
/// let endpoint = Endpoint(path: "/hello", method: .get)
/// let response: Response = try await provider.send(endpoint, as: Response.self)
/// print(response.message)
/// ```
///
/// ## Error Handling
/// - If the server returns an invalid status code, `HTTPResponseValidator` throws a validation error.
/// - If decoding fails, the error is mapped using `ErrorType.fromDecodingError(_:)`.
/// - Any unknown errors are mapped to `ErrorType.unknown`.
@available(iOS 13.0.0, *)
public final class NetworkProvider<ErrorType: NetworkErrorConvertible>: NetworkClientProtocol {
    private let configuration: NetworkConfiguration
    private let responseCache = ResponseCache()

    /// Initializes the `NetworkProvider` with a given network configuration.
    ///
    /// - Parameter configuration: The configuration that includes base URL, session, and decoder.
    public init(configuration: NetworkConfiguration) {
        self.configuration = configuration
    }

    /// Sends a request to the provided `Endpoint` and decodes the response into the expected type.
    ///
    /// - Parameters:
    ///   - endpoint: The `Endpoint` describing the path, method, headers, query, and body.
    ///   - type: The expected `Decodable` type for the response.
    /// - Returns: A decoded object of type `T`.
    /// - Throws:
    ///   - A `URLError` if networking fails.
    ///   - An error thrown by `HTTPResponseValidator` if status code is invalid.
    ///   - A mapped decoding error using `ErrorType.fromDecodingError`.
    ///   - `ErrorType.unknown` for unexpected decoding failures.
    @available(macOS 10.15, *)
    public func send<T>(_ endpoint: Endpoint, as type: T.Type) async throws -> T where T: Decodable {
        let request = try endpoint.asURLRequest(baseURL: configuration.baseURL)
        
        /// 1. Cache
        if case let .enabled(ttl) = endpoint.cachePolicy,
           let data = responseCache.get(for: request, ttl: ttl) {
            LogUtilities.log("📦 Using cached response")
            return try configuration.decoder.decode(T.self, from: data)
        }
        
        /// 2. Network call
        let (data, response): (Data, URLResponse)

        if #available(macOS 12.0, *) {
            (data, response) = try await configuration.session.data(for: request)
        } else {
            // Fallback for macOS < 12
            (data, response) = try await withCheckedThrowingContinuation { continuation in
                configuration.session.dataTask(with: request) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let data = data, let response = response {
                        continuation.resume(returning: (data, response))
                    } else {
                        continuation.resume(throwing: URLError(.badServerResponse))
                    }
                }.resume()
            }
        }

        try HTTPResponseValidator.validate(response)

        LogUtilities.log("RESPONSE: \(String(data: data, encoding: .utf8) ?? "Unable to decode data to string")")
        
        if case .enabled = endpoint.cachePolicy,
           let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode == 200 {
            responseCache.set(data, for: request)
            LogUtilities.log("💾 Cached response")
        }

        do {
            return try configuration.decoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            throw ErrorType.fromDecodingError(decodingError)
        } catch {
            throw ErrorType.unknown
        }
    }
}
