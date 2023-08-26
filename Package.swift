// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
  name: "swift-foundation-extensions",
  platforms: [
    .macOS(.v10_15),
    .macCatalyst(.v13),
    .iOS(.v13),
    .tvOS(.v13),
    .watchOS(.v6)
  ],
  products: [
    .library(
      name: "FoundationExtensions",
      targets: ["FoundationExtensions"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/capturecontext/swift-declarative-configuration.git",
      .upToNextMinor(from: "0.3.0")
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-custom-dump",
      .upToNextMajor(from: "1.0.0")
    ),
    .package(
      url: "https://github.com/maximkrouk/swift-macro-toolkit.git",
      .upToNextMinor(from: "0.3.0")
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-macro-testing.git",
      .upToNextMinor(from: "0.1.0")
    ),
    .package(
      url: "https://github.com/apple/swift-syntax.git",
      exact: "509.0.0"
    ),
  ],
  targets: [
    .target(
      name: "FoundationExtensions",
      dependencies: [
        .target(name: "FoundationExtensionsMacros"),
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
    .macro(
      name: "FoundationExtensionsMacros",
      dependencies: [
        .product(
          name: "MacroToolkit",
          package: "swift-macro-toolkit"
        )
      ]
    ),
    .testTarget(
      name: "FoundationExtensionsTests",
      dependencies: [
        .target(name: "FoundationExtensions"),
      ]
    ),
    .testTarget(
        name: "FoundationExtensionsMacrosTests",
        dependencies: [
          .target(name: "FoundationExtensionsMacros"),
          .product(name: "MacroTesting", package: "swift-macro-testing"),
        ]
    ),
  ]
)
