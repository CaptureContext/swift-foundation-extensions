import XCTest
@testable import FoundationExtensions

final class AssociatingObjectTests: XCTestCase {
	func testMain() {
		struct Struct: Equatable {
			var value: Int
		}
		class CustomObject {}
		class CustomNSObject: NSObject {}
		class CustomAssociatingObject: AssociatingObject {
			var _struct: Struct {
				get { getAssociatedObject(forKey: #function).or(.init(value: 0)) }
				set { setAssociatedObject(newValue, forKey: #function)}
			}
		}
		
		let nsObject = NSObject()
		let customObject = CustomObject()
		let customNSObject = CustomNSObject()
		let customAssociatingObject = CustomAssociatingObject()
		
		// simple check for struct storage
		XCTAssertEqual(customAssociatingObject._struct, .init(value: 0))
		
		customAssociatingObject._struct.value = 1
		XCTAssertEqual(customAssociatingObject._struct, .init(value: 1))
		
		nsObject.setAssociatedObject(91, forKey: "value")
		customNSObject.setAssociatedObject(92, forKey: "value")
		customAssociatingObject.setAssociatedObject(93, forKey: "value")
		_setAssociatedObject(94, to: customObject, forKey: "value")
		
		// check if set overrides values on different objects
		
		nsObject.setAssociatedObject(91, forKey: "value")
		customNSObject.setAssociatedObject(92, forKey: "value")
		customAssociatingObject.setAssociatedObject(93, forKey: "value")
		_setAssociatedObject(94, to: customObject, forKey: "value")
		
		XCTAssertEqual(91, nsObject.getAssociatedObject(forKey: "value"))
		XCTAssertEqual(92, customNSObject.getAssociatedObject(forKey: "value"))
		XCTAssertEqual(93, customAssociatingObject.getAssociatedObject(forKey: "value"))
		XCTAssertEqual(94, _getAssociatedObject(forKey: "value", from: customObject))
		
		// check if prev value is removed if the new one of other type is set
		
		nsObject.setAssociatedObject("test", forKey: "value")
		XCTAssertEqual("test", nsObject.getAssociatedObject(forKey: "value"))
		XCTAssertEqual(Int?.none, nsObject.getAssociatedObject(forKey: "value"))
		
		// test set and get in different independent functions
		
		nsObject.setAssociatedObject("0", forKey: "zero")
		XCTAssertEqual("0", getValueForKey_zero(from: nsObject))
		
		setZeroForKey_zero(to: nsObject)
		XCTAssertEqual(0, getValueForKey_zero(from: nsObject))
		XCTAssert(getValueForKey_zero(of: Any.self, from: customObject).isNil)
	}
	
	func testStaticStringAddress() {
		let a: StaticString = #function
		let b: StaticString = #function
		let c: StaticString = "testStaticStringAddress()"
		let d: StaticString = "testStaticStringAddress()"
		let f: StaticString = "other"
		
		func getBaseAddress(for key: StaticString) -> String? {
			key.withUTF8Buffer { pointer in
				pointer.baseAddress.map(UnsafeRawPointer.init).map(\.debugDescription)
			}
		}
		
		XCTAssertEqual(a.description, b.description)
		XCTAssertEqual(getBaseAddress(for: a), getBaseAddress(for: b))
		
		XCTAssertEqual(c.description, d.description)
		XCTAssertEqual(getBaseAddress(for: c), getBaseAddress(for: d))
		
		XCTAssertEqual(a.description, c.description)
		XCTAssertEqual(getBaseAddress(for: a), getBaseAddress(for: c))
		
		XCTAssertNotEqual(a.description, f.description)
		XCTAssertNotEqual(getBaseAddress(for: a), getBaseAddress(for: f))
	}
}

fileprivate func setZeroForKey_zero(to object: AnyObject) {
	_setAssociatedObject(0, to: object, forKey: "zero")
}

fileprivate func getValueForKey_zero<T>(
	of type: T.Type = T.self,
	from object: AnyObject
) -> T? {
	_getAssociatedObject(forKey: "zero", from: object)
}
