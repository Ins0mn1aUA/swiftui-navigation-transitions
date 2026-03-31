import UIKit

extension Animation {
	/// A critically damped spring animation matching the native iOS navigation transition feel.
	///
	/// - Parameter dampingRatio: The damping ratio (1.0 = critically damped, no oscillation).
	public static func spring(dampingRatio: Double = 1.0) -> Self {
		.init(
			duration: defaultDuration,
			timingParameters: UISpringTimingParameters(dampingRatio: dampingRatio),
		)
	}
}

