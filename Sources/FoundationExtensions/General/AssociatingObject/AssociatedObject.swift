import FoundationExtensionsMacros

@attached(accessor)
public macro AssociatedObject(
  _ policy: objc_AssociationPolicy
) = #externalMacro(
  module: "FoundationExtensionsMacros",
  type: "AssociatedObjectMacro"
)

@attached(accessor)
public macro AssociatedObject(
  _ threadSafety: _AssociationPolicyThreadSafety = .nonatomic
) = #externalMacro(
  module: "FoundationExtensionsMacros",
  type: "AssociatedObjectMacro"
)
