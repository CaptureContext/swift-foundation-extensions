import Foundation

extension Bundle {
	@inlinable
	public var appVersionNumber: String? { infoDictionary?["CFBundleShortVersionString"] as? String }
	
	@inlinable
	public var buildVersionNumber: String? { infoDictionary?["CFBundleVersion"] as? String }
	
	@inlinable
	public var teamIdentifierPrefix: String? { infoDictionary?["TeamIdentifierPrefix"] as? String }
	
	/// KeyPrefix that can be `<bundle-id>.` or empty if BundleID is inaccessable
	@inlinable
	public var keyPrefix: String {
		return bundleIdentifier.map { $0.appending(".") }.or("")
	}
	
	/// Creates a key prefixed by bundle.keyPrefix
	@inlinable
	public func makeKey(_ key: String) -> String {
		return keyPrefix.appending(key)
	}
	
	/// Creates appGroupID with a specified teamIdentifier prefixed by bundle.teamIdentifierPrefix
	///
	/// Returns nil if teamIdentifierPrefix is inaccessable
	@inlinable
	public func appGroupID(for teamIdentifier: String) -> String? {
		return teamIdentifierPrefix.map { "\($0)\(teamIdentifier)" }
	}
}
