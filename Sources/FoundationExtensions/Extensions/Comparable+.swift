extension Comparable {
	@inlinable
	public func clamped(in range: ClosedRange<Self>) -> Self {
		min(max(range.lowerBound, self), range.upperBound)
	}

	@inlinable
	public mutating func clamp(in range: ClosedRange<Self>) {
		self = self.clamped(in: range)
	}

	@inlinable
	public func clamped(in range: PartialRangeFrom<Self>) -> Self {
		max(range.lowerBound, self)
	}

	@inlinable
	public mutating func clamp(in range: PartialRangeFrom<Self>) {
		self = self.clamped(in: range)
	}

	@inlinable
	public func clamped(in range: PartialRangeThrough<Self>) -> Self {
		min(self, range.upperBound)
	}

	@inlinable
	public mutating func clamp(in range: PartialRangeThrough<Self>) {
		self = self.clamped(in: range)
	}
}
