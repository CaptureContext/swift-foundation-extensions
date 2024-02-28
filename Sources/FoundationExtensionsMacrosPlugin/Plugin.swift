import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct FoundationExtensionsPlugin: CompilerPlugin {
	let providingMacros: [Macro.Type] = [
		AssociatedObjectMacro.self
	]
}

