// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "swift-aws-lambda-webfinger",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(name: "webfinger", targets: ["WebFinger"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime", from: "1.0.0-alpha"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-events", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "WebFinger",
            dependencies: [
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-runtime")
            ]
        ),
    ]
)
