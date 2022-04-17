import Foundation

public protocol Castable {
  func `as`<T>(_ type: T.Type) -> T?
  func `is`<T>(_ type: T.Type) -> Bool
}

extension Castable {
  public func `as`<T>(_ type: T.Type) -> T? {
    self as? T
  }

  public func `is`<T>(_ type: T.Type) -> Bool {
    self is T
  }
}

extension Optional: Castable {}

extension NSObject: Castable {}
