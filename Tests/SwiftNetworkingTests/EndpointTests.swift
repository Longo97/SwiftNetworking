import XCTest
@testable import SwiftNetworking

final class EndpointTests: XCTestCase {
    let baseURL = URL(string: "https://api.example.com")!
    
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
        
        let request = try endpoint.asURLRequest(baseURL: URL(string: "https://api.example.com")!)
        let data = try JSONDecoder().decode(Team.self, from: request.httpBody!)
        
        XCTAssertEqual(request.url?.absoluteString, "https://api.example.com/teams")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(data, team)
    }
    
    func testDefaultMethodIsGET() throws {
        let endpoint = Endpoint(path: "/status")
        let request = try endpoint.asURLRequest(baseURL: baseURL)
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    func testURLConstructionFailsWithInvalidBaseURL() {
        let invalidBaseURL = URL(string: "invalid-url")
        let endpoint = Endpoint(path: "/test")
        
        XCTAssertThrowsError(try endpoint.asURLRequest(baseURL: invalidBaseURL!)) { error in
            XCTAssertEqual(error as? DefaultNetworkError, .cannotBuildURL)
        }
    }
}
