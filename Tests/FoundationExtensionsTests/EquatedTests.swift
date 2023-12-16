import XCTest
@testable import FoundationExtensions

final class EquatedTests: XCTestCase {
	func testMain() {
		struct Const {
			var value: () -> Int
			
			init(_ value: Int) {
				self.value = { value }
			}
		}
		
		struct State: Equatable {
			@Equated(by: .property { $0.value() })
			var const = Const(0)
		}
		
		XCTAssertEqual(State(const: .init(0)), State(const: .init(0)))
		XCTAssertNotEqual(State(const: .init(0)), State(const: .init(1)))
	}
}
