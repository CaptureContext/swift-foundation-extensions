# swift-foundation-extensions

[![CI](https://github.com/capturecontext/swift-foundation-extensions/actions/workflows/ci.yml/badge.svg)](https://github.com/capturecontext/swift-foundation-extensions/actions/workflows/ci.yml) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcapturecontext%2Fswift-foundation-extensions%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/capturecontext/swift-foundation-extensions) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcapturecontext%2Fswift-foundation-extensions%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/capturecontext/swift-foundation-extensions)

Standard extensions for Foundation framework

- [Documentation](https://swiftpackageindex.com/capturecontext/swift-foundation-extensions/0.5.0/documentation/foundationextensions)
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
- [License](#license)

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
  
  @ReadonlyPropertyProxy(\MyView.label.text)
  var readonlyText: String?
}

let view: MyView = .init()
view.label.text // ❌
view.text = "Hello, World!"
```

### Swizzling

This package also provides some sugar for objc method swizzling

> [!NOTE]
>
> _The package is compatible with non-Apple platforms, however it uses conditional compilation, so **`Swizzling` APIs are only available on Apple platforms**_

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

### More

More extensions can be found in sources.

### Equated

> [!WARNING]
>
> `FoundationExtensions` simply exports `Equated` for backwards compatibility
>
> It's likely to be removed in favor of a separate package [swift-equated](https://github.com/capturecontext/swift-equated), see it's readme for more info

### Undo/Redo management

> [!WARNING]
>
> `FoundationExtensions` simply exports `Resettable` for backwards compatibility
>
> It's likely to be removed in favor of a separate package [swift-resettable](https://github.com/capturecontext/swift-resettable), see it's readme for more info

### Object Association

> [!WARNING]
>
> `FoundationExtensions` simply exports `AssociatedObjects`
>
> `FoundationExtensionsMacros` simply exports `AssociatedObjectsMacros`
>
> Likely to be removed in favor of a separate package [swift-associated-objects](https://github.com/capturecontext/swift-associated-objects)

## Installation

### Basic

You can add `swift-foundation-extensions` to an Xcode project by adding it as a package dependency.

1. From the **File** menu, select **Swift Packages › Add Package Dependency…**
2. Enter [`"https://github.com/capturecontext/swift-foundation-extensions"`](https://github.com/capturecontext/swift-foundation-extensions) into the package repository URL text field
3. Choose products you need to link to your project.

### Recommended

If you use SwiftPM for your project structure, add `swift-foundation-extensions` dependency to your package file

```swift
.package(
  url: "https://github.com/capturecontext/swift-foundation-extensions.git", 
  .upToNextMinor("0.6.9")
)
```

Do not forget about target dependencies

```swift
.product(
  name: "<#Product#>", 
  package: "swift-foundation-extensions"
)
```

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
