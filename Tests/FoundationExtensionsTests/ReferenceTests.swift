import XCTest
@testable import FoundationExtensions

final class ReferenceTests: XCTestCase {
  func testAssociatingObject() {
    class Obj: AssociatingObject {}
    let obj = Obj()
    let value = 1
    
    class _Obj: AssociatingObject {}
    let _obj = _Obj()
    let _value = 2
    
    XCTAssertNil(obj.getAssociatedObject(of: Int.self, forKey: "value"))
    XCTAssertTrue(obj.setAssociatedObject(value, forKey: "value"))
    XCTAssertEqual(obj.getAssociatedObject(forKey: "value"), value)
    
    XCTAssertNil(_obj.getAssociatedObject(of: Int.self, forKey: "value"))
    XCTAssertTrue(_obj.setAssociatedObject(_value, forKey: "value"))
    XCTAssertEqual(_obj.getAssociatedObject(forKey: "value"), _value)
    
    XCTAssertEqual(obj.getAssociatedObject(forKey: "value"), value)
  }
  
  func testAssociatingNSObject() {
    class Obj: NSObject {}
    let obj = Obj()
    
    let value = 1
    XCTAssertEqual(obj.getAssociatedObject(of: Int.self, forKey: "value"), nil)
    
    obj.setAssociatedObject(value, forKey: "value")
    XCTAssertEqual(obj.getAssociatedObject(forKey: "value"), value)
  }
  
  func testReferenceObservation() {
    class Object: ReferenceProvider {
      var value = 0
    }
    
    let object = Object()
    let reference = object.reference(for: \.value)
    
    var handledOnChange: Int?
    var numberOfTrackedChanges = 0
    var numberOfTrackedSets = 0
    let trackedReference = reference.onChange {
      handledOnChange = $0
      numberOfTrackedChanges += 1
    }.onSet { _ in
      numberOfTrackedSets += 1
    }
    
    object.value = 1
    
    XCTAssertEqual(object.value, reference.wrappedValue)
    XCTAssertEqual(object.value, trackedReference.wrappedValue)
    
    // Reference does not handle direct object changes
    XCTAssertEqual(handledOnChange, nil)
    XCTAssertEqual(numberOfTrackedSets, 0)
    XCTAssertEqual(numberOfTrackedChanges, 0)
    
    trackedReference.wrappedValue = 2
    
    XCTAssertEqual(object.value, 2)
    XCTAssertEqual(object.value, reference.wrappedValue)
    XCTAssertEqual(object.value, trackedReference.wrappedValue)
    XCTAssertEqual(object.value, handledOnChange)
    XCTAssertEqual(numberOfTrackedSets, 1)
    XCTAssertEqual(numberOfTrackedChanges, 1)
    
    trackedReference.wrappedValue = 2
    
    XCTAssertEqual(object.value, 2)
    XCTAssertEqual(object.value, reference.wrappedValue)
    XCTAssertEqual(object.value, trackedReference.wrappedValue)
    XCTAssertEqual(object.value, handledOnChange)
    XCTAssertEqual(numberOfTrackedSets, 2)
    XCTAssertEqual(numberOfTrackedChanges, 1)
  }
}
