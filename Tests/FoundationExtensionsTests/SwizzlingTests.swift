import XCTest
@testable import FoundationExtensions

final class SwizzlingTests: XCTestCase {
	func testMain() {
		let object = MyObject()

		XCTAssertEqual(object.modify(10), 11)

		MyObject.swizzle() // exchanges implementations

		XCTAssertEqual(object.modify(10), 21)

		MyObject.swizzle() // exchanges implementations back

		XCTAssertEqual(object.modify(10), 11)
	}
}

private class MyObject: NSObject {
	@objc dynamic
	func modify(_ value: Int) -> Int {
		return value + 1
	}
}

extension MyObject {
	/// Performs swizzling for the class
	///
	/// If you only want to allow to swizzle your class once in app lifetime you can do this
	/// ```swift
	/// static let swizzle: Void = {
	///   objc_exchangeImplementations(
	///     #selector(modify),
	///     #selector(__swizzledModify)
	///   )
	/// }()
	/// ```
	static func swizzle() {
		objc_exchangeImplementations(
			#selector(modify),
			#selector(__swizzledModify)
		)

		// add more swizzling here if needed
	}

	@objc dynamic
	private func __swizzledModify(_ value: Int) -> Int {
		// Calls original method
		return __swizzledModify(value * 2)
	}
}
