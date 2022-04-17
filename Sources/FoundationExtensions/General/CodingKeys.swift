import Foundation

public struct CodingKeys: CodingKey {

  public var stringValue: String
  public var intValue: Int?

  public init(stringValue: String) {
    self.stringValue = stringValue
  }

  public init?(intValue: Int) {
    self.stringValue = "Index \(intValue)"
    self.intValue = intValue
  }

  public static func custom(_ value: String) -> Self { .init(stringValue: value) }

}

extension CodingKeys: ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    self = .custom(value)
  }

}
