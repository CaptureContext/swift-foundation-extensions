import Foundation

extension NSLocking {
	/// Atomically stores new value in object
	@inlinable
	public func store<T>(_ value: T, in object: inout T) {
		mutate(&object, with: { $0 = value })
	}

	/// Atomically mutates object with closure
	@inlinable
	public func mutate<T: AnyObject>(_ object: T, with closure: (T) -> Void) {
		execute { closure(object) }
	}

	/// Atomically mutates object with closure
	@inlinable
	public func mutate<T>(_ object: inout T, with closure: (inout T) -> Void) {
		execute { closure(&object) }
	}

	/// Atomically assigns value to specified object property
	@inlinable
	public func assign<T: AnyObject, Value>(
		_ value: Value,
		to keyPath: ReferenceWritableKeyPath<T, Value>,
		on object: T
	) {
		execute { object[keyPath: keyPath] = value }
	}

	/// Atomically assigns value to specified object property
	@inlinable
	public func assign<T, Value>(
		_ value: Value,
		to keyPath: WritableKeyPath<T, Value>,
		on object: inout T
	) {
		execute { object[keyPath: keyPath] = value }
	}

	/// Atomically executes the block of code
	@discardableResult
	@inlinable
	public func execute<T>(_ closure: () -> T) -> T {
		withLock(closure)
	}

}
