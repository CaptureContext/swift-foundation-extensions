// swift-tools-version:5.6

import PackageDescription

let package = Package(
  name: "swift-foundation-extensions",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v13),
    .tvOS(.v13),
    .watchOS(.v6)
  ],
  products: [
    .library(
      name: "FoundationExtensions",
      targets: ["FoundationExtensions"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/capturecontext/swift-declarative-configuration.git",
      .upToNextMinor(from: "0.3.0")
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-custom-dump",
      .upToNextMajor(from: "0.3.0")
    ),
  ],
  targets: [
    .target(
      name: "FoundationExtensions",
      dependencies: [
        .product(
          name: "FunctionalKeyPath",
          package: "swift-declarative-configuration"
        ),
        .product(
          name: "CustomDump",
          package: "swift-custom-dump"
        ),
      ]
    ),
    .testTarget(
      name: "FoundationExtensionsTests",
      dependencies: [
        .target(name: "FoundationExtensions"),
      ]
    ),
  ]
)
