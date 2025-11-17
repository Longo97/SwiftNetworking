//
//  NetworkProviderTests.swift
//  SwiftNetworking
//
//  Created by Marco Longobardi on 09/07/25.
//

import XCTest
@testable import SwiftNetworking
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// # NetworkProviderTests
/// Unit tests for `NetworkProvider`, which handles sending network requests and decoding responses.
///
/// These tests use a custom `MockURLProtocol` to intercept and simulate network behavior.
/// Tested scenarios include:
/// - Successful decoding of valid JSON
/// - Throwing errors when network issues occur
/// - Proper error propagation when receiving invalid status codes
///
/// ## Test Cases
final class NetworkProviderTests: XCTestCase {
    
    /// Registers the mock URL protocol before any test is run.
    override class func setUp() {
        super.setUp()
        URLProtocol.registerClass(MockURLProtocol.self)
    }
    
    /// Unregisters the mock URL protocol after all tests are complete.
    override class func tearDown() {
        URLProtocol.unregisterClass(MockURLProtocol.self)
        super.tearDown()
    }
    
    /// ## testSuccessfulDecoding
    /// Tests that the `NetworkProvider` correctly decodes a valid JSON response into a Decodable model.
    ///
    /// The test ensures:
    /// - The mocked JSON is returned and decoded properly.
    /// - The decoded value matches the expected model.
    func testSuccessfulDecoding() async throws {
        let json = """
        {
          "message": "Hello world"
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.stubResponseData = json
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let baseURL = URL(string: "https://api.example.com")!
        let network = NetworkProvider<DefaultNetworkError>(
            configuration: .init(baseURL: baseURL, session: session)
        )
        
        let endpoint = Endpoint(path: "/greeting", method: .get)
        
        struct Response: Decodable {
            let message: String
        }
        
        let result: Response = try await network.send(endpoint, as: Response.self)
        XCTAssertEqual(result.message, "Hello world")
    }
    
    /// ## testNetworkErrorIsThrown
    /// Simulates a network connectivity issue and verifies that the appropriate `URLError` is thrown.
    ///
    /// The test ensures:
    /// - A `URLError` is thrown when the network is unavailable.
    /// - The error has the expected `.notConnectedToInternet` code.
    func testNetworkErrorIsThrown() async throws {
        MockURLProtocol.error = URLError(.notConnectedToInternet)
        
        defer {
            MockURLProtocol.stubResponseData = nil
            MockURLProtocol.error = nil
            MockURLProtocol.responseStatusCode = 200
        }
        
        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: sessionConfig)
        
        let config = NetworkConfiguration(baseURL: URL(string: "http://example.com")!, session: session)
        let provider = NetworkProvider<DefaultNetworkError>(configuration: config)
        
        struct Response: Decodable { let value: String }
        
        do {
            _ = try await provider.send(.init(path: "/test", method: .get), as: Response.self)
            XCTFail("Expected network error")
        } catch let error as URLError {
            XCTAssertEqual(error.code, .notConnectedToInternet)
        }
    }
    
    /// ## testInvalidStatusCodeThrows
    /// Simulates an HTTP 500 response and checks that the proper `DefaultNetworkError.statusCode` is thrown.
    ///
    /// The test ensures:
    /// - A decoding attempt is made with an empty response body.
    /// - A `.statusCode(500)` error is returned from the `NetworkProvider`.
    func testInvalidStatusCodeThrows() async throws {
        let json = Data()
        MockURLProtocol.stubResponseData = json
        MockURLProtocol.responseStatusCode = 500
        
        defer {
            MockURLProtocol.stubResponseData = nil
            MockURLProtocol.error = nil
            MockURLProtocol.responseStatusCode = 200
        }
        
        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: sessionConfig)
        
        let config = NetworkConfiguration(baseURL: URL(string: "http://example.com")!, session: session)
        let provider = NetworkProvider<DefaultNetworkError>(configuration: config)
        
        struct Response: Decodable { let value: String }
        
        do {
            _ = try await provider.send(.init(path: "/test", method: .get), as: Response.self)
            XCTFail("Expected validation error")
        } catch let error as DefaultNetworkError {
            XCTAssertEqual(error, .statusCode(500))
        }
    }
    
    /// ## testFetchReadsLocalJSONAndDecodes
    /// Tests that the `NetworkProvider` correctly decodes a valid JSON response into a Decodable model.
    ///
    /// The test ensures:
    /// - The mocked JSON is returned and decoded properly.
    /// - The decoded value matches the expected model.
    func testFetchReadsLocalJSONAndDecodes() throws {
            let config = URLSessionConfiguration.ephemeral
            config.protocolClasses = [MockURLProtocol.self]
            let session = URLSession(configuration: config)
            
            let baseURL = URL(string: "https://api.example.com")!
            let network = NetworkProvider<DefaultNetworkError>(
                configuration: .init(baseURL: baseURL, session: session)
            )
            
            let jsonData = """
            {
                "id": 1,
                "name": "Alice"
            }
            """.data(using: .utf8)!

            MockURLProtocol.stubResponseData = jsonData

            let exp = expectation(description: "Decoding JSON")
        
            struct User: Decodable {
                let id: Int
                let name: String
            }

            network.fetch(Endpoint(path: "/user")) { (result: Result<User, Error>) in
                switch result {
                case .success(let user):
                    XCTAssertEqual(user.id, 1)
                    XCTAssertEqual(user.name, "Alice")
                case .failure(let error):
                    XCTFail("Expected success, got \(error)")
                }
                exp.fulfill()
            }

            wait(for: [exp], timeout: 1.0)
        }
    
    /// ## testFetchWithCacheEnabled
    /// Tests that the `fetch` method correctly uses cached responses when cache is enabled.
    func testFetchWithCacheEnabled() throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let baseURL = URL(string: "https://api.example.com")!
        let network = NetworkProvider<DefaultNetworkError>(
            configuration: .init(baseURL: baseURL, session: session)
        )
        
        let jsonData = """
        {
            "value": "cached"
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.stubResponseData = jsonData
        
        struct Response: Decodable {
            let value: String
        }
        
        let exp1 = expectation(description: "First request")
        
        // First request should hit the network
        network.fetch(Endpoint(path: "/cached", cachePolicy: .enabled(ttl: 60))) { (result: Result<Response, Error>) in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.value, "cached")
            case .failure(let error):
                XCTFail("Expected success, got \(error)")
            }
            exp1.fulfill()
        }
        
        wait(for: [exp1], timeout: 1.0)
        
        // Change the mock response
        let newJsonData = """
        {
            "value": "new"
        }
        """.data(using: .utf8)!
        MockURLProtocol.stubResponseData = newJsonData
        
        let exp2 = expectation(description: "Second request")
        
        // Second request should use cache and return the old value
        network.fetch(Endpoint(path: "/cached", cachePolicy: .enabled(ttl: 60))) { (result: Result<Response, Error>) in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.value, "cached", "Should return cached value, not new value")
            case .failure(let error):
                XCTFail("Expected success, got \(error)")
            }
            exp2.fulfill()
        }
        
        wait(for: [exp2], timeout: 1.0)
    }
    
    /// ## testFetchWithCustomDecoder
    /// Tests that the `fetch` method uses the configured decoder.
    func testFetchWithCustomDecoder() throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let baseURL = URL(string: "https://api.example.com")!
        let network = NetworkProvider<DefaultNetworkError>(
            configuration: .init(baseURL: baseURL, decoder: decoder, session: session)
        )
        
        let jsonData = """
        {
            "user_name": "TestUser"
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.stubResponseData = jsonData
        
        struct User: Decodable {
            let userName: String
        }
        
        let exp = expectation(description: "Decoding with custom decoder")
        
        network.fetch(Endpoint(path: "/user")) { (result: Result<User, Error>) in
            switch result {
            case .success(let user):
                XCTAssertEqual(user.userName, "TestUser")
            case .failure(let error):
                XCTFail("Expected success, got \(error)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    /// ## testFetchHandlesDecodingError
    /// Tests that the `fetch` method properly handles and maps decoding errors.
    func testFetchHandlesDecodingError() throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let baseURL = URL(string: "https://api.example.com")!
        let network = NetworkProvider<DefaultNetworkError>(
            configuration: .init(baseURL: baseURL, session: session)
        )
        
        // Invalid JSON that doesn't match the model
        let jsonData = """
        {
            "unexpected": "data"
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.stubResponseData = jsonData
        
        struct User: Decodable {
            let id: Int
            let name: String
        }
        
        let exp = expectation(description: "Handle decoding error")
        
        network.fetch(Endpoint(path: "/user")) { (result: Result<User, Error>) in
            switch result {
            case .success:
                XCTFail("Expected decoding error, got success")
            case .failure(let error):
                if let networkError = error as? DefaultNetworkError {
                    // Check that it's a decoding error
                    if case .decoding = networkError {
                        // Success - decoding error was properly mapped
                    } else {
                        XCTFail("Expected decoding error, got \(networkError)")
                    }
                } else {
                    XCTFail("Expected DefaultNetworkError, got \(error)")
                }
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    /// ## testSendHandlesDecodingError
    /// Tests that the `send` method properly handles and maps decoding errors.
    func testSendHandlesDecodingError() async throws {
        let jsonData = """
        {
            "unexpected": "data"
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.stubResponseData = jsonData
        
        defer {
            MockURLProtocol.stubResponseData = nil
            MockURLProtocol.error = nil
            MockURLProtocol.responseStatusCode = 200
        }
        
        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: sessionConfig)
        
        let config = NetworkConfiguration(baseURL: URL(string: "http://example.com")!, session: session)
        let provider = NetworkProvider<DefaultNetworkError>(configuration: config)
        
        struct User: Decodable {
            let id: Int
            let name: String
        }
        
        do {
            _ = try await provider.send(.init(path: "/test", method: .get), as: User.self)
            XCTFail("Expected decoding error")
        } catch let error as DefaultNetworkError {
            // Check that it's a decoding error
            if case .decoding = error {
                // Success - decoding error was properly mapped
            } else {
                XCTFail("Expected decoding error, got \(error)")
            }
        }
    }
}
