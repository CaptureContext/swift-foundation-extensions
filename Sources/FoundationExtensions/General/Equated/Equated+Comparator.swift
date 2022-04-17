import Foundation

extension Equated {
  public struct Comparator {
    public let compare: (Value, Value) -> Bool
  }
}

extension Equated.Comparator {
  public static func custom(_ compare: @escaping (Value, Value) -> Bool) -> Self {
    return .init(compare: compare)
  }
  
  public static func property<Property: Equatable>(
    _ scope: @escaping (Value) -> Property
  ) -> Self {
    return .init { scope($0) == scope($1) }
  }
  
  public static func wrappedProperty<Wrapped, Property: Equatable>(
    _ scope: @escaping (Wrapped) -> Property
  ) -> Self where Value == Optional<Wrapped> {
    return .init { $0.map(scope) == $1.map(scope) }
  }
  
  public static var dump: Self {
    .init { lhs, rhs in
      var (lhsDump, rhsDump) = ("", "")
      Swift.dump(lhs, to: &lhsDump)
      Swift.dump(rhs, to: &rhsDump)
      return lhsDump == rhsDump
    }
  }
  
  public static var typedDump: Self {
    .init { lhs, rhs in
      var (lhsDump, rhsDump) = ("\(type(of: lhs))", "\(type(of: rhs))")
      Swift.dump(lhs, to: &lhsDump)
      Swift.dump(rhs, to: &rhsDump)
      return lhsDump == rhsDump
    }
  }
}
  
extension Equated.Comparator where Value: Error {
  public static var localizedDescription: Self {
    .property(\.localizedDescription)
  }
}
