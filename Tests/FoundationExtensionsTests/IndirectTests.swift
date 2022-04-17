import XCTest
@testable import FoundationExtensions

final class IndirectTests: XCTestCase {
  func testMain() {
    struct LinkedListNode<Value: Equatable>: Equatable {
      var value: Value
      @Indirect
      var next: LinkedListNode?
    }
    
    var root = LinkedListNode<Int>(value: 0)
    let first = LinkedListNode<Int>(value: 1)
    let second = LinkedListNode<Int>(value: 2)
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
    
    // value semantics
    XCTAssertEqual(
      first,
      LinkedListNode(value: 1)
    )
  }
}
