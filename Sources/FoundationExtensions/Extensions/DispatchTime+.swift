#if canImport(Dispatch)
import Dispatch

extension DispatchTimeInterval {
	/// Creates DispatchTimeInterval.nanoseconds for the specified interval in seconds
	@inlinable
	public static func interval(_ value: TimeInterval) -> DispatchTimeInterval {
		return .nanoseconds(Int(value * pow(10, 9)))
	}
}

#if swift(>=6.0)
extension DispatchTime: @retroactive ExpressibleByFloatLiteral {}
#else
extension DispatchTime: ExpressibleByFloatLiteral {}
#endif

extension DispatchTime {
	/// Creates DispatchTime for the specified interval in seconds from `.now()`
	@inlinable
	public static func interval(_ interval: TimeInterval) -> DispatchTime {
		return .now() + .interval(interval)
	}

	@inlinable
	public init(floatLiteral value: TimeInterval) {
		self = .interval(value)
	}
}
#endif
