// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "swift-foundation-extensions",
	platforms: [
		.macOS(.v10_15),
		.macCatalyst(.v13),
		.iOS(.v13),
		.tvOS(.v13),
		.watchOS(.v6),
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
			url: "https://github.com/capturecontext/swift-resettable.git",
			.upToNextMinor(from: "0.1.0")
		),
		.package(
			url: "https://github.com/capturecontext/swift-equated.git",
			.upToNextMinor(from: "0.0.2")
		),
		.package(
			url: "https://github.com/capturecontext/swift-associated-objects.git",
			.upToNextMinor(from: "0.2.2")
		)
	],
	targets: [
		.target(
			name: "FoundationExtensions",
			dependencies: [
				.product(
					name: "AssociatedObjects",
					package: "swift-associated-objects"
				),
				.product(
					name: "Resettable",
					package: "swift-resettable"
				),
				.product(
					name: "Equated",
					package: "swift-equated"
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
	],
	swiftLanguageModes: [.v6]
)
