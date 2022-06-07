# swift-foundation-extensions

[![SwiftPM 5.3](https://img.shields.io/badge/swiftpm-5.3-ED523F.svg?style=flat)](https://swift.org/download/) ![Platforms](https://img.shields.io/badge/Platforms-iOS_13_|_macOS_10.15_|_tvOS_14_|_watchOS_7-ED523F.svg?style=flat) [![@maximkrouk](https://img.shields.io/badge/contact-@capturecontext-1DA1F2.svg?style=flat&logo=twitter)](https://twitter.com/capture_context) 

Standard extensions for Foundation

> NOTE: The package is in beta (feel free suggest your improvements [here](https://github.com/capturecontext/swift-foundation-extensions/discussions/1))



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
  .branch("main")
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

