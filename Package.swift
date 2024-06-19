// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "OpenAI",
  platforms: [
    .iOS(.v15),
    .tvOS(.v15),
    .macOS(.v12),
    .watchOS(.v8)
  ],

  products: [
    .library(name: "OpenAI", targets: ["OpenAI"])
  ],
  dependencies: [
    .package(url: "https://github.com/swiftnative/URLConfig.git", from: "1.1.0")
  ],
  targets: [
    .target(
      name: "OpenAI",
      dependencies: [
        .product(name: "URLConfig", package: "URLConfig")
      ],
      path: "Sources"),
    .testTarget(
      name: "OpenAITests",
      dependencies: ["OpenAI"],
      path: "Tests")
  ]
)
