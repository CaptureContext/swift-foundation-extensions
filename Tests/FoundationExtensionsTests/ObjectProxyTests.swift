import XCTest
@testable import FoundationExtensions

final class ObjectProxyTests: XCTestCase {
	func testMain() {
		class Object {
			class WrappedObject {
				var value: Int = 0
			}
			
			internal let wrapped: WrappedObject = .init()
			
			@PropertyProxy(\Object.wrapped.value)
			var value
		}
		
		let object = Object()
		
		XCTAssertEqual(object.value, 0)
		XCTAssertEqual(object.wrapped.value, 0)
		
		object.value = 1
		XCTAssertEqual(object.value, 1)
		XCTAssertEqual(object.wrapped.value, 1)
		
		object.value += 1
		XCTAssertEqual(object.value, 2)
		XCTAssertEqual(object.wrapped.value, 2)
	}
}
