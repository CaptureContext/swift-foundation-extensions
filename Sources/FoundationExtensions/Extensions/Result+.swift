extension Swift.Result {
  @inlinable
  public var value: Success? {
    switch self {
    case let .success(value): return value
    default: return nil
    }
  }
  
  @inlinable
  public var error: Failure? {
    switch self {
    case let .failure(error): return error
    default: return nil
    }
  }
  
  @inlinable
  public func eraseError() -> Result<Success, Swift.Error> {
    mapError { $0 as Error }
  }

  @inlinable
  public func replaceError(with success: Success) -> Result<Success, Never> {
    replaceError { _ in success }
  }

  @inlinable
  public func replaceError(with closure: (Error) -> Success) -> Result<Success, Never> {
    switch self {
    case .success(let value):
      return .success(value)
    case .failure(let error):
      return .success(closure(error))
    }
  }
}
