# swift-foundation-extensions

[![CI](https://github.com/CaptureContext/swift-foundation-extensions/actions/workflows/ci.yml/badge.svg)](https://github.com/CaptureContext/swift-foundation-extensions/actions/workflows/ci.yml) [![SwiftPM 5.9](https://img.shields.io/badge/swiftpm-5.9-ED523F.svg?style=flat)](https://swift.org/download/) ![Platforms](https://img.shields.io/badge/Platforms-iOS_13_|_macOS_10.15_|_tvOS_14_|_watchOS_7-ED523F.svg?style=flat) [![@capture_context](https://img.shields.io/badge/contact-@capturecontext-1DA1F2.svg?style=flat&logo=twitter)](https://twitter.com/capture_context) 

Standard extensions for Foundation framework

- [Documentation](https://swiftpackageindex.com/CaptureContext/swift-foundation-extensions/0.5.0/documentation/foundationextensions)
- [Contents](#contents)
  - [Coding](#coding)
  - [NSLocking](#nslocking)
  - [Optional](#optional)
  - [Undo/Redo management](#undoredo-management)
  - [Indirect](#indirect)
  - [Property Proxy](#property-proxy)
  - [Object Association](#object-Association)
  - [Swizzling](#swizzling)
- [Installation](#installation)
  - [Basic](#basic)
  - [Recommended](#recommended)
- [Licence](#licence)

## Contents

### Coding

- RawCodingKey allows you to create CodingKeys from literals

- Extensions for encoder and decoder allow you to create an object with a contextual container

- Extensions for coding containers automatically infer type from context

```swift
init(from decoder: Decoder) throws {
  self = try container.decode(RawCodingKey.self) { container in
    return .init(
      someProperty1: container.decode("someProperty1"),
      someProperty2: container.decode("some_property_2")
    )
  }
}

func encode(to encoder: encoder) throws {
  try encoder.encode(RawCodingKey.self) { container in
    try container.encode(someProperty1, forKey: "someProperty1")
    try container.encode(someProperty2, forKey: "some_property_2")
  }
}
```

### NSLocking

- `store(_:in:)` - stores value in some variable in locked context
- `mutate(_:with:)` - passes given object to locked context
- `assign(_:to:on:)` - stores value in object property in locked context
- `execute(_:)` - provides new locked context

### Optional

- `orThrow(_:)` - unwraps an optional or throws specified error
- `isNil` / `isNotNil` / `isNilOrEmpty`
- `or()` - coalesing alias
- `unwrap()` - returns unwrapping Result
- `assign(to:on:)` - assigns wrapped value to a specified target property by the keyPath
- `ifLetAssign(to:on:)` - assigns wrapped value to a specified target property by the keyPath if an optional was not nil

### Undo/Redo management

```swift
struct State {
  var value: Int = 0
}

@Resettable
let state = State()
state.value = 1   // value == 1
state.value *= 10 // value == 10
state.undo()      // value == 1
state.value += 1  // value == 2
state.undo()      // value == 1
state.redo()      // value == 2
```

### Indirect

CoW container, which allows you to recursively include single instances of value types

```swift
struct ListNode<Value> {
  var value: Value
  
	@Indirect
  var next: ListNode<Value>?
}
```



### PropertyProxy

```swift
class MyView: UIView {
  private let label: UILabel
  
  @PropertyProxy(\MyView.label.text)
  var text: String?
}

let view: MyView = .init()
view.label.text // ❌
view.text = "Hello, World!"
```

### Object Association

Basic helpers for object association are available in a base package

```swift
extension UIViewController {
  var someStoredProperty: Int {
    get { getAssociatedObject(forKey: #function).or(0) }
    set { setAssociatedObject(newValue, forKey: #function)  }
  }
}

let value: Bool = getAssociatedObject(forKey: "value", from: object)
```

But the full power of associated objects is provided by `FoundationExtensionsMacros` target

> By default `@AssociatedObject` macro uses `.retain(.nonatomic)` for classes and `.copy(.nonatomic)` `objc_AssociationPolicy` for structs.

```swift
import FoundationExtensionsMacros

extension SomeClass {
  @AssociatedObject
  var storedVariableInExtension: Int = 0
  
  @AssociatedObject(readonly: true)
  var storedVariableInExtension: SomeObject = .init()
  
  @AssociatedObject
  var optionalValue: Int?
  
  @AssociatedObject
  var object: Int?
    
  @AssociatedObject(threadSafety: .atomic)
  var threadSafeValue: Int?
    
  @AssociatedObject(threadSafety: .atomic)
  var threadSafeObject: Object?
    
  @AssociatedObject(policy: .assign)
  var customPolicyValue: Int?
    
  @AssociatedObject(policy: .retain(.atomic))
  var customPolicyThreadSafeObject: Object?
}
```

> Macros require swift-syntax compilation, so it will affect cold compilation time

### Swizzling

This package also provides some sugar for objc method swizzling

```swift
extension UIViewController {
  // Runs once in app lifetime
  // Repeated calls do nothing
  private static let swizzle: Void = {
    // This example is not really representative since these methods
    // can be simply globally overriden, but it's just an example
    // for the readme and you can find live example at
    // https://github.com/capturecontext/combine-cocoa-navigation
    
    objc_exchangeImplementations(
    	#selector(viewWillAppear)
      #selector(__swizzledViewWillAppear)
    )
    
    objc_exchangeImplementations(
    	#selector(viewDidAppear)
      #selector(__swizzledViewDidAppear)
    )
  }()

  @objc dynamic
  private func __swizzledViewWillAppear(_ animated: Bool) {
    __swizzledViewWillAppear(animated) // calls original method
    print(type(of: self), ObjectIdentifier(self), "will appear")
  }

  @objc dynamic
  private func __swizzledViewDidAppear(_ animated: Bool) {
    __swizzledViewDidAppear(animated) // calls original method
    print(type(of: self), ObjectIdentifier(self), "did appear")
  }
}
```

## Installation

### Basic

You can add FoundationExtensions to an Xcode project by adding it as a package dependency.

1. From the **File** menu, select **Swift Packages › Add Package Dependency…**
2. Enter [`"https://github.com/capturecontext/swift-foundation-extensions.git"`](https://github.com/capturecontext/swift-foundation-extensions.git) into the package repository URL text field
3. Choose products you need to link them to your project.

### Recommended

If you use SwiftPM for your project, you can add StandardExtensions to your package file.

```swift
.package(
  url: "https://github.com/capturecontext/swift-foundation-extensions.git", 
  .upToNextMinor(from: "0.5.0")
)
```

Do not forget about target dependencies:

```swift
.product(
  name: "FoundationExtensions", 
  package: "swift-foundation-extensions"
)
```

```swift
.product(
  name: "FoundationExtensionsMacros", 
  package: "swift-foundation-extensions"
)
```



## License

This library is released under the MIT license. See [LICENCE](LICENCE) for details.
