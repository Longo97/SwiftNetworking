//
//  NetworkClientProtocol.swift
//  SwiftNetworking
//
//  Created by Marco Longobardi on 08/07/25.
//

import Foundation

@available(iOS 13.0.0,macOS 10.15, *)
public protocol NetworkClientProtocol {
    func send<T: Decodable>(
        _ endpoint: Endpoint,
        as type: T.Type) async throws -> T
}
