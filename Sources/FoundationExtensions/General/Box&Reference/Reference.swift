import Foundation

#if canImport(Combine)
import Combine
#endif

extension ReadonlyReference {
  @inlinable
  public static func constant(_ value: Value) -> ReadonlyReference {
    ReadonlyReference { value }
  }
  
  @inlinable
  public static func object<Object: AnyObject>(_ object: Object, read: @escaping (Object) -> Value)
    -> ReadonlyReference
  {
    ReadonlyReference(read: { read(object) })
  }
}

@propertyWrapper
@dynamicMemberLookup
public struct ReadonlyReference<Value> {
  @usableFromInline
  internal var _read: () -> Value

  @inlinable
  public init(wrappedValue: Value) {
    self.init(read: { wrappedValue })
  }

  public init(read: @escaping () -> Value) {
    self._read = read
  }

  @inlinable
  public var wrappedValue: Value {
    self._read()
  }

  @inlinable
  public var projectedValue: ReadonlyReference {
    ReadonlyReference(read: _read)
  }

  @inlinable
  public var asWritable: Reference<Value> {
    Reference(read: _read, write: { _ in })
  }

  @inlinable
  public func writable(with write: @escaping (Value) -> Void) -> Reference<Value> {
    Reference(read: _read, write: write)
  }

  @inlinable
  public subscript<LocalValue>(dynamicMember keyPath: KeyPath<Value, LocalValue>) -> Reference<
    LocalValue
  > {
    .readonly { wrappedValue[keyPath: keyPath] }
  }
  
  @inlinable
  public subscript<LocalValue>(dynamicMember keyPath: ReferenceWritableKeyPath<Value, LocalValue>) -> Reference<
    LocalValue
  > {
    Reference(
      read: { _read()[keyPath: keyPath] },
      write: { _read()[keyPath: keyPath] = $0 })
  }
}

extension Reference {
  @inlinable
  public static func readonly(_ read: @escaping () -> Value) -> Reference {
    Reference(read: read, write: { _ in })
  }

  @inlinable
  public static func object<Object: AnyObject>(_ object: Object, read: @escaping (Object) -> Value)
    -> Reference
  {
    .readonly { read(object) }
  }

  @inlinable
  public static func object<Object: AnyObject>(
    _ object: Object,
    keyPath: ReferenceWritableKeyPath<Object, Value>
  ) -> Reference {
    Reference(
      read: { object[keyPath: keyPath] },
      write: { object[keyPath: keyPath] = $0 }
    )
  }

  @inlinable
  public static func variable(_ initialValue: Value) -> Reference {
    Reference(wrappedValue: initialValue)
  }

  @inlinable
  public static func constant(_ value: Value) -> Reference {
    .readonly { value }
  }
}

@propertyWrapper
@dynamicMemberLookup
public struct Reference<Value> {
  @usableFromInline
  internal var _read: () -> Value

  @usableFromInline
  internal var _write: (Value) -> Void

  @inlinable
  public init(wrappedValue: Value) {
    var value = wrappedValue
    self.init(
      read: { value },
      write: { value = $0 }
    )
  }

  public init(
    read: @escaping () -> Value,
    write: @escaping (Value) -> Void
  ) {
    self._read = read
    self._write = write
  }

  @inlinable
  public func read() -> Value { _read() }

  @inlinable
  public func write(_ value: Value) { _write(value) }

  @inlinable
  public var wrappedValue: Value {
    get { _read() }
    nonmutating set { _write(newValue) }
  }

  @inlinable
  public var projectedValue: Reference {
    Reference(read: _read, write: _write)
  }

  @inlinable
  public var readonly: ReadonlyReference<Value> { ReadonlyReference(read: _read) }

  @inlinable
  public subscript<LocalValue>(
    dynamicMember keyPath: KeyPath<Value, LocalValue>
  ) -> Reference<LocalValue> {
    .readonly { wrappedValue[keyPath: keyPath] }
  }

  @inlinable
  public subscript<LocalValue>(
    dynamicMember keyPath: WritableKeyPath<Value, LocalValue>
  ) -> Reference<LocalValue> {
    Reference<LocalValue>(
      read: { _read()[keyPath: keyPath] },
      write: { localValue in
        var value = _read()
        value[keyPath: keyPath] = localValue
        _write(value)
      }
    )
  }
}

extension Reference {
  public func map<T>(
    read: @escaping (Value) -> T,
    write: @escaping (T) -> Value
  ) -> Reference<T> {
    Reference<T>(
      read: { read(_read()) },
      write: { _write(write($0)) }
    )
  }
  
  public func onSet(perform action: @escaping (Value) -> Void) -> Reference {
    Reference(
      read: _read,
      write: { newValue in
        _write(newValue)
        action(newValue)
      }
    )
  }
  
  public func onChange(perform action: @escaping (Value) -> Void) -> Reference
  where Value: Equatable {
    Reference(
      read: _read,
      write: {
        let oldValue = _read()
        _write($0)
        let newValue = _read()
        if oldValue != newValue {
          action(newValue)
        }
      }
    )
  }
}

public protocol ReferenceProvider: AnyObject {}

extension ReferenceProvider {
  @inlinable
  public func reference<Value>(
    for keyPath: KeyPath<Self, Value>
  ) -> ReadonlyReference<Value> {
    .object(self, read: { $0[keyPath: keyPath] })
  }

  @inlinable
  public func reference<Value>(
    for keyPath: ReferenceWritableKeyPath<Self, Value>
  ) -> Reference<Value> {
    .object(self, keyPath: keyPath)
  }
}

extension NSObject: ReferenceProvider {}
