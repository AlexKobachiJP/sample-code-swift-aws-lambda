// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "swift-aws-lambda-webfinger",
  platforms: [
    .macOS(.v15)
  ],
  products: [
    .executable(name: "webfinger", targets: ["WebFinger"])
  ],
  dependencies: [
    .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime", from: "2.3.1"),
    .package(url: "https://github.com/swift-server/swift-aws-lambda-events", from: "1.2.4"),
    // We're not using this directly but Xcode 26 doesn't build the project without it, says:
    // sample-code-swift-aws-lambda/Package.swift Missing package product 'ServiceLifecycle'
    .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "2.8.0"),
  ],
  targets: [
    .executableTarget(
      name: "WebFinger",
      dependencies: [
        .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-events"),
        .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
        .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
      ]
    )
  ]
)
