//
//  ResponseCacheTests.swift
//  SwiftNetworking
//
//  Created by Marco Longobardi on 10/07/25.
//

import XCTest
@testable import SwiftNetworking

final class ResponseCacheTests: XCTestCase {
    
    func makeRequest(url: String = "https://example.com") -> URLRequest {
        return URLRequest(url: URL(string: url)!)
    }
    
    /// Tests that a cached response is correctly returned when accessed within the specified TTL.
    func testSetAndGetWithinTTL() {
        let cache = ResponseCache()
        let request = makeRequest()
        let data = "Hello, World!".data(using: .utf8)!
        
        cache.set(data, for: request)
        let result = cache.get(for: request, ttl: 5) // 5 seconds
        
        XCTAssertEqual(result, data)
    }
    
    /// Tests that the cache returns nil if the cached data has expired based on the TTL.
    func testGetReturnsNilAfterTTLExpires() {
        let cache = ResponseCache()
        let request = makeRequest()
        let data = "Outdated".data(using: .utf8)!
        
        cache.set(data, for: request)

        // Simula che il dato sia vecchio: modifica manualmente il timestamp
        let cached = cache.get(for: request, ttl: 0) // TTL scaduto subito
        
        XCTAssertNil(cached)
    }
    
    /// Tests that the cache returns nil when no data has been cached for the given request.
    func testGetReturnsNilIfNoCacheExists() {
        let cache = ResponseCache()
        let request = makeRequest()
        
        let result = cache.get(for: request, ttl: 5)
        
        XCTAssertNil(result)
    }
}
