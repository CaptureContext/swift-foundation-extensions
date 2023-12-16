import Foundation

public enum RawCodingKey: CodingKey, ExpressibleByStringLiteral, ExpressibleByIntegerLiteral {
	case key(String)
	case index(Int)
	
	@inlinable
	public init(stringLiteral value: String) {
		self.init(stringValue: value)
	}
	
	@inlinable
	public init(stringValue: String) {
		self = .key(stringValue)
	}
	
	@inlinable
	public init(integerLiteral value: Int) {
		self.init(intValue: value)
	}
	
	@inlinable
	public init(intValue: Int) {
		self = .index(intValue)
	}
	
	@inlinable
	public var stringValue: String {
		switch self {
		case let .key(value):
			return value
		case let .index(value):
			return value.description
		}
	}
	
	@inlinable
	public var intValue: Int? {
		switch self {
		case let .index(value):
			return value
		default:
			return nil
		}
	}
}

extension Decoder {
	@inlinable
	public func decode<T>(
		_ decode: (KeyedDecodingContainer<RawCodingKey>) throws -> T
	) throws -> T {
		return try self.decode(RawCodingKey.self, decode)
	}
	
	@inlinable
	public func decode<CodingKeys: CodingKey, T>(
		_ codingKeys: CodingKeys.Type,
		_ decode: (KeyedDecodingContainer<CodingKeys>) throws -> T
	) throws -> T {
		let container = try container(keyedBy: codingKeys)
		return try decode(container)
	}
}

extension Encoder {
	@inlinable
	public func encode<T>(
		_ encode: (inout KeyedEncodingContainer<RawCodingKey>) throws -> T
	) throws -> T {
		return try self.encode(RawCodingKey.self, encode)
	}
	
	@inlinable
	public func encode<CodingKeys: CodingKey, T>(
		_ codingKeys: CodingKeys.Type,
		_ encode: (inout KeyedEncodingContainer<CodingKeys>) throws -> T
	) throws -> T {
		var container = container(keyedBy: codingKeys)
		return try encode(&container)
	}
}

extension KeyedDecodingContainer {
	@inlinable
	public func decode<T: Decodable>(
		_ key: K
	) throws -> T {
		try decode(T.self, forKey: key)
	}
	
	@inlinable
	public func decodeIfPresent<T: Decodable>(
		_ key: K
	) throws -> T? {
		try decodeIfPresent(T.self, forKey: key)
	}
}
