/// Helper for creating `objc_AssociationPolicy`
public enum _AssociationPolicyKind: String {
	/// `OBJC_ASSOCIATION_COPY` / `OBJC_ASSOCIATION_COPY_NONATOMIC`
	///
	/// Use this policy when you need the value of the object as it was at the moment the property was set,
	/// and the object is possibly mutable.
	case copy
	
	/// `OBJC_ASSOCIATION_ASSIGN`
	///
	/// Use this when you're associating a raw pointer, or for a weak reference to an object.
	/// It does not extend the lifetime of the associated object.
	case assign
	
	
	/// `OBJC_ASSOCIATION_RETAIN` / `OBJC_ASSOCIATION_RETAIN_NONATOMIC`
	///
	///  Use  this to specify a strong reference to the associated object
	case retain
}

/// Helper for creating `objc_AssociationPolicy`
///
/// Remember, ﻿`.atomic` properties ensure that an entire value is set/get
/// before another operation can take place on it - these are thread-safe but slower.
/// On the other hand, ﻿`.nonatomic` properties don't have that restriction - they're faster but not thread-safe.
public enum _AssociationPolicyThreadSafety: String {
	/// It is the default behaviour. If an object is declared as atomic then it becomes thread-safe.
	///
	/// Thread-safe means, at a time only one thread of a particular instance of that class can have the control over that object.
	case atomic
	
	/// Disable thread-safety. it’s faster to access a nonatomic property than an atomic one.
	///
	/// You can use the nonatomic property attribute to specify that synthesized accessors simply set or return a value directly,
	/// with no guarantees about what happens if that same value is accessed simultaneously from different threads.
	/// For this reason,
	case nonatomic
}

extension objc_AssociationPolicy {
	@inlinable
	public init(
		_ kind: _AssociationPolicyKind,
		_ threadSafety: _AssociationPolicyThreadSafety
	) {
		switch kind {
		case .copy:
			self = .copy(threadSafety)
		case .assign:
			self = .assign
		case .retain:
			self = .retain(threadSafety)
		}
	}
	
	/// `OBJC_ASSOCIATION_ASSIGN`
	///
	/// Use this when you're associating a raw pointer, or for a weak reference to an object.
	/// It does not extend the lifetime of the associated object.
	@inlinable
	public static var assign: Self { .OBJC_ASSOCIATION_ASSIGN }
	
	/// `OBJC_ASSOCIATION_RETAIN` / `OBJC_ASSOCIATION_RETAIN_NONATOMIC`
	///
	///  Use  `.retain(.atomic)` to specify a strong reference to the associated object and it's thread-safe.
	///  Use this when you're working in a multithreaded environment and you need to ensure that
	///  the associated object isn't deallocated before you're done with it.
	///
	///  `.retain(.nonatomic)` specifies a strong reference to the associated object and is not thread-safe.
	///  This is appropriate when you're not concerned with performance in multithreaded scenarios.
	@inlinable
	public static func retain(_ threadSafety: _AssociationPolicyThreadSafety) ->  Self {
		switch threadSafety {
		case .atomic:
				.OBJC_ASSOCIATION_RETAIN
		case .nonatomic:
				.OBJC_ASSOCIATION_RETAIN_NONATOMIC
		}
	}
	
	/// `OBJC_ASSOCIATION_COPY` / `OBJC_ASSOCIATION_COPY_NONATOMIC`
	///
	/// `.copy(.atomic)` as well as `.retain` also creates a copy of the associated object,
	/// and the copy is made in an atomic way (thread-safe). Use this policy when
	/// you're working in a multithreaded environment and you need the value of the object
	/// as it was at the moment the property was set, and the object is possibly mutable.
	///
	/// `.copy(.nonatomic)` creates a copy of the associated object, and the copy is made in a non-atomic way.
	/// Use this policy when you need the value of the object as it was at the moment the property was set,
	/// and the object is possibly mutable.
	@inlinable
	public static func copy(_ threadSafety: _AssociationPolicyThreadSafety) ->  Self {
		switch threadSafety {
		case .atomic:
				.OBJC_ASSOCIATION_COPY
		case .nonatomic:
				.OBJC_ASSOCIATION_COPY_NONATOMIC
		}
	}
}
