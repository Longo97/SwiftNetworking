//
//  Endpoint.swift
//  SwiftNetworking
//
//  Created by Marco Longobardi on 08/07/25.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Represents a REST API endpoint, encapsulating the URL path, HTTP method,
/// query parameters, headers, and optional body data.
///
/// This struct simplifies the creation of `URLRequest` objects by
/// constructing the full URL and encoding the request body if provided.
///
/// # Properties
/// - `path`: The URL path component appended to the base URL.
/// - `method`: The HTTP method to use (e.g., GET, POST). Defaults to `.get`.
/// - `query`: Optional query parameters as an array of `URLQueryItem`.
/// - `headers`: Optional HTTP headers as a dictionary `[String: String]`.
/// - `body`: Optional request body conforming to `Encodable`.
/// - `cachePolicy`: Policy to enable cache. Default to `.disabled`
/// - `verbose`: Controls whether request/response logs should be printed. Default to `false`
///
/// # Usage Example
/// ```swift
/// let endpoint = Endpoint(
///     path: "/teams",
///     method: .post,
///     query: [URLQueryItem(name: "season", value: "2024")],
///     headers: ["Authorization": "Bearer TOKEN"],
///     body: Team(name: "Napoli", year: 1926),
///     cachePolicy: .enabled(ttl: 60),
///     verbose: true
/// )
/// ```
///
/// # Errors
/// Throws `DefaultNetworkError.cannotBuildURL` if the composed URL is invalid.
public struct Endpoint {
    /// The path component appended to the base URL.
    public let path: String
    
    /// The HTTP method used for the request.
    public let method: HTTPMethod
    
    /// Query parameters included in the URL.
    public let query: [URLQueryItem]?
    
    /// HTTP headers included in the request.
    public let headers: [String:String]?
    
    /// The body payload encoded as JSON, if provided.
    public let body: Encodable?
    
    /// The policy for cache usage, if not set the cache is disabled
    public var cachePolicy: CachePolicy = .disabled
        
    /// Controls whether request/response logs should be printed.
    public var verbose: Bool = false
    
    /// Creates a new `Endpoint` instance.
    ///
    /// - Parameters:
    ///   - path: The URL path component (e.g., "/teams").
    ///   - method: The HTTP method to use (default is `.get`).
    ///   - query: Optional query parameters to append to the URL.
    ///   - headers: Optional HTTP headers to include in the request.
    ///   - body: Optional request body conforming to `Encodable`.
    ///   - cachePolicy: Optional cache policy to set cache usage.
    ///   - verbose: Boolean to set network logs
    public init(path: String,
                method: HTTPMethod = .get,
                query: [URLQueryItem]? = nil,
                headers: [String: String]? = nil,
                body: Encodable? = nil,
                cachePolicy: CachePolicy = .disabled,
                verbose: Bool = false) {
        self.path = path
        self.method = method
        self.query = query
        self.headers = headers
        self.body = body
        self.cachePolicy = cachePolicy
        self.verbose = verbose
    }
    
    /// Constructs a `URLRequest` from the endpoint and a base URL.
    ///
    /// - Parameter baseURL: The base URL to which the endpoint path and query are appended.
    /// - Returns: A configured `URLRequest` with method, headers, and body set.
    /// - Throws: `DefaultNetworkError.cannotBuildURL` if URL construction fails.
    internal func asURLRequest(baseURL: URL) throws -> URLRequest {
        var components: URLComponents? = nil
        if #available(iOS 16.0, macOS 13.0, *) {
            components = URLComponents(url: baseURL.appending(path: path),
                                       resolvingAgainstBaseURL: false)
        } else {
            components = URLComponents(url: baseURL.appendingPathComponent(path),
                                       resolvingAgainstBaseURL: false)
        }
        
        components?.queryItems = query
        
        guard let components = components, let url = components.url else {
            throw DefaultNetworkError.cannotBuildURL
        }
        
        guard let scheme = url.scheme, let host = url.host, !scheme.isEmpty, !host.isEmpty else {
            LogUtilities.log("Invalid URL: \(url)")
            throw DefaultNetworkError.cannotBuildURL
        }
        
        var request = URLRequest(url: url)
        if verbose {
            LogUtilities.log("Request URL: \(method.rawValue) \(url.absoluteString)")
        }
        request.httpMethod = method.rawValue
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let data = request.httpBody, verbose {
                LogUtilities.log("Body: \n\(String(data: data, encoding: .utf8) ?? "Unable to convert body to string")")
            }
        }
        
        headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        return request
    }
}
