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
