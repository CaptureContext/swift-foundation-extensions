import MacroToolkit
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct AssociatedObjectMacro: AccessorMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingAccessorsOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [AccessorDeclSyntax] {
    guard let decl = Decl(declaration).asVariable else {
      return context.diagnose(.requiresComputedProperty(declaration), return: [])
    }

    guard
      let binding = destructureSingle(decl.bindings),
      decl._syntax.bindingSpecifier.tokenKind != .keyword(.let),
      let name = binding.identifier
    else {
      return context.diagnose(.requiresComputedProperty(decl._syntax.bindingSpecifier), return: [])
    }

    guard let type = binding.type else {
      return context.diagnose(.requiresExplicitType(binding._syntax), return: [])
    }

    if binding.initialValue == nil {
      guard case .optional = type else {
        return context.diagnose(.requiresInitialValueForNonOptionals(binding._syntax), return: [])
      }
    }

    do {
      let getter = binding.accessors.first(where: \.accessorSpecifier.tokenKind == .keyword(.get))
      if let getter {
        return context.diagnose(.unexpectedGetAccessor(getter.accessorSpecifier), return: [])
      }

      let setter = binding.accessors.first(where: \.accessorSpecifier.tokenKind == .keyword(.set))
      if let setter {
        return context.diagnose(.unexpectedSetAccessor(setter.accessorSpecifier), return: [])
      }
    }

    let willSetHandler = binding.accessors.first(
      where: \.accessorSpecifier.tokenKind == .keyword(.willSet)
    )

    let didSetHandler = binding.accessors.first(
      where: \.accessorSpecifier.tokenKind == .keyword(.didSet)
    )

    let setAssociatedObjectFunc: CodeBlockSyntax

    switch node.arguments {
    case .none:
      setAssociatedObjectFunc = CodeBlockSyntax {
        """
        do {
          _setAssociatedObject(
            newValue,
            to: self,
            forKey: #function
          )
        }
        """
      }

    case let .argumentList(args) where args.count == 0:
      setAssociatedObjectFunc = CodeBlockSyntax {
        """
        do {
          _setAssociatedObject(
            newValue,
            to: self,
            forKey: #function
          )
        }
        """
      }

    case let .argumentList(args) where args.count == 1:
      setAssociatedObjectFunc = CodeBlockSyntax {
        """
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
          _macro_setAssociatedObject(\(raw: destructureSingle(args)!.description))
        }
        """
      }

    default:
      return context.diagnose(.unexpectedArguments(node), return: [])
    }

    let getter: CodeBlockSyntax = if let initialValue = binding.initialValue {
      CodeBlockSyntax {
        """
        return _getAssociatedObject(
          forKey: #function,
          from: self
        ).or(\(raw: initialValue._syntax.trimmed.description))
        """
      }
    } else {
      CodeBlockSyntax {
        """
        return _getAssociatedObject(
          forKey: #function,
          from: self
        )
        """
      }
    }

    let oldValueID = context.makeUniqueName(name)
    let setter = CodeBlockSyntax {
      if didSetHandler != nil {
        """
        let \(oldValueID) = \(raw: name)
        """
      }

      if let willSetHandler {
        DoStmtSyntax {
          if let param = willSetHandler.parameters?.name {
            """
            let \(param) = newValue
            """
          }
          if let body = willSetHandler.body {
            body.statements.trimmed
          }
        }
      }

      setAssociatedObjectFunc.statements

      if let didSetHandler {
        DoStmtSyntax {
          """
          let \(didSetHandler.parameters?.name ?? "oldValue") = \(oldValueID)
          """
          if let body = didSetHandler.body {
            body.statements.trimmed
          }
        }
      }
    }

    return [
      AccessorDeclSyntax(
        accessorSpecifier: .keyword(.get),
        body: getter
      ),
      AccessorDeclSyntax(
        accessorSpecifier: .keyword(.set),
        body: setter
      ),
    ]
  }
}

fileprivate extension Diagnostic {
  static func requiresComputedProperty(_ node: some SyntaxProtocol) -> Self {
    DiagnosticBuilder(for: node)
      .messageID(domain: "AssociatedObject", id: "requeres_computed_property")
      .message("`@AssociatedObject` must be attached to a computed property declaration.")
      .build()
  }

  static func requiresExplicitType(_ node: some SyntaxProtocol) -> Self {
    DiagnosticBuilder(for: node)
      .messageID(domain: "AssociatedObject", id: "requres_explicit_type")
      .message("`@AssociatedObject` requires explicit type declaration.")
      .build()
  }

  static func requiresInitialValueForNonOptionals(_ node: some SyntaxProtocol) -> Self {
    DiagnosticBuilder(for: node)
      .messageID(domain: "AssociatedObject", id: "requres_initial_value_for_non-optionals")
      .message("`@AssociatedObject` requires initial value for non-optional types.")
      .build()
  }

  static func unexpectedGetAccessor(_ node: some SyntaxProtocol) -> Self {
    DiagnosticBuilder(for: node)
      .messageID(domain: "AssociatedObject", id: "unexpected_get_accessor")
      .message("`@AssociatedObject` does not support custom `get` accessors")
      .build()
  }

  static func unexpectedSetAccessor(_ node: some SyntaxProtocol) -> Self {
    DiagnosticBuilder(for: node)
      .messageID(domain: "AssociatedObject", id: "unexpected_set_accessor")
      .message("`@AssociatedObject` does not support custom `set` accessors")
      .suggestReplacement(
        "Use `didSet` instead",
        old: node,
        new: TokenSyntax.keyword(.didSet)
      )
      .build()
  }

  static func unexpectedArguments(_ node: AttributeSyntax) -> Self {
    DiagnosticBuilder(for: node)
      .messageID(domain: "AssociatedObject", id: "unexpected_number_of_args")
      .message(
          """
          [internal] `@AssociatedObject` received unexpected args, submit an issue here: \
          https://github.com/capturecontext/swift-foundation-extensions
          """
      )
      .suggestReplacement(
        "Replace arguments",
        old: node,
        new: AttributeSyntax("AssociatedObject", argumentList: {
          .init(expression: ExprSyntax(literal: "<#AssociationPolicy#>"))
        })
      )
      .suggestReplacement(
        "Remove arguments",
        old: node,
        new: AttributeSyntax("AssociatedObject")
      )
      .build()
  }
}
