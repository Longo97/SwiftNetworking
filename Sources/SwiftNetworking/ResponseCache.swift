//
//  ResponseCache.swift
//  SwiftNetworking
//
//  Created by Marco Longobardi on 10/07/25.
//


import Foundation

internal final class ResponseCache {
    private let cache = NSCache<NSURLRequest, CachedResponse>()
    
    func get(for request: URLRequest, ttl: TimeInterval) -> Data? {
        guard let cached = cache.object(forKey: request as NSURLRequest) else { return nil }
        let age = abs(cached.timestamp.timeIntervalSinceNow)
        return age < ttl ? cached.data : nil
    }
    
    func set(_ data: Data, for request: URLRequest) {
        cache.setObject(CachedResponse(data: data), forKey: request as NSURLRequest)
    }
}
