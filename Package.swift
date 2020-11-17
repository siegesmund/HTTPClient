// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "HTTPClient",
    platforms: [.macOS(.v11), .iOS(.v14)],

    products: [
        .library(
            name: "HTTPClient",
            targets: ["HTTPClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.2.0")),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.1"),
        .package(url: "https://github.com/groue/CombineExpectations", from: "0.5.0")
    ],
    targets: [
        .target(
            name: "HTTPClient",
            dependencies: ["Alamofire", "KeychainAccess"]),
        .testTarget(
            name: "HTTPClientTests",
            dependencies: ["HTTPClient", "CombineExpectations"]),
    ]
)
