import XCTest
@testable import FoundationExtensions

func andOf(_ values: Bool...) -> Bool {
	values.reduce(true) { $0 && $1 }
}

final class ResettableTests: XCTestCase {
	struct TestStruct: Equatable {
		struct Inner: Equatable {
			var value: Int = 0
		}
		var inner: Inner = .init()
		var boolean: Bool = false
		var int: Int = 0
		var optional: Optional<Inner> = nil
	}
	
	class TestClass: Equatable {
		static func == (lhs: TestClass, rhs: TestClass) -> Bool {
			andOf(
				lhs.inner == rhs.inner,
				lhs.boolean == rhs.boolean,
				lhs.int == rhs.int,
				lhs.optional == rhs.optional
			)
		}
		
		struct Inner: Equatable {
			var value: Int = 0
		}
		
		init() {}
		
		var inner: Inner = .init()
		var boolean: Bool = false
		var int: Int = 0
		var optional: Optional<Inner> = nil
	}
	
	public func testUndoRedoValueType() {
		var value = TestStruct()
		let resettable = Resettable(value)
		
		resettable.inner.value(1)
		value.inner.value = 1
		
		resettable.boolean(true)
		value.boolean = true
		
		resettable.inner.value(2)
		value.inner.value = 2
		
		resettable.int(10)
		value.int = 10
		
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.undo()
		value.int = 0
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.undo()
		value.inner.value = 1
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.undo()
		value.boolean = false
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.undo()
		value.inner.value = 0
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.redo()
		value.inner.value = 1
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.int { $0 += 1 }
		value.int = 1
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.undo()
		value.int = 0
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.redo()
		value.int = 1
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.redo()
		value.int = 1
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.optional(.init())
		value.optional = .init()
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.optional.value(1)
		value.optional?.value = 1
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.optional(nil)
		value.optional = nil
		XCTAssertEqual(resettable.wrappedValue, value)
	}
	
	public func testUndoRedoReferenceType() {
		let value = TestClass()
		let resettable = Resettable(value)
		
		resettable.inner.value(1)
		value.inner.value = 1
		
		resettable.boolean(true)
		value.boolean = true
		
		resettable.inner.value(2)
		value.inner.value = 2
		
		resettable.int(10)
		value.int = 10
		
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.undo()
		value.int = 0
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.undo()
		value.inner.value = 1
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.undo()
		value.boolean = false
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.undo()
		value.inner.value = 0
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.redo()
		value.inner.value = 1
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.int { $0 += 1 }
		value.int = 1
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.undo()
		value.int = 0
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.redo()
		value.int = 1
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.redo()
		value.int = 1
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.optional(.init())
		value.optional = .init()
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.optional.value(1)
		value.optional?.value = 1
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.optional(nil)
		value.optional = nil
		XCTAssertEqual(resettable.wrappedValue, value)
	}
	
	func testUndoRedoCollection() {
		struct Object: Equatable {
			let id: UUID = .init()
			var value: Int = 0
		}
		
		var first = Object(value: 0)
		var second = Object(value: 1)
		let resettable = Resettable([first, second])
		
		resettable.collection.swapAt(0, 1)
		
		XCTAssertEqual(resettable.wrappedValue, [second, first])
		
		resettable.collection[safe: 0].value(0)
		second.value = 0
		
		XCTAssertEqual(resettable.wrappedValue, [second, first])
		
		resettable.undo()
		second.value = 1
		XCTAssertEqual(resettable.wrappedValue, [second, first])
		
		resettable.undo()
		XCTAssertEqual(resettable.wrappedValue, [first, second])
		
		resettable.redo()
		XCTAssertEqual(resettable.wrappedValue, [second, first])
		
		let third = Object(value: -1)
		resettable
			.collection.swapAt(0, 1)
			.collection[safe: 0].value(2)
			.collection.append(third)
			._modify(
				using: { $0.reverse() },
				undo: { $0.reverse() }
			)
		first.value = 2
		
		XCTAssertEqual(resettable.wrappedValue, [third, second, first])
		
		resettable.redo().redo().redo() // no changes
		
		XCTAssertEqual(resettable.wrappedValue, [third, second, first])
		
		resettable.undo()
		
		XCTAssertEqual(resettable.wrappedValue, [first, second, third])
		
		resettable.undo()
		
		XCTAssertEqual(resettable.wrappedValue, [first, second])
		
		resettable.redo()
		
		XCTAssertEqual(resettable.wrappedValue, [first, second, third])
		
		resettable
			.collection.remove(at: 2)
			.collection.remove(at: 1)
			.collection.remove(at: 0)
		
		resettable.undo().undo().undo()
		
		XCTAssertEqual(resettable.wrappedValue, [first, second, third])
		
		resettable.restore()
		
		XCTAssertEqual(resettable.wrappedValue, [])
		
		resettable.reset()
		
		first.value = 0
		second.value = 1
		
		XCTAssertEqual(resettable.wrappedValue, [first, second])
	}
	
	func testAmendValueType() {
		var value = TestStruct()
		let resettable = Resettable(value)
		
		resettable.inner.value(1)
		value.inner.value = 1
		
		resettable.boolean(true)
		value.boolean = true
		
		resettable.inner.value(2)
		value.inner.value = 2
		
		resettable.int(10)
		value.int = 10
		
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.undo()
		value.int = 0
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.undo()
		value.inner.value = 1
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.undo()
		value.boolean = false
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.inner.value(100, operation: .amend)
		value.inner.value = 100
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.redo()
		value.boolean = true
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.redo()
		value.inner.value = 2
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.redo()
		value.int = 10
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.undo()
		value.int = 0
		XCTAssertEqual(resettable.wrappedValue, value)
	}
	
	func testAmendReferenceType() {
		let value = TestClass()
		let resettable = Resettable(value)
		
		resettable.inner.value(1)
		value.inner.value = 1
		
		resettable.boolean(true)
		value.boolean = true
		
		resettable.inner.value(2)
		value.inner.value = 2
		
		resettable.int(10)
		value.int = 10
		
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.undo()
		value.int = 0
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.undo()
		value.inner.value = 1
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.undo()
		value.boolean = false
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.inner.value(100, operation: .amend)
		value.inner.value = 100
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.redo()
		value.boolean = true
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.redo()
		value.inner.value = 2
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.redo()
		value.int = 10
		XCTAssertEqual(resettable.wrappedValue, value)
	}
	
	public func testAmendCollection() {
		struct Object: Equatable {
			let id: UUID = .init()
			var value: Int = 0
		}
		
		let first = Object(value: 0)
		var second = Object(value: 1)
		let third = Object(value: 2)
		let resettable = Resettable([first, second])
		
		resettable.collection.swapAt(0, 1)
		
		XCTAssertEqual(resettable.wrappedValue, [second, first])
		
		resettable.collection[safe: 0].value(0)
		second.value = 0
		
		XCTAssertEqual(resettable.wrappedValue, [second, first])
		
		resettable.undo()
		second.value = 1
		XCTAssertEqual(resettable.wrappedValue, [second, first])
		
		resettable.undo()
		XCTAssertEqual(resettable.wrappedValue, [first, second])
		
		resettable.collection.append(third, operation: .insert)
		
		XCTAssertEqual(resettable.wrappedValue, [first, second, third])
		
		resettable.redo()
		XCTAssertEqual(resettable.wrappedValue, [second, first, third])
	}
	
	func testInjectAndDump() {
		var value = TestStruct()
		let resettable = Resettable(value)
		
		resettable.int { $0 += 1 }
		resettable.int { $0 += 1 }
		resettable.int { $0 += 1 }
		value.int += 3
		
		resettable.undo(2)
		value.int -= 2
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.int(.inject) { $0 *= 3 }
		value.int *= 3
		XCTAssertEqual(resettable.wrappedValue, value)
		
		resettable.restore()
		value.int += 1
		value.int += 1
		XCTAssertEqual(resettable.wrappedValue, value)
		
		let expectedDump = #"""
		"""
		  ResettableTests.TestStruct(
		    inner: ResettableTests.TestStruct.Inner(value: 0),
		    boolean: false,
		    int: 0,
		    optional: nil
		  )

		  ResettableTests.TestStruct(
		    inner: ResettableTests.TestStruct.Inner(value: 0),
		    boolean: false,
		-   int: 0,
		+   int: 3,
		    optional: nil
		  )

		  ResettableTests.TestStruct(
		    inner: ResettableTests.TestStruct.Inner(value: 0),
		    boolean: false,
		-   int: 3,
		+   int: 4,
		    optional: nil
		  )

		  >>> ResettableTests.TestStruct(
		    inner: ResettableTests.TestStruct.Inner(value: 0),
		    boolean: false,
		-   int: 4,
		+   int: 5,
		    optional: nil
		  )
		"""
		"""#
		
		let actualDump = resettable.dump()
		XCTAssertEqual(expectedDump, actualDump)
	}
}
