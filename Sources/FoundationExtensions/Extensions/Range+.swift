extension Range where Bound: BinaryInteger {
  @inlinable
  public var length: Bound { upperBound - lowerBound }
}

extension ClosedRange where Bound: Numeric {
  @inlinable
  public var length: Bound { upperBound - lowerBound }
}

extension ClosedRange {
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
  @inlinable
  public func clamped(_ value: Bound) -> Bound {
    if value > upperBound {
      return upperBound
    } else {
      return value
    }
  }
}
