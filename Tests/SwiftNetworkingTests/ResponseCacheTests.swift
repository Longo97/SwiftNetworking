//
//  ResponseCacheTests.swift
//  SwiftNetworking
//
//  Created by Marco Longobardi on 10/07/25.
//

import XCTest
@testable import SwiftNetworking
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class ResponseCacheTests: XCTestCase {
    
    private var cache: ResponseCache!
        private var request: URLRequest!
        
        override func setUp() {
            super.setUp()
            cache = ResponseCache()
            request = URLRequest(url: URL(string: "https://api.example.com/test")!)
            request.httpMethod = "GET"
            request.addValue("Bearer abc", forHTTPHeaderField: "Authorization")
        }
        
        override func tearDown() {
            cache = nil
            request = nil
            super.tearDown()
        }
        
        func test_cacheStoresAndRetrievesDataWithinTTL() {
            let data = "Hello".data(using: .utf8)!
            cache.set(data, for: request)
            
            let result = cache.get(for: request, ttl: 5) // TTL 5 seconds
            XCTAssertEqual(result, data, "Cache should return the saved data within TTL")
        }
        
        func test_cacheInvalidatesDataAfterTTL() {
            let data = "Hello".data(using: .utf8)!
            cache.set(data, for: request)
            
            let expectation = XCTestExpectation(description: "Wait for TTL expiration")
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                let result = self.cache.get(for: self.request, ttl: 1) // TTL 1 second
                XCTAssertNil(result, "Cache should invalidate expired data")
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 3)
        }
        
        func test_cacheIgnoresVolatileHeaders() {
            let data = "Hello".data(using: .utf8)!
            cache.set(data, for: request)
            
            var otherRequest = request!
            otherRequest.setValue("Bearer xyz", forHTTPHeaderField: "Authorization")
            
            let result = cache.get(for: otherRequest, ttl: 5)
            XCTAssertEqual(result, data, "Cache should ignore volatile headers and return the data")
        }
}
