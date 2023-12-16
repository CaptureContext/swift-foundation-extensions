import Foundation

public protocol AssociatingObject: AnyObject {
	@inlinable
	@discardableResult
	func setAssociatedObject<Object>(
		_ object: Object?,
		forKey key: StaticString,
		policy: objc_AssociationPolicy
	) -> Bool
	
	@inlinable
	@discardableResult
	func setAssociatedObject<Object>(
		_ object: Object?,
		forKey key: StaticString,
		threadSafety: _AssociationPolicyThreadSafety
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
		_ object: Object?,
		forKey key: StaticString,
		policy: objc_AssociationPolicy = .retain(.nonatomic)
	) -> Bool {
		return _setAssociatedObject(
			object,
			to: self,
			forKey: key,
			policy: policy
		)
	}
	
	@inlinable
	@discardableResult
	public func setAssociatedObject<Object>(
		_ object: Object?,
		forKey key: StaticString,
		threadSafety: _AssociationPolicyThreadSafety
	) -> Bool {
		return _setAssociatedObject(
			object,
			to: self,
			forKey: key,
			threadSafety: threadSafety
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
	_ object: Object?,
	to associatingObject: AnyObject,
	forKey key: StaticString,
	threadSafety: _AssociationPolicyThreadSafety = .nonatomic
) -> Bool {
	_setAssociatedObject(
		object,
		to: associatingObject,
		forKey: key,
		policy: .init(
			Object.self is AnyClass ? .retain : .copy,
			threadSafety
		)
	)
}

@inlinable
@discardableResult
public func _setAssociatedObject<Object>(
	_ object: Object?,
	to associatingObject: AnyObject,
	forKey key: StaticString,
	policy: objc_AssociationPolicy
) -> Bool {
	return key.withUTF8Buffer { pointer in
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
