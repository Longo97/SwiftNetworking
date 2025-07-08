//
//  HTTPResponseValidator.swift
//  SwiftNetworking
//
//  Created by Marco Longobardi on 08/07/25.
//

import Foundation

public enum HTTPResponseValidator {
    public static func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw DefaultNetworkError.invalidHTTPResponse
        }
        LogUtilities.log("RESPONSE CODE: \(http.statusCode)")
        guard (200..<300).contains(http.statusCode) else {
            throw DefaultNetworkError.statusCode(http.statusCode)
        }
    }
}
