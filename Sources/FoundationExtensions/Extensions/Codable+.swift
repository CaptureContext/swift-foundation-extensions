import Foundation

public enum RawCodingKey: CodingKey, ExpressibleByStringLiteral, ExpressibleByIntegerLiteral {
  case key(String)
  case index(Int)

  public init(stringLiteral value: String) {
    self.init(stringValue: value)
  }

  public init(stringValue: String) {
    self = .key(stringValue)
  }

  public init(integerLiteral value: Int) {
    self.init(intValue: value)
  }

  public init(intValue: Int) {
    self = .index(intValue)
  }

  public var stringValue: String {
    switch self {
    case let .key(value):
      return value
    case let .index(value):
      return value.description
    }
  }

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
  public func decode<T>(
    _ decode: (KeyedDecodingContainer<RawCodingKey>) throws -> T
  ) throws -> T {
    return try self.decode(RawCodingKey.self, decode)
  }

  public func decode<CodingKeys: CodingKey, T>(
    _ codingKeys: CodingKeys.Type,
    _ decode: (KeyedDecodingContainer<CodingKeys>) throws -> T
  ) throws -> T {
    let container = try container(keyedBy: codingKeys)
    return try decode(container)
  }
}

extension Encoder {
  public func encode<T>(
    _ encode: (inout KeyedEncodingContainer<RawCodingKey>) throws -> T
  ) throws -> T {
    return try self.encode(RawCodingKey.self, encode)
  }

  public func encode<CodingKeys: CodingKey, T>(
    _ codingKeys: CodingKeys.Type,
    _ encode: (inout KeyedEncodingContainer<CodingKeys>) throws -> T
  ) throws -> T {
    var container = container(keyedBy: codingKeys)
    return try encode(&container)
  }
}

extension KeyedDecodingContainer {
  public func decode<T: Decodable>(
    _ key: K
  ) throws -> T {
    try decode(T.self, forKey: key)
  }

  public func decodeIfPresent<T: Decodable>(
    _ key: K
  ) throws -> T? {
    try decodeIfPresent(T.self, forKey: key)
  }
}
