@available(*, deprecated, renamed: "Optional.UnwrappingError", message: "Use Optional<Wrapped>.UnwrappingError instead")
public typealias UnwrappingError<T> = Optional<T>.UnwrappingError

extension Optional.UnwrappingError {
	@available(*, deprecated, message: "Instead of UnwrappingError<T>, use Optional<Wrapped>.UnwrappingError")
	public typealias T = Wrapped
}
