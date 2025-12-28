extension Range where Bound: Numeric {
	@inlinable
	public var length: Bound { upperBound - lowerBound }
}

extension ClosedRange where Bound: Numeric {
	@inlinable
	public var length: Bound { upperBound - lowerBound }
}
