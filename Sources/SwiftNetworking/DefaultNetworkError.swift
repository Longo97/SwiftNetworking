//
//  DefaultNetworkError.swift
//  SwiftNetworking
//
//  Created by Marco Longobardi on 08/07/25.
//

public enum DefaultNetworkError: NetworkErrorConvertible {
    case invalidHTTPResponse
    case cannotBuildURL
    case statusCode(Int)
    case decoding(DecodingError)
    case genericUnknown
    
    public static func fromStatusCode(_ code: Int) -> DefaultNetworkError {
        .statusCode(code)
    }
    
    public static func fromDecodingError(_ error: DecodingError) -> DefaultNetworkError {
        .decoding(error)
    }
    
    public static var invalidResponse: Self {
        .invalidHTTPResponse
    }
    public static var unknown: Self {
        .genericUnknown
    }
}

extension DefaultNetworkError: Equatable {
    public static func == (lhs: DefaultNetworkError, rhs: DefaultNetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidHTTPResponse, .invalidHTTPResponse),
             (.cannotBuildURL, .cannotBuildURL),
             (.genericUnknown, .genericUnknown):
            return true
        case let (.statusCode(a), .statusCode(b)):
            return a == b
        case (.decoding, .decoding):
            // Non possiamo confrontare DecodingError, quindi li trattiamo come uguali tra loro
            return true
        default:
            return false
        }
    }
}
