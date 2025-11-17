//
//  HTTPResponseValidator.swift
//  SwiftNetworking
//
//  Created by Marco Longobardi on 08/07/25.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

internal enum HTTPResponseValidator {
    internal static func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw DefaultNetworkError.invalidHTTPResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw DefaultNetworkError.statusCode(http.statusCode)
        }
    }
}
