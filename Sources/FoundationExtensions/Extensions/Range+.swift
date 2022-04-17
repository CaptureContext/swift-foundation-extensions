extension ClosedRange where Bound: FloatingPoint {
  public var length: Bound { upperBound - lowerBound }
}

extension ClosedRange where Bound: BinaryInteger {
  public var length: Bound { upperBound - lowerBound }
}

extension ClosedRange {
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
