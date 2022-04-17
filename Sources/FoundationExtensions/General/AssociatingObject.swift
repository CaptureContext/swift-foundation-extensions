import Foundation

public protocol AssociatingObject: AnyObject {
  @inlinable
  @discardableResult
  func setAssociatedObject<Object>(
    _ object: Object,
    forKey key: StaticString,
    policy: objc_AssociationPolicy
  ) -> Bool
  
  @inlinable
  func getAssociatedObject<Object>(
    of type: Object.Type,
    forKey key: StaticString
  ) -> Object?
}

extension AssociatingObject {
  @inlinable
  @discardableResult
  public func setAssociatedObject<Object>(
    _ object: Object,
    forKey key: StaticString,
    policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC
  ) -> Bool {
    return _setAssociatedObject(
      object,
      to: self,
      forKey: key,
      policy: policy
    )
  }
  
  @inlinable
  public func getAssociatedObject<Object>(
    of type: Object.Type = Object.self,
    forKey key: StaticString
  ) -> Object? {
    return _getAssociatedObject(
      forKey: key,
      from: self
    )
  }
}

@inlinable
@discardableResult
public func _setAssociatedObject<Object>(
  _ object: Object,
  to associatingObject: AnyObject,
  forKey key: StaticString,
  policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC
) -> Bool {
  key.withUTF8Buffer { pointer in
    if let p = pointer.baseAddress.map(UnsafeRawPointer.init) {
      objc_setAssociatedObject(associatingObject, p, object, policy)
      return true
    } else {
      return false
    }
  }
}

@inlinable
public func _getAssociatedObject<Object>(
  of type: Object.Type = Object.self,
  forKey key: StaticString,
  from associatingObject: AnyObject
) -> Object? {
  key.withUTF8Buffer { pointer in
    if let p = pointer.baseAddress.map(UnsafeRawPointer.init) {
      return objc_getAssociatedObject(associatingObject, p).flatMap { $0 as? Object }
    } else {
      return nil
    }
  }
}

extension NSObject: AssociatingObject {}
