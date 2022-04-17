//
//  Collection+Extension.swift
//  AthenaMacOS
//
//  Created by Maxim Krouk on 7/19/20.
//  Copyright © 2020 dev.makeupstudio. All rights reserved.
//

extension Collection {
  /// - Complexity: *O(1)*
  @inlinable
  public var isNotEmpty: Bool { !self.isEmpty }
}

extension Array {
  /// - Complexity: *O(1)*
  @inlinable
  public subscript(safe index: Index?) -> Element? {
    get {
      guard let index = index else { return nil }
      return self[safe: index]
    }
    set {
      guard let index = index else { return }
      self[safe: index] = newValue
    }
  }
  
  /// - Complexity: *O(1)*
  @inlinable
  public subscript(safe index: Index) -> Element? {
    get {
      guard
        index >= startIndex,
        index < endIndex
      else { return nil }
      return self[index]
    }
    set {
      guard
        index >= startIndex,
        index < endIndex,
        let value = newValue
      else { return }
      return self[index] = value
    }
  }
  
  /// - Complexity: *O(n)*
  @inlinable
  public mutating func bringFront(elementsSatisfying predicate: (Element) -> Bool) {
    let leftHalf = self.filter { predicate($0) }
    let rightHalf = self.filter { !predicate($0) }
    self = leftHalf + rightHalf
  }
}
