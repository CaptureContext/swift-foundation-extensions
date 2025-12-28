// swift-tools-version: 6.0

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
		),
		.library(
			name: "FoundationExtensionsMacros",
			targets: ["FoundationExtensionsMacros"]
		),
	],
	dependencies: [
		.package(
			url: "https://github.com/capturecontext/swift-declarative-configuration.git",
			.upToNextMinor(from: "0.3.0")
		),
		.package(path: "../swift-associated-objects"),
		.package(path: "../swift-resettable")
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
					name: "AssociatedObjects",
					package: "swift-associated-objects"
				),
				.product(
					name: "Resettable",
					package: "swift-resettable"
				),
			]
		),
		.target(
			name: "FoundationExtensionsMacros",
			dependencies: [
				.target(name: "FoundationExtensions"),
				.product(
					name: "AssociatedObjectsMacros",
					package: "swift-associated-objects"
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
