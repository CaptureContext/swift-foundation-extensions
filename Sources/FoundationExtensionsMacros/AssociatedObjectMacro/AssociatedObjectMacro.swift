import MacroToolkit
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import Foundation

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

    do { // Unsupported accessors
      let getter = binding.accessors.first(
				where: \.accessorSpecifier.tokenKind == .keyword(.get)
			)

      if let getter {
        return context.diagnose(
					.unexpectedGetAccessor(getter.accessorSpecifier),
					return: []
				)
      }

      let setter = binding.accessors.first(
				where: \.accessorSpecifier.tokenKind == .keyword(.set)
			)

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

    var setAssociatedObjectFunc: CodeBlockSyntax? = nil

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

		case let .argumentList(args) where (1...2).contains(args.count):
			if 
				let isReadonly = args.first(where: \.label?.text == "readonly"),
				Expr(isReadonly.expression).asBooleanLiteral?.value == true
			{
				if binding.initialValue == nil {
					return context.diagnose(
						.requiresInitialValueForReadonly(binding._syntax),
						return: []
					)
				}

				if let didSetHandler {
					return context.diagnose(
						.unexpectedDidSetAccessor(didSetHandler.accessorSpecifier),
						return: []
					)
				}

				if let willSetHandler {
					return context.diagnose(
						.unexpectedWillSetAccessor(willSetHandler.accessorSpecifier),
						return: []
					)
				}
			} else if let threadSafety = args.first(where: \.label?.text == "threadSafety") {
				setAssociatedObjectFunc = CodeBlockSyntax {
					"""
					do {
						_setAssociatedObject(
							newValue,
							to: self,
							forKey: #function,
							threadSafety: \(raw: threadSafety.expression.description)
						)
					}
					"""
				}
			} else if let policy = args.first(where: \.label?.text == "policy") {
				setAssociatedObjectFunc = CodeBlockSyntax {
					"""
					do {
						_setAssociatedObject(
							newValue,
							to: self,
							forKey: #function,
							policy: \(raw: policy.expression.description)
						)
					}
					"""
				}
			} else {
				return context.diagnose(.unexpectedArguments(decl._syntax), return: [])
			}

    default:
      return context.diagnose(.unexpectedArguments(decl._syntax), return: [])
    }

		if binding.initialValue == nil {
			guard case .optional = type else {
				return context.diagnose(
					.requiresInitialValueForNonOptionals(binding._syntax),
					return: []
				)
			}
		}
		
		let getter: CodeBlockSyntax = if let initialValue = binding.initialValue {
			CodeBlockSyntax {
				"""
				return _getAssociatedObject(
					forKey: #function,
					from: self
				) ?? {
					let initialValue: \(raw: type.description) = \(raw: initialValue._syntax.trimmed.description)
					_setAssociatedObject(
						initialValue,
						to: self,
						forKey: #function
					)
					return \(raw: name)
				}()
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

		if let setAssociatedObjectFunc {
			let oldValueID = context.makeUniqueName(name)
			let isOldValueNeeded: Bool = {
				guard
					let didSetHandler,
					let body = didSetHandler.body
				else { return false }

				let parameter = didSetHandler.parameters?.name ?? "oldValue"
				return body.description.range(of: parameter.description) != nil
			}()

			let setter = CodeBlockSyntax {
				if isOldValueNeeded {
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
					// Compiler produces a warning when parameter is unused
					DoStmtSyntax {
						if isOldValueNeeded {
							"""
							let \(didSetHandler.parameters?.name ?? "oldValue") = \(oldValueID)
							"""
						}
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
		} else {
			return [
				AccessorDeclSyntax(
					accessorSpecifier: .keyword(.get),
					body: getter
				),
			]
		}
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

	static func requiresInitialValueForReadonly(_ node: some SyntaxProtocol) -> Self {
	 DiagnosticBuilder(for: node)
		 .messageID(domain: "AssociatedObject", id: "requres_initial_value_for_non-optionals")
		 .message("`@AssociatedObject` requires initial value for readonly properties.")
		 .build()
 }

  static func unexpectedGetAccessor(_ node: some SyntaxProtocol) -> Self {
    DiagnosticBuilder(for: node)
      .messageID(domain: "AssociatedObject", id: "unexpected_get_accessor")
      .message("`@AssociatedObject` does not support custom `get` accessors")
      .build()
  }

	static func unexpectedDidSetAccessor(_ node: some SyntaxProtocol) -> Self {
	 DiagnosticBuilder(for: node)
		 .messageID(domain: "AssociatedObject", id: "unexpected_get_accessor")
		 .message("Readonly `@AssociatedObject` does not support `didSet` accessors")
		 .build()
 }

	static func unexpectedWillSetAccessor(_ node: some SyntaxProtocol) -> Self {
	 DiagnosticBuilder(for: node)
		 .messageID(domain: "AssociatedObject", id: "unexpected_get_accessor")
		 .message("Readonly `@AssociatedObject` does not support `willSet` accessors")
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

  static func unexpectedArguments(_ node: VariableDeclSyntax) -> Self {
    return DiagnosticBuilder(for: node)
      .messageID(domain: "AssociatedObject", id: "unexpected_number_of_args")
      .message(
          """
          [internal] `@AssociatedObject` received unexpected args, submit an issue here: \
          https://github.com/capturecontext/swift-foundation-extensions
          """
      )
      .suggestReplacement(
        "Remove arguments",
        old: node,
        new: {
          var suggestion = node.detached
          suggestion.attributes = .init(suggestion.attributes.map { attribute in
            guard
              case var .attribute(attribute) = attribute,
              attribute.attributeName.description == "AssociatedObject"
            else { return attribute }

            attribute.arguments = nil
            attribute.leftParen = nil
            attribute.rightParen = nil

            return .attribute(attribute)
          })
          return suggestion
        }()
      )
      .suggestReplacement(
        "Replace arguments",
        old: node,
        new: {
          var suggestion = node.detached
          suggestion.attributes = .init(suggestion.attributes.map { attribute in
            guard
              case var .attribute(attribute) = attribute,
              attribute.attributeName.description == "AssociatedObject"
            else { return attribute }

            attribute.arguments = .argumentList(.init {
              LabeledExprSyntax(
								expression: ExprSyntax(stringLiteral: "<#AssociationPolicy#>")
							)
							LabeledExprSyntax(
								label: "readonly",
								expression: ExprSyntax(stringLiteral: "<#Bool#>")
							)
            })

            return .attribute(attribute)
          })
          return suggestion
        }()
      )
      .build()
  }
}
