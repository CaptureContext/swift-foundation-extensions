extension ClosedRange {
	@available(*, deprecated, message: "Use value.clamped(in: range) instead")
	@inlinable
	public func clamped(_ value: Bound) -> Bound {
		if value < lowerBound {
			return lowerBound
		} else if value > upperBound {
			return upperBound
		} else {
			return value
		}
	}
}

extension PartialRangeFrom {
	@available(*, deprecated, message: "Use value.clamped(in: range) instead")
	@inlinable
	public func clamped(_ value: Bound) -> Bound {
		if value < lowerBound {
			return lowerBound
		} else {
			return value
		}
	}
}

extension PartialRangeThrough {
	@available(*, deprecated, message: "Use value.clamped(in: range) instead")
	@inlinable
	public func clamped(_ value: Bound) -> Bound {
		if value > upperBound {
			return upperBound
		} else {
			return value
		}
	}
}
