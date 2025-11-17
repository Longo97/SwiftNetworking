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
        
        func test_cacheReturnsNilForNonExistentRequest() {
            var differentRequest = request!
            differentRequest.url = URL(string: "https://api.example.com/different")
            
            let result = cache.get(for: differentRequest, ttl: 5)
            XCTAssertNil(result, "Cache should return nil for requests that haven't been cached")
        }
        
        func test_cacheHandlesEmptyData() {
            let emptyData = Data()
            cache.set(emptyData, for: request)
            
            let result = cache.get(for: request, ttl: 5)
            XCTAssertEqual(result, emptyData, "Cache should handle empty data")
        }
        
        func test_cacheOverwritesExistingData() {
            let data1 = "First".data(using: .utf8)!
            cache.set(data1, for: request)
            
            let data2 = "Second".data(using: .utf8)!
            cache.set(data2, for: request)
            
            let result = cache.get(for: request, ttl: 5)
            XCTAssertEqual(result, data2, "Cache should overwrite existing data")
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
