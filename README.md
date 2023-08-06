# swift-foundation-extensions

[![SwiftPM 5.6](https://img.shields.io/badge/swiftpm-5.8-ED523F.svg?style=flat)](https://swift.org/download/) ![Platforms](https://img.shields.io/badge/Platforms-iOS_13_|_macOS_10.15_|_tvOS_14_|_watchOS_7-ED523F.svg?style=flat) [![@maximkrouk](https://img.shields.io/badge/contact-@capturecontext-1DA1F2.svg?style=flat&logo=twitter)](https://twitter.com/capture_context) 

Standard extensions for Foundation

> NOTE: The package is in beta (feel free suggest your improvements [here](https://github.com/capturecontext/swift-foundation-extensions/discussions/1))

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
  name: "swift-foundation-extensions",
  url: "https://github.com/capturecontext/swift-foundation-extensions.git", 
  .upToNextMinor(from: "0.2.0")
)
```

Do not forget about target dependencies:

```swift
.product(
  name: "FoundationExtensions", 
  package: "swift-foundation-extensions"
)
```


## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
