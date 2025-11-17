//
//  NetworkConfigurationTests.swift
//  SwiftNetworking
//
//  Created by Marco Longobardi
//

import XCTest
@testable import SwiftNetworking
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// # NetworkConfigurationTests
/// Unit tests for the `NetworkConfiguration` struct.
///
/// These tests validate:
/// - Custom configurations
/// - Default configuration
/// - Decoder customization
final class NetworkConfigurationTests: XCTestCase {
    
    /// ## testCustomConfiguration
    /// Verifies that a custom configuration can be created with specified values.
    func testCustomConfiguration() {
        let url = URL(string: "https://api.custom.com")!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let session = URLSession.shared
        
        let config = NetworkConfiguration(baseURL: url, decoder: decoder, session: session)
        
        XCTAssertEqual(config.baseURL, url)
        XCTAssertNotNil(config.decoder)
        XCTAssertEqual(config.session, session)
    }
    
    /// ## testDefaultConfiguration
    /// Verifies that the default configuration is properly initialized.
    func testDefaultConfiguration() {
        let config = NetworkConfiguration.default
        
        XCTAssertNotNil(config, "Default configuration should not be nil")
        XCTAssertEqual(config?.baseURL.absoluteString, "https://example.com")
    }
    
    /// ## testConfigurationWithDefaultValues
    /// Verifies that a configuration with only base URL uses default decoder and session.
    func testConfigurationWithDefaultValues() {
        let url = URL(string: "https://api.test.com")!
        let config = NetworkConfiguration(baseURL: url)
        
        XCTAssertEqual(config.baseURL, url)
        XCTAssertNotNil(config.decoder)
        XCTAssertNotNil(config.session)
    }
}
