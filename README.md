# SwiftNetworkingKit 🚀

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Swift Version](https://img.shields.io/badge/Swift-5.7-blue.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2013%2B%20-brightgreen.svg)]()
[![Release 1.0.0](https://img.shields.io/badge/release-1.0.0-blue.svg)]()

**A lightweight and testable asynchronous REST client built with Swift and `async/await`.**

---

## 🔧 Features

- ✅ Supports `GET`, `POST`, `PUT`, `DELETE`
- ✅ Encodable request body + Decodable response parsing
- ✅ Conditional debug logging in development builds
- ✅ Strongly typed, extensible error system via `NetworkErrorConvertible` protocol
- ✅ No external dependencies

---

## 📦 Installation

### Swift Package Manager (SPM)

Add the following to your `Package.swift` dependencies:

```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "YourApp",
  dependencies: [
    .package(url: "https://github.com/your-username/SwiftNetworkingKit.git", from: "1.0.0")
  ],
  targets: [
    .target(name: "YourApp", dependencies: ["SwiftNetworkingKit"])
  ]
)
```

Or use Xcode:
File → Add Packages…
 and paste the repo URL: https://github.com/Longo97/SwiftNetworking.git
