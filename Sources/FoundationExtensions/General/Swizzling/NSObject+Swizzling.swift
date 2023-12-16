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
	public static func objc_exchangeImplementations(
		_ originalSelector: Selector,
		_ swizzledSelector: Selector
	) {
		let originalMethod = class_getInstanceMethod(
			Self.self,
			originalSelector
		)

		let swizzledMethod = class_getInstanceMethod(
			Self.self,
			swizzledSelector
		)

		guard
			let originalMethod,
			let swizzledMethod
		else { return }

		method_exchangeImplementations(originalMethod, swizzledMethod)
	}
}

extension NSObject: NSObjectSwizzlingProtocol {}
