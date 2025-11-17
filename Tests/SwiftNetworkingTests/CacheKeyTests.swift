//
//  CacheKeyTests.swift
//  SwiftNetworking
//
//  Created by Marco Longobardi
//

import XCTest
@testable import SwiftNetworking
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// # CacheKeyTests
/// Unit tests for the `CacheKey` class.
///
/// These tests validate:
/// - Equality comparison
/// - Hash calculation
/// - Header filtering behavior
final class CacheKeyTests: XCTestCase {
    
    /// ## testEqualityWithSameRequest
    /// Verifies that two cache keys from identical requests are equal.
    func testEqualityWithSameRequest() {
        var request1 = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request1.httpMethod = "GET"
        
        var request2 = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request2.httpMethod = "GET"
        
        let key1 = CacheKey(request: request1)
        let key2 = CacheKey(request: request2)
        
        XCTAssertEqual(key1, key2)
        XCTAssertEqual(key1.hash, key2.hash)
    }
    
    /// ## testInequalityWithDifferentURL
    /// Verifies that cache keys from requests with different URLs are not equal.
    func testInequalityWithDifferentURL() {
        let request1 = URLRequest(url: URL(string: "https://api.example.com/test1")!)
        let request2 = URLRequest(url: URL(string: "https://api.example.com/test2")!)
        
        let key1 = CacheKey(request: request1)
        let key2 = CacheKey(request: request2)
        
        XCTAssertNotEqual(key1, key2)
    }
    
    /// ## testInequalityWithDifferentMethod
    /// Verifies that cache keys from requests with different HTTP methods are not equal.
    func testInequalityWithDifferentMethod() {
        var request1 = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request1.httpMethod = "GET"
        
        var request2 = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request2.httpMethod = "POST"
        
        let key1 = CacheKey(request: request1)
        let key2 = CacheKey(request: request2)
        
        XCTAssertNotEqual(key1, key2)
    }
    
    /// ## testIgnoresVolatileHeaders
    /// Verifies that volatile headers (like Authorization) are ignored in cache key comparison.
    func testIgnoresVolatileHeaders() {
        var request1 = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request1.setValue("Bearer token1", forHTTPHeaderField: "Authorization")
        
        var request2 = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request2.setValue("Bearer token2", forHTTPHeaderField: "Authorization")
        
        let key1 = CacheKey(request: request1)
        let key2 = CacheKey(request: request2)
        
        XCTAssertEqual(key1, key2, "Cache keys should be equal when only volatile headers differ")
    }
    
    /// ## testIncludesAllowedHeaders
    /// Verifies that allowed headers (like Content-Type) are included in cache key comparison.
    func testIncludesAllowedHeaders() {
        var request1 = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request1.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var request2 = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request2.setValue("application/xml", forHTTPHeaderField: "Content-Type")
        
        let key1 = CacheKey(request: request1)
        let key2 = CacheKey(request: request2)
        
        XCTAssertNotEqual(key1, key2, "Cache keys should differ when allowed headers differ")
    }
    
    /// ## testHashConsistency
    /// Verifies that equal cache keys produce the same hash.
    func testHashConsistency() {
        var request1 = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request1.httpMethod = "GET"
        request1.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var request2 = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request2.httpMethod = "GET"
        request2.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let key1 = CacheKey(request: request1)
        let key2 = CacheKey(request: request2)
        
        XCTAssertEqual(key1.hash, key2.hash, "Equal cache keys should produce the same hash")
    }
}
