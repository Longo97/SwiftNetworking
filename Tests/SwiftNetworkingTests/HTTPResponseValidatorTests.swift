//
//  HTTPResponseValidatorTests.swift
//  SwiftNetworking
//
//  Created by Marco Longobardi
//

import XCTest
@testable import SwiftNetworking
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// # HTTPResponseValidatorTests
/// Unit tests for the `HTTPResponseValidator` utility.
///
/// These tests validate:
/// - Success for 2xx status codes
/// - Failure for non-2xx status codes
/// - Handling of non-HTTP responses
final class HTTPResponseValidatorTests: XCTestCase {
    
    /// ## testValidate2xxStatusCodes
    /// Verifies that 2xx status codes pass validation.
    func testValidate2xxStatusCodes() throws {
        let validCodes = [200, 201, 202, 204, 299]
        
        for code in validCodes {
            let response = HTTPURLResponse(
                url: URL(string: "https://example.com")!,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            
            XCTAssertNoThrow(try HTTPResponseValidator.validate(response), "Status code \(code) should be valid")
        }
    }
    
    /// ## testValidateRejectsClientErrors
    /// Verifies that 4xx status codes throw errors.
    func testValidateRejectsClientErrors() {
        let errorCodes = [400, 401, 403, 404, 422, 429]
        
        for code in errorCodes {
            let response = HTTPURLResponse(
                url: URL(string: "https://example.com")!,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            
            XCTAssertThrowsError(try HTTPResponseValidator.validate(response), "Status code \(code) should throw error") { error in
                if let networkError = error as? DefaultNetworkError {
                    XCTAssertEqual(networkError, .statusCode(code))
                } else {
                    XCTFail("Expected DefaultNetworkError, got \(error)")
                }
            }
        }
    }
    
    /// ## testValidateRejectsServerErrors
    /// Verifies that 5xx status codes throw errors.
    func testValidateRejectsServerErrors() {
        let errorCodes = [500, 502, 503, 504]
        
        for code in errorCodes {
            let response = HTTPURLResponse(
                url: URL(string: "https://example.com")!,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            
            XCTAssertThrowsError(try HTTPResponseValidator.validate(response), "Status code \(code) should throw error") { error in
                if let networkError = error as? DefaultNetworkError {
                    XCTAssertEqual(networkError, .statusCode(code))
                } else {
                    XCTFail("Expected DefaultNetworkError, got \(error)")
                }
            }
        }
    }
    
    /// ## testValidateRejectsNonHTTPResponse
    /// Verifies that non-HTTP responses throw an error.
    func testValidateRejectsNonHTTPResponse() {
        let response = URLResponse(
            url: URL(string: "https://example.com")!,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
        
        XCTAssertThrowsError(try HTTPResponseValidator.validate(response)) { error in
            if let networkError = error as? DefaultNetworkError {
                XCTAssertEqual(networkError, .invalidHTTPResponse)
            } else {
                XCTFail("Expected DefaultNetworkError.invalidHTTPResponse, got \(error)")
            }
        }
    }
}
