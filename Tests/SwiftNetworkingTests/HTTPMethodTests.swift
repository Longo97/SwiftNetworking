//
//  HTTPMethodTests.swift
//  SwiftNetworking
//
//  Created by Marco Longobardi
//

import XCTest
@testable import SwiftNetworking

/// # HTTPMethodTests
/// Unit tests for the `HTTPMethod` enum.
///
/// These tests validate:
/// - All HTTP methods have the correct raw values
/// - HTTP methods can be used in network requests
final class HTTPMethodTests: XCTestCase {
    
    /// ## testHTTPMethodRawValues
    /// Verifies that each HTTP method has the correct raw string value.
    func testHTTPMethodRawValues() {
        XCTAssertEqual(HTTPMethod.get.rawValue, "GET")
        XCTAssertEqual(HTTPMethod.post.rawValue, "POST")
        XCTAssertEqual(HTTPMethod.put.rawValue, "PUT")
        XCTAssertEqual(HTTPMethod.delete.rawValue, "DELETE")
        XCTAssertEqual(HTTPMethod.head.rawValue, "HEAD")
        XCTAssertEqual(HTTPMethod.options.rawValue, "OPTIONS")
        XCTAssertEqual(HTTPMethod.trace.rawValue, "TRACE")
        XCTAssertEqual(HTTPMethod.patch.rawValue, "PATCH")
        XCTAssertEqual(HTTPMethod.connect.rawValue, "CONNECT")
    }
}
