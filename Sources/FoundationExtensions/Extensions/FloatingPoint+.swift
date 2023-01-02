extension FloatingPoint {
  @inlinable
  public func progress(in total: Self) -> Self {
    total != 0 ? self / total : 0
  }
}
