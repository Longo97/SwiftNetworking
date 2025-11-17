import XCTest
@testable import SwiftNetworking
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// # EndpointTests
/// Unit tests for the `Endpoint` type used in SwiftNetworking.
///
/// These tests validate:
/// - URL construction with query parameters
/// - HTTP method configuration
/// - Request body encoding
/// - Request headers
/// - Error handling for malformed base URLs
///
/// ## Test Cases
final class EndpointTests: XCTestCase {
    let baseURL = URL(string: "https://api.example.com")!
    
    /// ## testGETRequestWithQuery
    /// Verifies that a GET request is correctly built when query parameters are provided.
    ///
    /// The test ensures:
    /// - The full URL includes the encoded query string.
    /// - The HTTP method is `GET`.
    /// - The request body is `nil`.
    func testGETRequestWithQuery() throws {
        let endpoint = Endpoint(
            path: "/teams",
            method: .get,
            query: [
                URLQueryItem(name: "league", value: "serie-a"),
                URLQueryItem(name: "season", value: "2024")
            ]
        )
        
        let request = try endpoint.asURLRequest(baseURL: baseURL)
        
        XCTAssertEqual(request.url?.absoluteString, "https://api.example.com/teams?league=serie-a&season=2024")
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.httpBody)
    }
    
    /// ## testPOSTRequestWithBodyAndHeaders
    /// Validates that a POST request includes the correct body and headers.
    ///
    /// The test ensures:
    /// - The request URL matches the expected path.
    /// - The HTTP method is `POST`.
    /// - The `Content-Type` header is set correctly.
    /// - The body is properly encoded as JSON and can be decoded back to the original model.
    func testPOSTRequestWithBodyAndHeaders() throws {
        struct Team: Codable, Equatable {
            let name: String
            let year: Int
        }
        
        let team = Team(name: "Napoli", year: 1926)
        
        let endpoint = Endpoint(
            path: "/teams",
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: team
        )
        
        let request = try endpoint.asURLRequest(baseURL: baseURL)
        let data = try JSONDecoder().decode(Team.self, from: request.httpBody!)
        
        XCTAssertEqual(request.url?.absoluteString, "https://api.example.com/teams")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(data, team)
    }
    
    /// ## testDefaultMethodIsGET
    /// Ensures that the default HTTP method used by `Endpoint` is `GET` when not explicitly specified.
    func testDefaultMethodIsGET() throws {
        let endpoint = Endpoint(path: "/status")
        let request = try endpoint.asURLRequest(baseURL: baseURL)
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    /// ## testURLConstructionFailsWithInvalidBaseURL
    /// Ensures that the request building process fails gracefully when an invalid base URL is provided.
    ///
    /// The test checks:
    /// - The error thrown is of type `DefaultNetworkError.cannotBuildURL`.
    func testURLConstructionFailsWithInvalidBaseURL() {
        let invalidBaseURL = URL(string: "invalid-url")
        let endpoint = Endpoint(path: "/test")
        
        XCTAssertThrowsError(try endpoint.asURLRequest(baseURL: invalidBaseURL!)) { error in
            XCTAssertEqual(error as? DefaultNetworkError, .cannotBuildURL)
        }
    }
}

