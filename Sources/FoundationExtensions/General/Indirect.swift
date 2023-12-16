import Foundation

/// CoW container, that allows you to wrap structs recursively
///
/// Usage:
/// ```
/// public struct User {
///     internal init(id: UUID, favoriteFollower: User?) {
///         self.id = id
///         self._favoriteFollower = Indirect(favoriteFollower)
///     }
///     public var id: UUID
///
///     @Indirect
///     public var favoriteFollower: User?
/// }
///
/// var user = User(id: UUID(), favoriteFollower: User(id: UUID()))
/// user.favoriteFollower?.id
/// ```
/// Note: Codable stuff behaviour is not tested for propertyWrapper style, maybe u should consider
/// using `var favoriteFollower: Indirect<User?>`.
///
@propertyWrapper
@dynamicMemberLookup
public struct Indirect<Value> {
	@usableFromInline
	class Storage: @unchecked Sendable {
		@usableFromInline
		var value: Value

		@usableFromInline
		init(_ value: Value) {
			self.value = value
		}
	}

	@usableFromInline
	var storage: Storage

	@inlinable
	public init(_ value: Value) {
		self.init(wrappedValue: value)
	}

	@inlinable
	public init(wrappedValue: Value) {
		self.storage = .init(wrappedValue)
	}

	@inlinable
	public var wrappedValue: Value {
		get { storage.value }
		set {
			if !isKnownUniquelyReferenced(&storage) {
				storage = Storage(storage.value)
			}
			storage.value = newValue
		}
	}

	@inlinable
	public var projectedValue: Self {
		get { self }
		set { self = newValue }
	}

	@inlinable
	public subscript<T>(dynamicMember keyPath: KeyPath<Value, T>) -> T {
		wrappedValue[keyPath: keyPath]
	}

	@inlinable
	public subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> T {
		get { wrappedValue[keyPath: keyPath] }
		set { wrappedValue[keyPath: keyPath] = newValue }
	}

	/// Assigns the new value directly to internal CoW storage
	@inlinable
	public func _setValue(_ value: Value) {
		storage.value = value
	}

	/// Modifies internal CoW  storage value directly
	@inlinable
	public func _modifyValue(_ transform: (inout Value) -> Void) {
		transform(&storage.value)
	}

	/// Checks if internal CoW  storage is shared with other value
	@inlinable
	public func _sharesStorage(with other: Self) -> Bool {
		storage === other.storage
	}
}

extension Indirect: Sendable where Value: Sendable {}

extension Indirect: Equatable where Value: Equatable {
	@inlinable
	public static func ==(lhs: Self, rhs: Self) -> Bool {
		lhs.wrappedValue == rhs.wrappedValue
	}
}

extension Indirect: Hashable where Value: Hashable {
	@inlinable
	public func hash(into hasher: inout Hasher) {
		wrappedValue.hash(into: &hasher)
	}
}

extension Indirect: Comparable where Value: Comparable {
	@inlinable
	public static func <(lhs: Self, rhs: Self) -> Bool {
		lhs.wrappedValue < rhs.wrappedValue
	}
}

extension Indirect: Decodable where Value: Decodable {
	@inlinable
	public init(from decoder: Decoder) throws {
		try self.init(.init(from: decoder))
	}
}

extension Indirect: Encodable where Value: Encodable {
	@inlinable
	public func encode(to encoder: Encoder) throws {
		try wrappedValue.encode(to: encoder)
	}
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Indirect: Identifiable where Value: Identifiable {
	@inlinable
	public var id: Value.ID { wrappedValue.id }
}

