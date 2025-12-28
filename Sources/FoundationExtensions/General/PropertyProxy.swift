// https://www.swiftbysundell.com/articles/accessing-a-swift-property-wrappers-enclosing-instance/

import Foundation

@propertyWrapper
public struct PropertyProxy<Object: AnyObject, Value> {
	public static subscript(
		_enclosingInstance instance: Object,
		wrapped wrappedKeyPath: ReferenceWritableKeyPath<Object, Value>,
		storage storageKeyPath: ReferenceWritableKeyPath<Object, Self>
	) -> Value {
		get {
			let wrapped = instance[keyPath: storageKeyPath]
			return instance[keyPath: wrapped.keyPath]
		}
		set {
			let wrapper = instance[keyPath: storageKeyPath]
			instance[keyPath: wrapper.keyPath] = newValue
		}
	}

	private let keyPath: ReferenceWritableKeyPath<Object, Value>

	@available(*, unavailable, message: "@PropertyProxy can only be applied to classes")
	public var wrappedValue: Value {
		get { fatalError() }
		set { fatalError() }
	}

	public init(_ keyPath: ReferenceWritableKeyPath<Object, Value>) {
		self.keyPath = keyPath
	}
}

@propertyWrapper
public struct ReadonlyPropertyProxy<Object: AnyObject, Value> {
	public static subscript(
		_enclosingInstance instance: Object,
		wrapped wrappedKeyPath: KeyPath<Object, Value>,
		storage storageKeyPath: KeyPath<Object, Self>
	) -> Value {
		get {
			let wrapped = instance[keyPath: storageKeyPath]
			return instance[keyPath: wrapped.keyPath]
		}
	}

	private let keyPath: KeyPath<Object, Value>

	@available(*, unavailable, message: "@PropertyProxy can only be applied to classes")
	public var wrappedValue: Value {
		get { fatalError() }
		set { fatalError() }
	}

	public init(_ keyPath: KeyPath<Object, Value>) {
		self.keyPath = keyPath
	}
}
