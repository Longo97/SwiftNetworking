//
//  LogUtilities.swift
//  SwiftNetworking
//
//  Created by Marco Longobardi on 08/07/25.
//

import Foundation

internal struct LogUtilities {
    static func log(_ message: String) {
#if DEBUG
        print("[DEBUG]: \(message)")
#endif
    }
}
