//
//  NetworkErrorConvertible.swift
//  SwiftNetworking
//
//  Created by Marco Longobardi on 08/07/25.
//

public protocol NetworkErrorConvertible: Error {
    static func fromStatusCode(_ code: Int) -> Self
    static func fromDecodingError(_ error: DecodingError) -> Self
    static var invalidResponse: Self { get }
    static var unknown: Self { get }
}
