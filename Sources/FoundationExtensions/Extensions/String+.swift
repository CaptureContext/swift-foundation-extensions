import Foundation

extension String {
	/// Returns ranges of all occrances of subsring in string
	@inlinable
	public func ranges(
		of substring: String,
		options: CompareOptions = [],
		locale: Locale? = nil
	) -> [Range<Index>] {
		var ranges: [Range<Index>] = []
		while
			let range = range(
				of: substring,
				options: options,
				range: (ranges.last?.upperBound ?? startIndex)..<endIndex,
				locale: locale
			) {
			ranges.append(range)
		}
		return ranges
	}
}
