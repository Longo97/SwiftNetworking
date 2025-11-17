//
//  NetworkClientProtocol.swift
//  SwiftNetworking
//
//  Created by Marco Longobardi on 08/07/25.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@available(iOS 13.0.0,macOS 10.15, *)
internal protocol NetworkClientProtocol {
    func send<T: Decodable>(
        _ endpoint: Endpoint,
        as type: T.Type) async throws -> T
    
    func fetch<T: Decodable>(
        _ endpoint: Endpoint,
        result: @escaping (Result<T, Error>) -> (Void))
}
