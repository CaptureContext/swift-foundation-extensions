import XCTest
import MacroTesting
import FoundationExtensionsMacros

final class AssociatedObjectTests: XCTestCase {
  override func invokeTest() {
    withMacroTesting(
      isRecording: false,
      macros: [
        "AssociatedObject": AssociatedObjectMacro.self
      ]
    ) {
      super.invokeTest()
    }
  }

  func testAttachmentToImmutableProperty() {
    assertMacro {
        """
        extension Object {
          @AssociatedObject
          let value: Int = 0
        }
        """
    } diagnostics: {
      """
      extension Object {
        @AssociatedObject
        let value: Int = 0
        ╰─ 🛑 `@AssociatedObject` must be attached to a computed property declaration.
      }
      """
    }
  }

  func testAttachmentToVariableWithDefaultValue_ImplicitType() {
    assertMacro {
        """
        extension Object {
          @AssociatedObject
          var value = 0
        }
        """
    } diagnostics: {
      """
      extension Object {
        @AssociatedObject
        var value = 0
            ╰─ 🛑 `@AssociatedObject` requires explicit type declaration.
      }
      """
    }
  }

  func testAttachmentToStoredVariable_NoInitialValue() {
    assertMacro {
        """
        extension Object {
          @AssociatedObject
          var value: Int
        }
        """
    } diagnostics: {
      """
      extension Object {
        @AssociatedObject
        var value: Int
            ╰─ 🛑 `@AssociatedObject` requires initial value for non-optional types.
      }
      """
    }
  }

  func testAttachmentToVariableWithDefaultValue() {
    assertMacro {
        """
        extension Object {
          @AssociatedObject
          var value: Int = 0
        }
        """
    } expansion: {
      """
      extension Object {
        var value: Int = 0 {
          get {
            return _getAssociatedObject(
              forKey: #function,
              from: self
            ).or(0)
          }
          set {
            do {
              _setAssociatedObject(
                newValue,
                to: self,
                forKey: #function
              )
            }
          }
        }
      }
      """
    }
  }

  func testAttachmentToOptionalVariable() {
    assertMacro {
      """
      extension Object {
        @AssociatedObject
        var value: Int?
      }
      """
    } expansion: {
      """
      extension Object {
        var value: Int? {
          get {
            return _getAssociatedObject(
              forKey: #function,
              from: self
            )
          }
          set {
            do {
              _setAssociatedObject(
                newValue,
                to: self,
                forKey: #function
              )
            }
          }
        }
      }
      """
    }
  }

  // 🛑 Macro is not able to process unrelated params [reason: lack of type info]
  // ⚠️ Params handling is responsibility of API providing library
  func testCustomParams_UnrelatedParams() {
    assertMacro {
      """
      extension Object {
        @AssociatedObject("Hello, World")
        var value: Int?
      }
      """
    } expansion: {
      """
      extension Object {
        var value: Int? {
          get {
            return _getAssociatedObject(
              forKey: #function,
              from: self
            )
          }
          set {
            do {
              func _macro_setAssociatedObject(_ policy: _AssociationPolicyKind) {
                _setAssociatedObject(
                  newValue,
                  to: self,
                  forKey: #function,
                  policy: policy
                )
              }
              func _macro_setAssociatedObject(_ threadSafety: _AssociationPolicyKindThreadSafety) {
                _setAssociatedObject(
                  newValue,
                  to: self,
                  forKey: #function,
                  threadSafety: threadSafety
                )
              }
              _macro_setAssociatedObject("Hello, World")
            }
          }
        }
      }
      """
    }
  }

  // ⚠️ Macro is not able to fully process unexpected number of args
  // ⚠️ Params handling is responsibility of API providing library
  func testCustomParams_MultipleParams() {
    assertMacro {
      """
      extension Object {
        @AssociatedObject(.copy, .nonatomic)
        var value: Int?
      }
      """
    } diagnostics: {
      """
      extension Object {
        @AssociatedObject(.copy, .nonatomic)
        ╰─ 🛑 [internal] `@AssociatedObject` received unexpected args, submit an issue here: https://github.com/capturecontext/swift-foundation-extensions
           ✏️ Remove arguments  │      ✏️ Replace arguments
        var value: Int?
      }
      """
    } fixes: {
      """
      extension Object {
        @AssociatedObject
        var value: Int?
      }
      """
    } expansion: {
      """
      extension Object {
        var value: Int? {
          get {
            return _getAssociatedObject(
              forKey: #function,
              from: self
            )
          }
          set {
            do {
              _setAssociatedObject(
                newValue,
                to: self,
                forKey: #function
              )
            }
          }
        }
      }
      """
    }
  }

  func testCustomParams_AssociationPolicy() {
    assertMacro {
      """
      extension Object {
        @AssociatedObject(.copy(.nonatomic))
        var value: Int?
      }
      """
    } expansion: {
      """
      extension Object {
        var value: Int? {
          get {
            return _getAssociatedObject(
              forKey: #function,
              from: self
            )
          }
          set {
            do {
              func _macro_setAssociatedObject(_ policy: _AssociationPolicyKind) {
                _setAssociatedObject(
                  newValue,
                  to: self,
                  forKey: #function,
                  policy: policy
                )
              }
              func _macro_setAssociatedObject(_ threadSafety: _AssociationPolicyKindThreadSafety) {
                _setAssociatedObject(
                  newValue,
                  to: self,
                  forKey: #function,
                  threadSafety: threadSafety
                )
              }
              _macro_setAssociatedObject(.copy(.nonatomic))
            }
          }
        }
      }
      """
    }
  }

  func testCustomParams_ThreadSafety() {
    assertMacro {
      """
      extension Object {
        @AssociatedObject(.atomic)
        var value: Int?
      }
      """
    } expansion: {
      """
      extension Object {
        var value: Int? {
          get {
            return _getAssociatedObject(
              forKey: #function,
              from: self
            )
          }
          set {
            do {
              func _macro_setAssociatedObject(_ policy: _AssociationPolicyKind) {
                _setAssociatedObject(
                  newValue,
                  to: self,
                  forKey: #function,
                  policy: policy
                )
              }
              func _macro_setAssociatedObject(_ threadSafety: _AssociationPolicyKindThreadSafety) {
                _setAssociatedObject(
                  newValue,
                  to: self,
                  forKey: #function,
                  threadSafety: threadSafety
                )
              }
              _macro_setAssociatedObject(.atomic)
            }
          }
        }
      }
      """
    }
  }

  func testComputedValue_CustomSetAccessor() {
    assertMacro {
      """
      extension Object {
        @AssociatedObject
        var value: Int? {
          set { print(newValue) }
        }
      }
      """
    } diagnostics: {
      """
      extension Object {
        @AssociatedObject
        var value: Int? {
            ╰─ 🛑 `@AssociatedObject` does not support custom `set` accessors
               ✏️ Use `didSet` instead
          set { print(newValue) }
        }
      }
      """
    } fixes: {
      """
      extension Object {
        @AssociatedObject
        var value: Int? {
          set { print(newValue) }
        }
      }
      """
    }
  }

  func testComputedValue_CustomWillSetDidSetAccessors() {
    assertMacro {
      """
      extension Object {
        @AssociatedObject
        var value: Int? {
          willSet { print(newValue) }
          didSet { print(oldValue) }
        }
      }
      """
    } expansion: {
      """
      extension Object {
        var value: Int? {
          willSet { print(newValue) }
          didSet { print(oldValue) }
          get {
            return _getAssociatedObject(
              forKey: #function,
              from: self
            )
          }

          set {
            let __macro_local_5valuefMu_ = value
            do {
              print(newValue)
            }
            do {
              _setAssociatedObject(
                newValue,
                to: self,
                forKey: #function
              )
            }
            do {
              let oldValue = __macro_local_5valuefMu_
              print(oldValue)
            }
          }
        }
      }
      """
    }
  }

  func testComputedValue_CustomWillSetDidSetAccessors_CustomArgs() {
    assertMacro {
      """
      extension Object {
        @AssociatedObject
        var value: Int? {
          willSet(new) { print(new) }
          didSet(old) { print(old) }
        }
      }
      """
    } expansion: {
      """
      extension Object {
        var value: Int? {
          willSet(new) { print(new) }
          didSet(old) { print(old) }
          get {
            return _getAssociatedObject(
              forKey: #function,
              from: self
            )
          }

          set {
            let __macro_local_5valuefMu_ = value
            do {
              let new = newValue
              print(new)
            }
            do {
              _setAssociatedObject(
                newValue,
                to: self,
                forKey: #function
              )
            }
            do {
              let old = __macro_local_5valuefMu_
              print(old)
            }
          }
        }
      }
      """
    }
  }

  func testStoredValue_CustomWillSetDidSetAccessors() {
    assertMacro {
      """
      extension Object {
        @AssociatedObject
        var value: Int = 0 {
          willSet { print(newValue) }
          didSet { print(oldValue) }
        }
      }
      """
    } expansion: {
      """
      extension Object {
        var value: Int = 0 {
          willSet { print(newValue) }
          didSet { print(oldValue) }
          get {
            return _getAssociatedObject(
              forKey: #function,
              from: self
            ).or(0)
          }

          set {
            let __macro_local_5valuefMu_ = value
            do {
              print(newValue)
            }
            do {
              _setAssociatedObject(
                newValue,
                to: self,
                forKey: #function
              )
            }
            do {
              let oldValue = __macro_local_5valuefMu_
              print(oldValue)
            }
          }
        }
      }
      """
    }
  }

  func testStoredValue_CustomWillSetDidSetAccessors_CustomArgs() {
    assertMacro {
      """
      extension Object {
        @AssociatedObject
        var value: Int = 0 {
          willSet(new) { print(new) }
          didSet(old) { print(old) }
        }
      }
      """
    } expansion: {
      """
      extension Object {
        var value: Int = 0 {
          willSet(new) { print(new) }
          didSet(old) { print(old) }
          get {
            return _getAssociatedObject(
              forKey: #function,
              from: self
            ).or(0)
          }

          set {
            let __macro_local_5valuefMu_ = value
            do {
              let new = newValue
              print(new)
            }
            do {
              _setAssociatedObject(
                newValue,
                to: self,
                forKey: #function
              )
            }
            do {
              let old = __macro_local_5valuefMu_
              print(old)
            }
          }
        }
      }
      """
    }
  }
}
