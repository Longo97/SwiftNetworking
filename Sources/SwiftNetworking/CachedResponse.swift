//
//  CachedResponse.swift
//  SwiftNetworking
//
//  Created by Marco Longobardi on 10/07/25.
//

import Foundation

final class CachedResponse {
    let data: Data
    let timestamp: Date
    
    init(data: Data) {
        self.data = data
        self.timestamp = Date()
    }
}
