extension Optional {
	/// Unwraps an optional or throws specified error
	@inlinable
	public func orThrow(_ error: @autoclosure () -> Error) throws -> Wrapped {
		switch self {
		case .some(let wrapped):
			return wrapped
		case .none:
			throw error()
		}
	}

	@inlinable
	public var isNil: Bool {
		switch self {
		case .none: return true
		case .some: return false
		}
	}

	@inlinable
	public var isNotNil: Bool { !isNil }

	/// Unwraps an optional and returns specified value if the optional was nil
	@inlinable
	public func or(_ value: @autoclosure () -> Wrapped) -> Wrapped {
		self ?? value()
	}

	/// Unwraps an optional and returns specified value if the optional was nil
	@inlinable
	public func or(_ value: @autoclosure () -> Wrapped?) -> Wrapped? {
		self ?? value()
	}

	/// Unwraps an optional and returns unwrapping result
	@inlinable
	public func unwrap(function: String = #function, file: String = #filePath, line: Int = #line)
	-> Result<Wrapped, UnwrappingError<Wrapped>>
	{
		switch self {
		case .some(let value):
			return .success(value)
		case .none:
			return .failure(
				UnwrappingError(
					function: function,
					file: file,
					line: line)
			)
		}
	}

	/// Assigns wrapped value to a specified target property by the keyPath
	@inlinable
	public func assign<T: AnyObject>(
		to keyPath: ReferenceWritableKeyPath<T, Optional>,
		on target: T
	) { target[keyPath: keyPath] = self }

	/// Assigns wrapped value to a specified target property by the keyPath if an optional was not nil
	@inlinable
	public func ifLetAssign<T: AnyObject>(
		to keyPath: ReferenceWritableKeyPath<T, Wrapped>,
		on target: T
	) { map { target[keyPath: keyPath] = $0 } }

	/// Assigns wrapped value to a specified target property by the keyPath if an optional was not nil
	@inlinable
	public func ifLetAssign<T: AnyObject>(
		to keyPath: ReferenceWritableKeyPath<T, Optional>,
		on target: T
	) { map { target[keyPath: keyPath] = $0 } }

	/// Assigns wrapped value to a specified target property by the keyPath
	@inlinable
	public func assign<T>(
		to keyPath: WritableKeyPath<T, Optional>,
		on target: inout T
	) { target[keyPath: keyPath] = self }

	/// Assigns wrapped value to a specified target property by the keyPath if an optional was not nil
	@inlinable
	public func ifLetAssign<T>(
		to keyPath: WritableKeyPath<T, Wrapped>,
		on target: inout T
	) { map { target[keyPath: keyPath] = $0 } }

	/// Assigns wrapped value to a specified target property by the keyPath if an optional was not nil
	@inlinable
	public func ifLetAssign<T>(
		to keyPath: WritableKeyPath<T, Optional>,
		on target: inout T
	) { map { target[keyPath: keyPath] = $0 } }
}

extension Optional where Wrapped: Collection {
	@inlinable
	public var isNilOrEmpty: Bool {
		map(\.isEmpty).or(true)
	}
}
