@attached(accessor)
public macro AssociatedObject(
	policy: objc_AssociationPolicy,
	readonly: Bool
) = #externalMacro(
	module: "FoundationExtensionsMacrosPlugin",
	type: "AssociatedObjectMacro"
)

@attached(accessor)
public macro AssociatedObject(
	threadSafety: _AssociationPolicyThreadSafety = .nonatomic,
	readonly: Bool = true
) = #externalMacro(
	module: "FoundationExtensionsMacrosPlugin",
	type: "AssociatedObjectMacro"
)
