@preconcurrency import Foundation

extension Notification.Name {
	@available(*, deprecated, message: "Use IssueReporting module from https://github.com/pointfreeco/swift-issue-reporting")
	public static let foundationExtensionsRuntimeWarning: Self = .init(
		rawValue: "FoundationExtensions.runtimeWarning"
	)
}

@available(*, deprecated, message: "Use IssueReporting module from https://github.com/pointfreeco/swift-issue-reporting")
@_transparent
@inlinable
@inline(__always)
public func runtimeWarn(
	_ message: @autoclosure () -> String,
	category: String? = "FoundationExtensions",
	notificationName: Notification.Name? = .foundationExtensionsRuntimeWarning
) {
	#if DEBUG && canImport(XCTestDynamicOverlay)
	let message = message()
	notificationName.map { notificationName in
		NotificationCenter.default.post(
			name: notificationName,
			object: nil,
			userInfo: ["message": message]
		)
	}

	let category = category ?? "Runtime Warning"

	if isTesting {
		XCTFail(message)
	} else {
		#if canImport(os)
		os_log(
			.fault,
			dso: dso,
			log: OSLog(subsystem: "com.apple.runtime-issues", category: category),
			"%@",
			message
		)
		#else
		fputs("\(formatter.string(from: Date())) [\(category)] \(message)\n", stderr)
		#endif
	}
	#endif
}

#if DEBUG && canImport(XCTestDynamicOverlay)
import XCTestDynamicOverlay

#if canImport(os)
import os

// NB: Xcode runtime warnings offer a much better experience than traditional assertions and
//     breakpoints, but Apple provides no means of creating custom runtime warnings ourselves.
//     To work around this, we hook into SwiftUI's runtime issue delivery mechanism, instead.
//
// Feedback filed: https://gist.github.com/stephencelis/a8d06383ed6ccde3e5ef5d1b3ad52bbc
@usableFromInline
nonisolated(unsafe) let dso = { () -> UnsafeMutableRawPointer in
	let count = _dyld_image_count()
	for i in 0..<count {
		if let name = _dyld_get_image_name(i) {
			let swiftString = String(cString: name)
			if swiftString.hasSuffix("/SwiftUI") {
				if let header = _dyld_get_image_header(i) {
					return UnsafeMutableRawPointer(mutating: UnsafeRawPointer(header))
				}
			}
		}
	}
	return UnsafeMutableRawPointer(mutating: #dsohandle)
}()
#else
import Foundation

@usableFromInline
let formatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.dateFormat = "yyyy-MM-dd HH:MM:SS.sssZ"
	return formatter
}()
#endif
#endif

#if os(WASI)
		public let isTesting = false
#else
		import Foundation

		/// Whether or not the current process is running tests.
		///
		/// You can use this information to prevent application code from running when hosting tests. For
		/// example, you can wrap your app entry point:
		///
		/// ```swift
		/// import IssueReporting
		///
		/// @main
		/// struct MyApp: App {
		///   var body: some Scene {
		///     WindowGroup {
		///       if !isTesting {
		///         MyRootView()
		///       }
		///     }
		///   }
		/// }
		///
		/// To detect if the current task is running inside a test, use ``TestContext/current``, instead.
		public let isTesting = ProcessInfo.processInfo.isTesting

		extension ProcessInfo {
				fileprivate var isTesting: Bool {
						if environment.keys.contains("XCTestBundlePath") { return true }
						if environment.keys.contains("XCTestBundleInjectPath") { return true }
						if environment.keys.contains("XCTestConfigurationFilePath") { return true }
						if environment.keys.contains("XCTestSessionIdentifier") { return true }

						return arguments.contains { argument in
								let path = URL(fileURLWithPath: argument)
								return path.lastPathComponent == "swiftpm-testing-helper"
										|| argument == "--testing-library"
										|| path.lastPathComponent == "xctest"
										|| path.pathExtension == "xctest"
						}
				}
		}
#endif
