import Foundation

extension NSMutableAttributedString {
	@inlinable
	public func addAttribute(_ key: Key, value: Any) {
		addAttribute(key, value: value, range: NSRange(0..<length))
	}
}

extension NSAttributedString {
	@inlinable
	public func mapRegex(
		_ regex: NSRegularExpression,
		_ transform: (NSMutableAttributedString, NSRange) -> Void
	) -> NSAttributedString {
		let attributedString = NSMutableAttributedString(attributedString: self)
		let range = NSRange(0..<length)
		let ranges = regex
			.matches(in: string, options: [], range: range)
			.map(\.range)
		
		ranges.forEach { range in
			transform(
				attributedString,
				range
			)
		}
		
		return attributedString
	}
	
	@inlinable
	public func mapRegex(
		_ regex: NSRegularExpression,
		at groupIndex: Int,
		_ transform: (NSMutableAttributedString, NSRange) -> Void
	) -> NSAttributedString {
		let attributedString = NSMutableAttributedString(attributedString: self)
		let range = NSRange(0..<length)
		let ranges = regex
			.matches(in: string, options: [], range: range)
			.map { $0.range(at: groupIndex) }
		
		ranges.forEach { range in
			transform(
				attributedString,
				range
			)
		}
		
		return attributedString
	}
}
