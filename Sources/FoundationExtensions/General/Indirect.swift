//
//  Indirect.swift
//  EduDoCore
//
//  Created by Maxim Krouk on 9/8/20.
//  Copyright © 2020 EduDo Inc. All rights reserved.
//

import Foundation

/// Allows to wrap structs recoursively
///
/// Usage:
/// ```
/// public struct User {
///     internal init(id: UUID, favoriteFollower: User?) {
///         self.id = id
///         self._favoriteFollower = Indirect(favoriteFollower)
///     }
///     public var id: UUID
///
///     @Indirect
///     public var favoriteFollower: User?
/// }
///
/// var user = User(id: UUID(), favoriteFollower: User(id: UUID()))
/// user.favoriteFollower?.id
/// ```
/// Note: Codable stuff behaviour is not tested for propertyWrapper style, maybe u should consider
/// using `var favoriteFollower: Indirect<User?>`.
///
@propertyWrapper
@dynamicMemberLookup
public struct Indirect<Value> {
  private class Storage {
    var value: Value
    init(_ value: Value) {
      self.value = value
    }
  }
  
  private var storage: Storage

  public init(_ value: Value) {
    self.init(wrappedValue: value)
  }
  
  public init(wrappedValue: Value) {
    self.storage = .init(wrappedValue)
  }

  public var wrappedValue: Value {
    get { storage.value }
    set {
      if isKnownUniquelyReferenced(&storage) {
        storage.value = newValue
      } else {
        storage = Storage(newValue)
      }
    }
  }

  public subscript<T>(dynamicMember keyPath: KeyPath<Value, T>) -> T {
    wrappedValue[keyPath: keyPath]
  }

  public subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> T {
    get { wrappedValue[keyPath: keyPath] }
    set { wrappedValue[keyPath: keyPath] = newValue }
  }
}

extension Indirect: Comparable where Value: Comparable {
  public static func <(lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue < rhs.wrappedValue
  }
}

extension Indirect: Hashable where Value: Hashable {
  public func hash(into hasher: inout Hasher) {
    wrappedValue.hash(into: &hasher)
  }
}

extension Indirect: Equatable where Value: Equatable {
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension Indirect: Codable where Value: Codable {
  public init(from decoder: Decoder) throws {
    try self.init(.init(from: decoder))
  }

  public func encode(to encoder: Encoder) throws {
    try wrappedValue.encode(to: encoder)
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Indirect: Identifiable where Value: Identifiable {
  public var id: Value.ID { wrappedValue.id }
}
