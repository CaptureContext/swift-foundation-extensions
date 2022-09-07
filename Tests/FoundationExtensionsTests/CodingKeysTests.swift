import XCTest
@testable import FoundationExtensions

final class CodingKeysTests: XCTestCase {
  struct Object: Codable, Equatable {
    init(
      optionalValue: Int? = nil,
      integerValue: Int = 0,
      stringValue: String = "",
      boolValue: Bool = false
    ) {
      self.optionalValue = optionalValue
      self.integerValue = integerValue
      self.stringValue = stringValue
      self.boolValue = boolValue
    }
    
    var optionalValue: Int? = nil
    var integerValue: Int = 0
    var stringValue: String = ""
    var boolValue: Bool = false
    
    init(from decoder: Decoder) throws {
      self = try decoder.decode { container in
        return .init(
          optionalValue: try container.decodeIfPresent("optionalValue"),
          integerValue: try container.decode("integerValue"),
          stringValue: try container.decode("stringValue"),
          boolValue: try container.decode("boolValue")
        )
      }
    }
    
    func encode(to encoder: Encoder) throws {
      try encoder.encode { container in
        try container.encodeIfPresent(optionalValue, forKey: "optionalValue")
        try container.encode(integerValue, forKey: "integerValue")
        try container.encode(stringValue, forKey: "stringValue")
        try container.encode(boolValue, forKey: "boolValue")
      }
    }
  }
  
  struct CodableObject: Codable, Equatable {
    init(
      optionalValue: Int? = nil,
      integerValue: Int = 0,
      stringValue: String = "",
      boolValue: Bool = false
    ) {
      self.optionalValue = optionalValue
      self.integerValue = integerValue
      self.stringValue = stringValue
      self.boolValue = boolValue
    }
    
    var optionalValue: Int? = nil
    var integerValue: Int = 0
    var stringValue: String = ""
    var boolValue: Bool = false
  }
  
  struct IntegerValueDecoding: Decodable, Equatable {
    init(value: Int) {
      self.value = value
    }
    
    var value: Int
    
    init(from decoder: Decoder) throws {
      self = try decoder.decode { container in
        return try container.decode("integerValue")
      }
    }
  }
  
  func testMain() throws {
    let object = Object(
      optionalValue: 1,
      integerValue: 2,
      stringValue: "test",
      boolValue: true
    )
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = [ .prettyPrinted]
    if #available(iOS 11.0, tvOS 11.0, *) {
      encoder.outputFormatting.insert(.sortedKeys)
    }
    
    let decoder = JSONDecoder()
    
    let encodedData = try encoder.encode(object)
    
    if #available(iOS 11.0, tvOS 11.0, *) {
      XCTAssertEqual(
        try XCTUnwrap(String(data: encodedData, encoding: .utf8)),
        """
        {
          "boolValue" : true,
          "integerValue" : 2,
          "optionalValue" : 1,
          "stringValue" : "test"
        }
        """
      )
    }
    
    XCTAssertEqual(
      object,
      try decoder.decode(Object.self, from: encodedData)
    )
    
    XCTAssertEqual(
      try decoder.decode(CodableObject.self, from: encodedData),
      CodableObject(
        optionalValue: 1,
        integerValue: 2,
        stringValue: "test",
        boolValue: true
      )
    )
    
    XCTAssertEqual(
      try decoder.decode(IntegerValueDecoding.self, from: encodedData),
      IntegerValueDecoding(value: 2)
    )
    
    XCTAssertEqual(
      try encoder.encode(CodableObject(
        optionalValue: 1,
        integerValue: 2,
        stringValue: "test",
        boolValue: true
      )),
      encodedData
    )
  }
}
