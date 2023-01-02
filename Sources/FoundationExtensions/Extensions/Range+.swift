extension ClosedRange where Bound: FloatingPoint {
  @inlinable
  public var length: Bound { upperBound - lowerBound }
}

extension ClosedRange where Bound: BinaryInteger {
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
