//
//  CacheKey.swift
//  SwiftNetworking
//
//  Created by Marco Longobardi on 30/08/25.
//
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class CacheKey: NSObject {
    let method: String
    let url: String
    let headers: [String: String]
    
    init(request: URLRequest) {
        self.method = request.httpMethod ?? "GET"
        self.url = request.url?.absoluteString ?? ""
        
        let allowed = ["Accept", "Content-Type", "Accept-Language"]
        self.headers = (request.allHTTPHeaderFields ?? [:])
            .filter { allowed.contains($0.key) }
    }
    
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(method)
        hasher.combine(url)
        for (k, v) in headers.sorted(by: { $0.key < $1.key }) {
            hasher.combine(k)
            hasher.combine(v)
        }
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CacheKey else { return false }
        return method == other.method &&
        url == other.url &&
        headers == other.headers
    }
}
