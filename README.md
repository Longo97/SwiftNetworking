# SwiftNetworking 🚀

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Swift Version](https://img.shields.io/badge/Swift-5.7-blue.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2013%2B%20-brightgreen.svg)]()
[![Release 1.0.0](https://img.shields.io/badge/release-1.1.0-blue.svg)]()

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
    .package(url: "https://github.com/Longo97/SwiftNetworking.git", from: "1.0.0")
  ],
  targets: [
    .target(name: "YourApp", dependencies: ["SwiftNetworking"])
  ]
)
```

Or use Xcode:
File → Add Packages…
 and paste the repo URL: https://github.com/Longo97/SwiftNetworking.git

 ## 🚀 Usage
 ```swift
guard let url = URL(string: "https://<Your URL>.com") else {
    return
}

let configuration = NetworkConfiguration(baseURL:url)
let provider = NetworkProvider<DefaultNetworkError>(configuration: configuration)
do {
    let user = try await provider.send(Endpoint(path: "/users"), as: User.self) // <User> is the Model
    print(user.name)
} catch {
    print(error.localizedDescription)
}
```

## 🙌 Contributing
We welcome contributions to improve SwiftNetworking! 🚀

If you’d like to help, here are a few ideas:
- Add new request/response features;
- Improve compatibility with older iOS versions;
- Write tests or improve documentation.

## 📐 Guidelines
- Follow the existing code style and structure;
- Write tests for any new functionality;
- Open a pull request with a clear description of your changes;
- Be respectful and constructive in discussions.

## 📄 License
This project is licensed under the MIT License.
