// https://www.swiftbysundell.com/articles/accessing-a-swift-property-wrappers-enclosing-instance/

import FunctionalKeyPath
import Foundation

@propertyWrapper
public struct PropertyProxy<Object: AnyObject, Value> {
  public static subscript(
    _enclosingInstance instance: Object,
    wrapped wrappedKeyPath: ReferenceWritableKeyPath<Object, Value>,
    storage storageKeyPath: ReferenceWritableKeyPath<Object, Self>
  ) -> Value {
    get {
      let path = instance[keyPath: storageKeyPath].path
      return path.extract(from: instance)
    }
    set {
      let wrapper = instance[keyPath: storageKeyPath]
      _ = wrapper.path.embed(newValue, in: instance)
    }
  }

  private let path: FunctionalKeyPath<Object, Value>
  
  @available(*, unavailable, message: "@ObjectProxy can only be applied to classes")
  public var wrappedValue: Value {
    get { fatalError() }
    set { fatalError() }
  }

  public init(_ path: FunctionalKeyPath<Object, Value>) {
    self.path = path
  }

  public init(_ keyPath: ReferenceWritableKeyPath<Object, Value>) {
    self.path = .init(keyPath)
  }
}
