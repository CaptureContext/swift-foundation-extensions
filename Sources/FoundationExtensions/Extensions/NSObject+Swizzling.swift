public protocol NSObjectSwizzlingProtocol: NSObjectProtocol {}
extension NSObjectSwizzlingProtocol {
	/// Exchanges implementation of objc methods
	///
	/// Example:
	/// ```swift
	/// extension UIView {
	///   // Should be called manually to apply swizzling
	///   static func swizzle() {
	///     objc_exchangeImplementations(
	///       #selector(layoutSubviews),
	///       #selector(__swizzledLayoutSubviews)
	///     )
	///     // Swizzle other methods if needed
	///   }
	///
	///   @objc dynamic func __swizzledLayoutSubviews() {
	///     __swizzledLayoutSubviews() // call original implementation
	///     print("some logs")
  ///   }
	/// }
	/// ```
	///
	/// > For swift classes consider using Swift swizzling with
	/// > `@_dynamicReplacement`, but keep in mind that Swift
	/// > swizzling causes infinite recursion for objc methods and `async` functions
	/// >
	/// > Forum:
	/// > - [@_dynamicReplacement causes infinite recursion](
	///  https://forums.swift.org/t/dynamicreplacement-causes-infinite-recursion/52768
	/// )
	/// >
	/// > Swift issues:
	/// > - [@_dynamicReplacement could not call origin async method](
	///  https://github.com/apple/swift/issues/62214
	/// )
	/// > - [@_dynamicReplacement can't call the original method](
	///  https://github.com/apple/swift/issues/53916
	/// )
	///
	@available(*, deprecated, message: "Use `objc_exchangeImplementations(_,_,_)` instead")
	@inlinable
	public static func objc_exchangeImplementations(
		_ originalSelector: Selector,
		_ swizzledSelector: Selector
	) {
		objc_exchangeImplementations(
			originalSelector,
			swizzledSelector,
			using: class_getInstanceMethod
		)
	}

	/// Exchanges implementation of objc methods
	///
	/// Example:
	/// ```swift
	/// extension UIView {
	///   // Should be called manually to apply swizzling
	///   static func swizzle() {
	///     objc_exchangeImplementations(
	///       #selector(layoutSubviews),
	///       #selector(__swizzledLayoutSubviews),
	///       using: class_getInstanceMethod
	///     )
	///     // Swizzle other methods if needed
	///   }
	///
	///   @objc dynamic func __swizzledLayoutSubviews() {
	///     __swizzledLayoutSubviews() // call original implementation
	///     print("some logs")
	///   }
	/// }
	/// ```
	///
	/// > For swift classes consider using Swift swizzling with
	/// > `@_dynamicReplacement`, but keep in mind that Swift
	/// > swizzling causes infinite recursion for objc methods and `async` functions
	/// >
	/// > Forum:
	/// > - [@_dynamicReplacement causes infinite recursion](
	///  https://forums.swift.org/t/dynamicreplacement-causes-infinite-recursion/52768
	/// )
	/// >
	/// > Swift issues:
	/// > - [@_dynamicReplacement could not call origin async method](
	///  https://github.com/apple/swift/issues/62214
	/// )
	/// > - [@_dynamicReplacement can't call the original method](
	///  https://github.com/apple/swift/issues/53916
	/// )
	///
	@inlinable
	@discardableResult
	public static func objc_exchangeImplementations(
		_ originalSelector: Selector,
		_ swizzledSelector: Selector,
		using extractMethod: (AnyClass?, Selector) -> Method?
	) -> Bool {
		let originalMethod = extractMethod(
			Self.self,
			originalSelector
		)

		let swizzledMethod = extractMethod(
			Self.self,
			swizzledSelector
		)

		guard
			let originalMethod,
			let swizzledMethod
		else { return false }

		method_exchangeImplementations(originalMethod, swizzledMethod)
		return true
	}
}

extension NSObject: NSObjectSwizzlingProtocol {}
