import Foundation

extension Equated {
	public struct Comparator: @unchecked Sendable {
		@usableFromInline
		internal init(compare: @escaping (Value, Value) -> Bool) {
			self.compare = compare
		}
		
		public let compare: (Value, Value) -> Bool
	}
}

extension Equated.Comparator {
	@inlinable
	public static func custom(_ compare: @escaping (Value, Value) -> Bool) -> Self {
		return .init(compare: compare)
	}
	
	@inlinable
	public static func property<Property: Equatable>(
		_ scope: @escaping (Value) -> Property
	) -> Self {
		return .init { scope($0) == scope($1) }
	}
	
	@inlinable
	public static func wrappedProperty<Wrapped, Property: Equatable>(
		_ scope: @escaping (Wrapped) -> Property
	) -> Self where Value == Optional<Wrapped> {
		return .init { $0.map(scope) == $1.map(scope) }
	}
	
	@inlinable
	public static var dump: Self {
		.init { lhs, rhs in
			var (lhsDump, rhsDump) = ("", "")
			Swift.dump(lhs, to: &lhsDump)
			Swift.dump(rhs, to: &rhsDump)
			return lhsDump == rhsDump
		}
	}
	
	@inlinable
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
	@inlinable
	public static var localizedDescription: Self {
		.property(\.localizedDescription)
	}
}
