import XCTest
@testable import FoundationExtensions

final class IndirectTests: XCTestCase {
	func testMain() {
		struct LinkedListNode<Value: Equatable>: Equatable {
			var value: Value
			@Indirect
			var next: LinkedListNode?
		}
		
		@Indirect
		var root = LinkedListNode<Int>(value: 0)

		@Indirect
		var first: LinkedListNode? = LinkedListNode<Int>(value: 1)

		@Indirect
		var second: LinkedListNode? = LinkedListNode<Int>(value: 2)

		root.next = first
		root.next?.next = second
		
		XCTAssertEqual(
			root,
			LinkedListNode(
				value: 0,
				next: LinkedListNode(
					value: 1,
					next: LinkedListNode(value: 2)
				)
			)
		)
		
		// Equated by value
		XCTAssertEqual(
			first,
			LinkedListNode(value: 1)
		)

		// CoW
		var third = $second
		XCTAssert(third._sharesStorage(with: $second) == true)

		third._setValue(LinkedListNode(value: 2))
		XCTAssertEqual(second?.value, 2)
		XCTAssert(third._sharesStorage(with: $second) == true)

		third._modifyValue { $0?.value += 1 }
		XCTAssertEqual(second?.value, 3)
		XCTAssert(third._sharesStorage(with: $second) == true)

		third.wrappedValue?.value = 4
		XCTAssertEqual(second?.value, 3)
		XCTAssertEqual(third.wrappedValue?.value, 4)
		XCTAssert(third._sharesStorage(with: $second) == false)
	}
}
