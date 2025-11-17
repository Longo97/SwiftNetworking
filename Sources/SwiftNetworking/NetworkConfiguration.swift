//
//  NetworkConfiguration.swift
//  SwiftNetworking
//
//  Created by Marco Longobardi on 08/07/25.
//
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Configuration container for network requests.
///
/// Holds the base URL, JSON decoder, and URL session used by the networking layer.
///
/// # Properties
/// - `baseURL`: The base URL for all network requests.
/// - `decoder`: The JSON decoder used to decode response data. Defaults to `JSONDecoder()`.
/// - `session`: The URL session used to perform network tasks. Defaults to `.shared`.
///
/// # Usage Example
/// ```swift
/// let config = NetworkConfiguration(
///     baseURL: URL(string: "https://api.example.com")!,
///     decoder: JSONDecoder(),
///     session: URLSession(configuration: .default)
/// )
/// ```
///
/// # Default Configuration
/// A default static configuration is provided for convenience, with base URL
/// `"https://example.com"`, default JSON decoder, and shared URL session.
/// This initializer returns `nil` if the URL is invalid.
public struct NetworkConfiguration {
    /// The base URL used for network requests.
    public let baseURL: URL
    
    /// The JSON decoder used to decode network responses.
    public let decoder: JSONDecoder
    
    /// The URL session used to execute network requests.
    public let session: URLSession
    
    /// A default network configuration instance with base URL "https://example.com",
    /// default JSON decoder, and shared URL session.
    ///
    /// Returns `nil` if the default base URL string is invalid.
    public static var `default`: NetworkConfiguration? {
        guard let url = URL(string: "https://example.com") else {
            return nil
        }
        return .init(baseURL: url, decoder: JSONDecoder(), session: .shared)
    }
    
    /// Creates a new `NetworkConfiguration`.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for all requests.
    ///   - decoder: The JSON decoder to use for decoding responses (default is `JSONDecoder()`).
    ///   - session: The URL session to use for network tasks (default is `.shared`).
    public init(baseURL: URL, decoder: JSONDecoder = .init(), session: URLSession = .shared) {
        self.baseURL = baseURL
        self.decoder = decoder
        self.session = session
    }
}
