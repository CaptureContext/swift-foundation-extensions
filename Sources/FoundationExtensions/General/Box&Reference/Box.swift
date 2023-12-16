import Foundation

@propertyWrapper
@dynamicMemberLookup
final public class Box<Content> {
	public var content: Content
	
	@inlinable
	public var wrappedValue: Content {
		get { content }
		set { content = newValue }
	}
	
	@inlinable
	public convenience init<T>() where Content == T? {
		self.init(wrappedValue: nil)
	}
	
	@inlinable
	public convenience init(_ wrappedValue: Content) {
		self.init(wrappedValue: wrappedValue)
	}
	
	public init(wrappedValue: Content) {
		self.content = wrappedValue
	}
	
	@inlinable
	public var projectedValue: Reference<Content> { reference }
	
	@inlinable
	public var reference: Reference<Content> {
		.object(self, keyPath: \.wrappedValue)
	}
	
	@inlinable
	public subscript<U>(dynamicMember keyPath: KeyPath<Content, U>) -> U {
		get { self.wrappedValue[keyPath: keyPath] }
	}
	
	@inlinable
	public subscript<U>(dynamicMember keyPath: WritableKeyPath<Content, U>) -> U {
		get { self.wrappedValue[keyPath: keyPath] }
		set { self.wrappedValue[keyPath: keyPath] = newValue }
	}
	
	@inlinable
	public subscript<U>(dynamicMember keyPath: ReferenceWritableKeyPath<Content, U>) -> U {
		get { self.wrappedValue[keyPath: keyPath] }
		set { self.wrappedValue[keyPath: keyPath] = newValue }
	}
}
