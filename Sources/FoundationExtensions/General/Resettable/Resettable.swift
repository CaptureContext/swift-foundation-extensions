import CustomDump
import FunctionalKeyPath

extension Resettable {
  @available(
    *, deprecated,
     message: "Might be removed due to Value type constraint, which makes the behavior unstable, consider re-implementing this feature locally if you need"
  )
  public struct ValuesDump {
    public let items: [Object]
    public let currentIndex: Int
  }
}

extension Resettable {
  public enum OperationBehavior {
    case `default`
    case amend
    case insert
    case inject
  }
}

@propertyWrapper
@dynamicMemberLookup
public class Resettable<Object> {
  public init(_ object: Object) {
    self.object = object
    self.pointer = Pointer(undo: nil, redo: nil)
  }
  
  private var object: Object
  public var wrappedValue: Object { object }
  public var projectedValue: Resettable { self }
  
  private var pointer: Pointer
  
  // MARK: - Undo/Redo
  
  /// Dump values for __ValueTypes__
  @available(
    *, deprecated,
     message: "Might be removed due to Value type constraint, which makes the behavior unstable, consider re-implementing this feature locally if you need"
  )
  public func valuesDump() -> ValuesDump {
    let _pointer = pointer
    while pointer !== undo().pointer {}
    var buffer: [Object] = [wrappedValue]
    var indexBuffer = 0
    var currentIndex = 0
    
    while pointer !== redo().pointer {
      indexBuffer += 1
      let isCurrent = _pointer === pointer
      buffer.append(wrappedValue)
      if isCurrent { currentIndex = indexBuffer  }
    }
    
    if _pointer !== pointer {
      while _pointer !== undo().pointer {}
    }
    
    return ValuesDump(items: buffer, currentIndex: currentIndex)
  }
  
  public func dump() -> String {
    var buffer = ""
    self.dump(to: &buffer)
    return buffer
  }
  
  public func dump<TargetStream: TextOutputStream>(
    to stream: inout TargetStream
  ) {
    let _pointer = pointer
    while pointer !== undo().pointer {}
    var buffer: [String] = []
    var initialBuffer = ""
    customDump(wrappedValue, to: &initialBuffer)
    buffer.append(#"""""#)
    buffer.append("\n")
    buffer.append(
      initialBuffer.components(separatedBy: .newlines)
        .map { "  " + $0 }
        .joined(separator: "\n")
    )
    buffer.append("\n")
    
    var previous = wrappedValue
    
    while pointer !== redo().pointer {
      let isCurrent = _pointer === pointer
      var dump = ""
      customDump(diff(previous, wrappedValue), to: &dump)
      if dump == "nil" {
        buffer.append("\n  No state changes \n")
      } else {
        var _dump = dump.trimmingCharacters(in: [#"""#])
        if isCurrent {
          if _dump.hasPrefix("\n  ") {
            _dump.removeFirst(3)
          }
          buffer.append("\n  >>> ".appending(_dump))
        } else {
          buffer.append(_dump)
        }
      }
      previous = wrappedValue
    }
    
    buffer.append(#"""""#)
    
    stream.write(buffer.joined())
    
    if _pointer !== pointer {
      while _pointer !== undo().pointer {}
    }
  }
  
  @discardableResult
  public func undo() -> Resettable {
    pointer = pointer.undo(&object)
    return self
  }
  
  @discardableResult
  public func redo() -> Resettable {
    pointer = pointer.redo(&object)
    return self
  }
  
  @discardableResult
  public func undo(_ count: Int) -> Resettable {
    for _ in 0..<count { undo() }
    return self
  }
  
  @discardableResult
  public func redo(_ count: Int) -> Resettable {
    for _ in 0..<count { redo() }
    return self
  }
  
  @discardableResult
  public func reset() -> Resettable {
    while pointer !== undo().pointer {}
    return self
  }
  
  @discardableResult
  public func restore() -> Resettable {
    while pointer !== redo().pointer {}
    return self
  }
  
  // MARK: - Unsafe modification
  
  @discardableResult
  private func __modify(
    _ nextPointer: () -> Pointer
  ) -> Resettable {
    self.pointer = nextPointer()
    return self
  }
  
  @discardableResult
  public func _modify<Value>(
    operation: OperationBehavior = .default,
    _ keyPath: FunctionalKeyPath<Object, Value>,
    using action: @escaping (inout Value) -> Void
  ) -> Resettable {
    __modify {
      pointer.apply(
        modification: action,
        for: &object, keyPath,
        operation: operation
      )
    }
  }
  
  @discardableResult
  public func _modify<Value>(
    operation: OperationBehavior = .default,
    _ keyPath: FunctionalKeyPath<Object, Value>,
    using action: @escaping (inout Value) -> Void,
    undo: @escaping (inout Value) -> Void
  ) -> Resettable {
    __modify {
      pointer.apply(
        modification: action,
        for: &object, keyPath,
        undo: undo,
        operation: operation
      )
    }
  }
  
  @discardableResult
  public func _modify(
    operation: OperationBehavior = .default,
    using action: @escaping (inout Object) -> Void,
    undo: @escaping (inout Object) -> Void
  ) -> Resettable {
    __modify {
      pointer.apply(
        modification: action,
        undo: undo,
        for: &object,
        operation: operation
      )
    }
  }
  
  // MARK: - DynamicMemberLookup
  
  // MARK: Default
  
  public subscript<Value>(
    dynamicMember keyPath: WritableKeyPath<Object, Value>
  ) -> WritableKeyPathContainer<Value> {
    WritableKeyPathContainer(
      resettable: self,
      keyPath: .init(keyPath)
    )
  }
  
  public subscript<Value>(
    dynamicMember keyPath: KeyPath<Object, Value>
  ) -> KeyPathContainer<Value> {
    KeyPathContainer(
      resettable: self,
      keyPath: .getonly(keyPath)
    )
  }
  
  // MARK: Optional
  
  public subscript<Value, Wrapped>(
    dynamicMember keyPath: WritableKeyPath<Wrapped, Value>
  ) -> WritableKeyPathContainer<Value?> where Object == Optional<Wrapped> {
    WritableKeyPathContainer<Value?>(
      resettable: self,
      keyPath: FunctionalKeyPath(keyPath).optional()
    )
  }
  
  public subscript<Value, Wrapped>(
    dynamicMember keyPath: KeyPath<Wrapped, Value>
  ) -> KeyPathContainer<Value?> where Object == Optional<Wrapped> {
    KeyPathContainer<Value?>(
      resettable: self,
      keyPath: FunctionalKeyPath.getonly(keyPath).optional()
    )
  }
  
  // MARK: Collection
  
  public subscript<Value>(
    dynamicMember keyPath: WritableKeyPath<Object, Value>
  ) -> WritableCollectionProxy<Value> where Value: Swift.Collection {
    WritableCollectionProxy<Value>(
      resettable: self,
      keyPath: .init(keyPath)
    )
  }
  
  public subscript<Value>(
    dynamicMember keyPath: KeyPath<Object, Value>
  ) -> CollectionProxy<Value> where Value: Swift.Collection {
    CollectionProxy<Value>(
      resettable: self,
      keyPath: .getonly(keyPath)
    )
  }
}

// MARK: - Undo/Redo Core

extension Resettable {
  private class Pointer {
    init(
      prev: Pointer? = nil,
      next: Pointer? = nil,
      undo: ((inout Object) -> Void)? = nil,
      redo: ((inout Object) -> Void)? = nil
    ) {
      self.prev = prev
      self.next = next
      self._undo = undo
      self._redo = redo
    }
    
    var prev: Pointer?
    var next: Pointer?
    var _undo: ((inout Object) -> Void)?
    var _redo: ((inout Object) -> Void)?
    
    // MARK: - Undo/Redo
    
    func undo(_ object: inout Object) -> Pointer {
      _undo?(&object)
      return prev.or(self)
    }
    
    func redo(_ object: inout Object) -> Pointer {
      _redo?(&object)
      return next.or(self)
    }
    
    // MARK: - Apply
    
    func apply<Value>(
      modification action: @escaping (inout Value) -> Void,
      for object: inout Object,
      _ keyPath: FunctionalKeyPath<Object, Value>,
      operation: OperationBehavior = .default
    ) -> Pointer {
      var didPrepareObjectForAmend = false
      if operation == .amend {
        self._undo?(&object)
        didPrepareObjectForAmend = true
      }
      let valueSnapshot = keyPath.extract(from: object)
      return apply(
        modification: action,
        for: &object,
        keyPath,
        undo: { $0 = valueSnapshot },
        operation: operation,
        didPrepareObjectForAmend: didPrepareObjectForAmend
      )
    }
    
    func apply<Value>(
      modification action: @escaping (inout Value) -> Void,
      for object: inout Object,
      _ keyPath: FunctionalKeyPath<Object, Value>,
      undo: @escaping (inout Value) -> Void,
      operation: OperationBehavior = .default,
      didPrepareObjectForAmend: Bool = false
    ) -> Pointer {
      return apply(
        modification: { object in
          keyPath.embed(
            modification(
              of: keyPath.extract(from: object),
              with: action
            ),
            in: &object
          )
        },
        undo: { object in
          keyPath.embed(
            modification(
              of: keyPath.extract(from: object),
              with: undo
            ),
            in: &object
          )
        },
        for: &object,
        operation: operation,
        didPrepareObjectForAmend: didPrepareObjectForAmend
      )
    }
    
    func apply(
      modification: @escaping (inout Object) -> Void,
      undo: @escaping (inout Object) -> Void,
      for object: inout Object,
      operation: OperationBehavior = .default,
      didPrepareObjectForAmend: Bool = false
    ) -> Pointer {
      if operation == .inject {
        modification(&object)
        
        let prevUndo = self._undo
        self._undo = { object in
          undo(&object)
          prevUndo?(&object)
        }
        
        let prevRedo = self.prev?._redo
        self.prev?._redo = { object in
          prevRedo?(&object)
          modification(&object)
        }
        
        return self
      }
      
      if operation == .amend {
        if !didPrepareObjectForAmend {
          self._undo?(&object)
        }
        modification(&object)
        self._undo = undo
        self.prev?._redo = modification
        return self
      }
      
      let pointer = Pointer(
        prev: self,
        next: operation == .insert ? self.next : nil,
        undo: undo,
        redo: operation == .insert ? self._redo : nil
      )
      
      modification(&object)
      self.next = pointer
      self._redo = modification
      
      return pointer
    }
  }
}

// MARK: Modification public API

extension Resettable {
  @dynamicMemberLookup
  public struct KeyPathContainer<Value> {
    let resettable: Resettable
    let keyPath: FunctionalKeyPath<Object, Value>
    
    // MARK: - DynamicMemberLookup
    
    // MARK: Default
    
    public subscript<LocalValue>(
      dynamicMember keyPath: ReferenceWritableKeyPath<Value, LocalValue>
    ) -> WritableKeyPathContainer<LocalValue> {
      WritableKeyPathContainer<LocalValue>(
        resettable: resettable,
        keyPath: self.keyPath.appending(path: .init(keyPath))
      )
    }
    
    public subscript<LocalValue>(
      dynamicMember keyPath: KeyPath<Value, LocalValue>
    ) -> KeyPathContainer<LocalValue> {
      KeyPathContainer<LocalValue>(
        resettable: resettable,
        keyPath: self.keyPath.appending(path: .getonly(keyPath))
      )
    }
    
    // MARK: Optional
    
    public subscript<LocalValue, Wrapped>(
      dynamicMember keyPath: ReferenceWritableKeyPath<Wrapped, LocalValue>
    ) -> WritableKeyPathContainer<LocalValue?> where Value == Optional<Wrapped> {
      WritableKeyPathContainer<LocalValue?>(
        resettable: resettable,
        keyPath: self.keyPath.appending(path: .init(keyPath))
      )
    }
    
    public subscript<LocalValue, Wrapped>(
      dynamicMember keyPath: KeyPath<Wrapped, LocalValue>
    ) -> KeyPathContainer<LocalValue?> where Value == Optional<Wrapped> {
      KeyPathContainer<LocalValue?>(
        resettable: resettable,
        keyPath: self.keyPath.appending(path: .getonly(keyPath))
      )
    }
    
    // MARK: Collection
    
    public subscript<LocalValue>(
      dynamicMember keyPath: ReferenceWritableKeyPath<Value, LocalValue>
    ) -> WritableCollectionProxy<LocalValue> where LocalValue: Swift.Collection {
      WritableCollectionProxy<LocalValue>(
        resettable: resettable,
        keyPath: self.keyPath.appending(path: .init(keyPath))
      )
    }
    
    public subscript<LocalValue>(
      dynamicMember keyPath: KeyPath<Value, LocalValue>
    ) -> CollectionProxy<LocalValue> where LocalValue: Swift.Collection {
      CollectionProxy<LocalValue>(
        resettable: resettable,
        keyPath: self.keyPath.appending(path: .getonly(keyPath))
      )
    }
  }
  
  @dynamicMemberLookup
  public struct WritableKeyPathContainer<Value> {
    let resettable: Resettable
    let keyPath: FunctionalKeyPath<Object, Value>
    
    // MARK: Modification
    
    @discardableResult
    public func callAsFunction(_ value: Value, operation: OperationBehavior = .default) -> Resettable {
      return self.callAsFunction(operation) { $0 = value }
    }
    
    @discardableResult
    public func callAsFunction(_ operation: OperationBehavior = .default, _ action: @escaping (inout Value) -> Void) -> Resettable {
      return resettable._modify(operation: operation, keyPath, using: action)
    }
    
    @discardableResult
    public func callAsFunction(
      _ operation: OperationBehavior = .default,
      _ action: @escaping (inout Value) -> Void,
      undo: @escaping (inout Value) -> Void
    ) -> Resettable {
      return resettable._modify(operation: operation, keyPath, using: action, undo: undo)
    }
    
    
    // MARK: - DynamicMemberLookup
    
    // MARK: Default
    
    public subscript<LocalValue>(
      dynamicMember keyPath: WritableKeyPath<Value, LocalValue>
    ) -> WritableKeyPathContainer<LocalValue> {
      WritableKeyPathContainer<LocalValue>(
        resettable: resettable,
        keyPath: self.keyPath.appending(path: .init(keyPath))
      )
    }
    
    public subscript<LocalValue>(
      dynamicMember keyPath: KeyPath<Value, LocalValue>
    ) -> KeyPathContainer<LocalValue> {
      KeyPathContainer<LocalValue>(
        resettable: resettable,
        keyPath: self.keyPath.appending(path: .getonly(keyPath))
      )
    }
    
    // MARK: Optional
    
    public subscript<LocalValue, Wrapped>(
      dynamicMember keyPath: WritableKeyPath<Wrapped, LocalValue>
    ) -> WritableKeyPathContainer<LocalValue?> where Value == Optional<Wrapped> {
      WritableKeyPathContainer<LocalValue?>(
        resettable: resettable,
        keyPath: self.keyPath.appending(path: .init(keyPath))
      )
    }
    
    public subscript<LocalValue, Wrapped>(
      dynamicMember keyPath: KeyPath<Wrapped, LocalValue>
    ) -> KeyPathContainer<LocalValue?> where Value == Optional<Wrapped> {
      KeyPathContainer<LocalValue?>(
        resettable: resettable,
        keyPath: self.keyPath.appending(path: .getonly(keyPath))
      )
    }
    
    // MARK: Collection
    
    public subscript<LocalValue>(
      dynamicMember keyPath: WritableKeyPath<Value, LocalValue>
    ) -> WritableCollectionProxy<LocalValue> where LocalValue: Swift.Collection {
      WritableCollectionProxy<LocalValue>(
        resettable: resettable,
        keyPath: self.keyPath.appending(path: .init(keyPath))
      )
    }
    
    public subscript<LocalValue>(
      dynamicMember keyPath: KeyPath<Value, LocalValue>
    ) -> CollectionProxy<LocalValue> where LocalValue: Swift.Collection {
      CollectionProxy<LocalValue>(
        resettable: resettable,
        keyPath: self.keyPath.appending(path: .getonly(keyPath))
      )
    }
  }
}

@discardableResult
fileprivate func modification<T>(
  of object: T,
  with action: (inout T) -> Void
) -> T {
  var _object = object
  action(&_object)
  return _object
}
