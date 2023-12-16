import SwiftDiagnostics
import SwiftSyntaxMacros

extension MacroExpansionContext {
	func diagnose<T>(_ diagnostic: Diagnostic, return value: T) -> T {
		self.diagnose(diagnostic)
		return value
	}
}
