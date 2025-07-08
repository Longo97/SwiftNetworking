//
//  Endpoint.swift
//  SwiftNetworking
//
//  Created by Marco Longobardi on 08/07/25.
//

import Foundation

public struct Endpoint {
    public let path: String
    public let method: HTTPMethod
    public let query: [URLQueryItem]?
    public let headers: [String:String]?
    public let body: Encodable?
    
    public init(path: String,
                method: HTTPMethod = .get,
                query: [URLQueryItem]? = nil,
                headers: [String: String]? = nil,
                body: Encodable? = nil) {
        self.path = path
        self.method = method
        self.query = query
        self.headers = headers
        self.body = body
    }
    
    public func asURLRequest(baseURL: URL) throws -> URLRequest {
        var components: URLComponents? = nil
        if #available(iOS 16.0, *) {
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
            LogUtilities.log("URL non valido: \(url)")
            throw DefaultNetworkError.cannotBuildURL
        }
        
        var request = URLRequest(url: url)
        LogUtilities.log("Request URL: \(method.rawValue) \(url.absoluteString)")
        request.httpMethod = method.rawValue
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let data = request.httpBody {
                LogUtilities.log("Body: \n \(String(data: data, encoding: .utf8) ?? "Unable to convert body to string")")
            }
        }
        headers?.forEach({ request.setValue($0.value, forHTTPHeaderField: $0.key)})
        return request
    }
}
