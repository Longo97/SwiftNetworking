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

### Basic GET Request (async/await)
 ```swift
guard let url = URL(string: "https://api.example.com") else {
    return
}

let configuration = NetworkConfiguration(baseURL: url)
let provider = NetworkProvider<DefaultNetworkError>(configuration: configuration)

struct User: Decodable {
    let id: Int
    let name: String
}

do {
    let user = try await provider.send(Endpoint(path: "/users/1"), as: User.self)
    print("User: \(user.name)")
} catch {
    print("Error: \(error.localizedDescription)")
}
```

### POST Request with Body
```swift
struct CreateUserRequest: Encodable {
    let name: String
    let email: String
}

let newUser = CreateUserRequest(name: "John Doe", email: "john@example.com")
let endpoint = Endpoint(
    path: "/users",
    method: .post,
    headers: ["Authorization": "Bearer YOUR_TOKEN"],
    body: newUser
)

do {
    let createdUser = try await provider.send(endpoint, as: User.self)
    print("Created user: \(createdUser.name)")
} catch {
    print("Error: \(error.localizedDescription)")
}
```

### PUT/PATCH Request
```swift
struct UpdateUserRequest: Encodable {
    let name: String
}

let update = UpdateUserRequest(name: "Jane Doe")
let endpoint = Endpoint(
    path: "/users/1",
    method: .patch,
    body: update
)

do {
    let updatedUser = try await provider.send(endpoint, as: User.self)
    print("Updated user: \(updatedUser.name)")
} catch {
    print("Error: \(error.localizedDescription)")
}
```

### DELETE Request
```swift
let endpoint = Endpoint(path: "/users/1", method: .delete)

do {
    // DELETE requests can return empty responses or status confirmations
    struct DeleteResponse: Decodable {
        let success: Bool
    }
    let response = try await provider.send(endpoint, as: DeleteResponse.self)
    print("Deleted: \(response.success)")
} catch {
    print("Error: \(error.localizedDescription)")
}
```

### Completion Handler (dataTask)
```swift
let endpoint = Endpoint(path: "/users/1")

provider.fetch(endpoint) { (result: Result<User, Error>) in
    switch result {
    case .success(let user):
        print("User fetched: \(user.name)")
    case .failure(let error):
        print("Failed to fetch user: \(error.localizedDescription)")
    }
}
```

### Request with Cache
```swift
let endpoint = Endpoint(
    path: "/users/1",
    cachePolicy: .enabled(ttl: 300), // Cache for 5 minutes
    verbose: true // Enable debug logging
)

do {
    let user = try await provider.send(endpoint, as: User.self)
    print("User: \(user.name)")
} catch {
    print("Error: \(error.localizedDescription)")
}
```

### Custom Decoder Configuration
```swift
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
decoder.dateDecodingStrategy = .iso8601

let configuration = NetworkConfiguration(
    baseURL: url,
    decoder: decoder
)
let provider = NetworkProvider<DefaultNetworkError>(configuration: configuration)
```

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
