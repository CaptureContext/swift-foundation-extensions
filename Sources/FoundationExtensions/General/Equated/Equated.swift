import Foundation

@propertyWrapper
public struct Equated<Value>: Equatable {
  @inlinable
  public init<T>(by comparator: Comparator) where Value == T? {
    self.init(.none, by: comparator)
  }

  @inlinable
  public init(_ wrappedValue: Value, by comparator: Comparator) {
    self.init(wrappedValue: wrappedValue, by: comparator)
  }

  @inlinable
  public init(wrappedValue: Value, by comparator: Comparator) {
    self.wrappedValue = wrappedValue
    self.comparator = comparator
  }

  public var wrappedValue: Value
  public var comparator: Comparator

  @inlinable
  public static func == (lhs: Equated<Value>, rhs: Equated<Value>) -> Bool {
    lhs.comparator.compare(lhs.wrappedValue, rhs.wrappedValue)
      && rhs.comparator.compare(rhs.wrappedValue, lhs.wrappedValue)
  }
}

extension Equated where Value: Equatable {
  @inlinable
  public init<T>() where Value == T? {
    self.init(wrappedValue: .none)
  }

  @inlinable
  public init(wrappedValue: Value) {
    self.init(wrappedValue, by: .custom(==))
  }
}

extension Equated: Error where Value: Error {
  @inlinable
  public init(_ wrappedValue: Value) {
    self.init(wrappedValue: wrappedValue)
  }

  @inlinable
  public init(wrappedValue: Value) {
    self.init(
      wrappedValue: wrappedValue,
      by: .localizedDescription
    )
  }

  @inlinable
  public var localizedDescription: String { wrappedValue.localizedDescription }
}

extension Equated: Hashable where Value: Hashable {
  @inlinable
  public func hash(into hasher: inout Hasher) {
    wrappedValue.hash(into: &hasher)
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Equated: Identifiable where Value: Identifiable {
  @inlinable
  public var id: Value.ID { wrappedValue.id }
}
