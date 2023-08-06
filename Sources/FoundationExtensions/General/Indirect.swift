import Foundation

/// CoW container, that allows you to wrap structs recoursively
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
  class Storage {
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
      if isKnownUniquelyReferenced(&storage) {
        storage.value = newValue
      } else {
        storage = Storage(newValue)
      }
    }
  }

  @inlinable
  public var projectedValue: Self { self }

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
}

extension Indirect: Comparable where Value: Comparable {
  @inlinable
  public static func <(lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue < rhs.wrappedValue
  }
}

extension Indirect: Hashable where Value: Hashable {
  @inlinable
  public func hash(into hasher: inout Hasher) {
    wrappedValue.hash(into: &hasher)
  }
}

extension Indirect: Equatable where Value: Equatable {
  @inlinable
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension Indirect: Codable where Value: Codable {
  @inlinable
  public init(from decoder: Decoder) throws {
    try self.init(.init(from: decoder))
  }

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
