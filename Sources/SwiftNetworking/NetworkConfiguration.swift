//
//  NetworkConfiguration.swift
//  SwiftNetworking
//
//  Created by Marco Longobardi on 08/07/25.
//
import Foundation

public struct NetworkConfiguration {
    public let baseURL: URL
    public let decoder: JSONDecoder
    public let session: URLSession
    
    public static var `default`: NetworkConfiguration? {
        guard let url = URL(string: "https://example.com") else {
            return nil
        }
        return .init(baseURL: url, decoder: JSONDecoder(), session: .shared)
    }
    
    public init(baseURL: URL, decoder: JSONDecoder = .init(), session: URLSession = .shared) {
        self.baseURL = baseURL
        self.decoder = decoder
        self.session = session
    }
}
