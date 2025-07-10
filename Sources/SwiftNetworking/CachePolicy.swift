//
//  CachePolicy.swift
//  SwiftNetworking
//
//  Created by Marco Longobardi on 10/07/25.
//
import Foundation

public enum CachePolicy {
    case enabled(ttl: TimeInterval)
    case disabled
}
