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
		.package(
			url: "https://github.com/pointfreeco/swift-custom-dump",
			.upToNextMajor(from: "1.0.0")
		),
		.package(
			url: "https://github.com/stackotter/swift-macro-toolkit.git",
			.upToNextMinor(from: "0.3.0")
		),
		.package(
			url: "https://github.com/pointfreeco/swift-macro-testing.git",
			.upToNextMinor(from: "0.2.2")
		)
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
		.target(
			name: "FoundationExtensionsMacros",
			dependencies: [
				.target(name: "FoundationExtensions"),
				.target(name: "FoundationExtensionsMacrosPlugin"),
			]
		),
		.macro(
			name: "FoundationExtensionsMacrosPlugin",
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
			name: "FoundationExtensionsMacrosPluginTests",
			dependencies: [
				.target(name: "FoundationExtensionsMacrosPlugin"),
				.product(name: "MacroTesting", package: "swift-macro-testing"),
			]
		),
		.testTarget(
			name: "FoundationExtensionsMacrosTests",
			dependencies: [
				.target(name: "FoundationExtensionsMacros"),
			]
		),
	]
)
