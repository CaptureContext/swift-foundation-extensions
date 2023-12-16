/// Universal String Identifier
///
/// Wraps string value as an identifier
public struct USID:
	Equatable,
	Hashable,
	RawRepresentable,
	ExpressibleByStringLiteral,
	ExpressibleByStringInterpolation,
	LosslessStringConvertible
{
	public let rawValue: String

	@inlinable
	public init(_ uuid: UUID = .init()) {
		self.init(uuid.uuidString)
	}

	@inlinable
	public init(stringLiteral value: String) {
		self.init(value)
	}

	@inlinable
	public init(_ value: String) {
		self.init(rawValue: value)
	}

	@inlinable
	public init(usidString value: String) {
		self.init(rawValue: value)
	}

	@inlinable
	public init(rawValue value: String) {
		self.rawValue = value
	}

	@inlinable
	public var description: String { rawValue }

	@inlinable
	public var usidString: String { rawValue }

	@inlinable
	public var intValue: Int? { Int(rawValue) }

	@inlinable
	public var uuidValue: UUID? { UUID(uuidString: rawValue) }
}

extension USID: Codable {
	@inlinable
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		self.init(rawValue: try container.decode(String.self))
	}

	@inlinable
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(rawValue)
	}
}

extension USID: ExpressibleByIntegerLiteral {
	@inlinable
	public init(integerLiteral value: Int) {
		self = .describing(value)
	}
}

extension USID {
	@inlinable
	public static func describing<Value: CustomStringConvertible>(_ value: Value) -> USID {
		return USID(rawValue: String(describing: value))
	}

	@inlinable
	public static func hash<Value: Hashable>(of value: Value) -> USID {
		return .describing(value.hashValue)
	}

	@inlinable
	public static func dump<T>(_ value: T) -> USID {
		var buffer = "\(type(of: value))\n"
		Swift.dump(value, to: &buffer)
		return USID(rawValue: buffer)
	}
}

extension String {
	@inlinable
	public func usid() -> USID { .init(self) }
}
