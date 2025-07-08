//
//  NetworkClient.swift
//  SwiftNetworking
//
//  Created by Marco Longobardi on 08/07/25.
//

import Foundation

@available(iOS 13.0.0, *)
public final class NetworkProvider<ErrorType: NetworkErrorConvertible>: NetworkClientProtocol {
    private let configuration: NetworkConfiguration
    
    public init(configuration: NetworkConfiguration) {
        self.configuration = configuration
    }
    
    @available(macOS 10.15, *)
    public func send<T>(_ endpoint: Endpoint, as type: T.Type) async throws -> T where T : Decodable {
        let request = try endpoint.asURLRequest(baseURL: configuration.baseURL)
        let (data, response): (Data, URLResponse)
        
        if #available(macOS 12.0, *) {
            (data, response) = try await configuration.session.data(for: request)
        } else {
            // Fallback on earlier versions
            (data, response) = try await withCheckedThrowingContinuation { continuation in
                configuration.session.dataTask(with: request) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let data = data, let response = response {
                        continuation.resume(returning: (data, response))
                    } else {
                        continuation.resume(throwing: URLError(.badServerResponse))
                    }
                }.resume()
            }
        }
        try HTTPResponseValidator.validate(response)
        
        LogUtilities.log("RESPONSE: \(String(data: data, encoding: .utf8) ?? "Unable to decode data to string")")
        do {
            return try configuration.decoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            throw ErrorType.fromDecodingError(decodingError)
        } catch {
            throw ErrorType.unknown
        }
    }
}
