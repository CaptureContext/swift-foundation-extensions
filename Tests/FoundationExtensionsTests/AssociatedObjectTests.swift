import XCTest
@testable import FoundationExtensions

class Object {}
extension Object {
  @AssociatedObject
  var didSetStoredValue: ((Int?) -> Void)?

  @AssociatedObject
  var willSetStoredValue: ((Int?) -> Void)?

  @AssociatedObject
  var storedValue: Int = 0 {
    willSet { willSetStoredValue?(newValue) }
    didSet { didSetStoredValue?(storedValue) }
  }
}

final class AssociatedObjectTests: XCTestCase {
  func testMain() {
    let object = Object()

    var value = (
      initial: object.storedValue,
      trackedWillSet: Int?.some(0),
      trackedWillSetCalls: 0,
      trackedDidSet: Int?.some(0),
      trackedDidSetCalls: 0
    )

    object.willSetStoredValue = { [weak object] in
      value.trackedWillSet = $0
      XCTAssertEqual(object?.storedValue, value.trackedDidSet)

      value.trackedWillSetCalls += 1
      XCTAssertEqual(value.trackedDidSetCalls, value.trackedWillSetCalls - 1)
    }
    object.didSetStoredValue = {
      XCTAssertEqual(value.trackedWillSet, $0)
      value.trackedDidSet = $0
      value.trackedDidSetCalls += 1
      XCTAssertEqual(value.trackedDidSetCalls, value.trackedWillSetCalls)
    }

    XCTAssertEqual(object.storedValue, 0)

    object.storedValue = 1
    XCTAssertEqual(object.storedValue, 1)
    XCTAssertEqual(value.trackedDidSetCalls, 1)

    object.storedValue = 69
    XCTAssertEqual(object.storedValue, 69)
    XCTAssertEqual(value.trackedDidSetCalls, 2)

    object.storedValue = 0
    XCTAssertEqual(object.storedValue, 0)
    XCTAssertEqual(value.trackedDidSetCalls, 3)
  }
}
