import Animator
public import UIKit

extension AnyNavigationTransition {
	/// An iOS-like navigation transition with parallax effect, dimming overlay, and edge shadow.
	///
	/// The front view slides the full screen width while the back view moves at a fraction
	/// of the speed, creating a parallax depth effect similar to the native iOS navigation transition.
	///
	/// - Parameters:
	///   - parallaxFactor: How much the back view moves relative to the front view (0...1). Default is 0.3.
	///   - dimmingAlpha: Maximum opacity of the dimming overlay on the back view. Default is 0.1.
	public static func native(parallaxFactor: CGFloat = 0.3, dimmingAlpha: CGFloat = 0.1) -> Self {
		.init(Native(parallaxFactor: parallaxFactor, dimmingAlpha: dimmingAlpha))
			.animation(.spring(dampingRatio: 1.0))
	}

	/// Equivalent to `native()` with default parameters.
	@inlinable
	public static var native: Self {
		.native()
	}
}

struct Native: PrimitiveNavigationTransition {
	let parallaxFactor: CGFloat
	let dimmingAlpha: CGFloat
	private let shadowWidth: CGFloat = 45

	private var screenCornerRadius: CGFloat {
		(UIScreen.main.value(forKey: "displayCornerRadius") as? CGFloat) ?? 0
	}

	func transition(with animator: any Animator, for operation: TransitionOperation, in context: any Context) {
		let container = context.containerView
		guard
			let fromView = context.view(forKey: .from),
			let toView = context.view(forKey: .to)
		else { return }

		let width = container.frame.width
		let height = container.frame.height
		let cornerRadius = screenCornerRadius

		// Dimming overlay (semi-transparent black over the back view)
		let dimmingView = UIView(frame: container.bounds)
		dimmingView.backgroundColor = .black
		dimmingView.isUserInteractionEnabled = false

		// Edge shadow (gradient on the left edge of the front view)
		let shadowView = makeShadowView(width: shadowWidth, height: height)

		// Save original corner radius state
		let fromCornerRadius = fromView.layer.cornerRadius
		let toCornerRadius = toView.layer.cornerRadius
		let fromCornerCurve = fromView.layer.cornerCurve
		let toCornerCurve = toView.layer.cornerCurve

		switch operation {
		case .push:
			container.insertSubview(toView, aboveSubview: fromView)
			container.insertSubview(dimmingView, belowSubview: toView)
			container.insertSubview(shadowView, belowSubview: toView)

			dimmingView.alpha = 0
			shadowView.frame.origin.x = width - shadowWidth
			toView.transform = CGAffineTransform(translationX: width, y: 0)

			if cornerRadius > 0 {
				toView.layer.cornerRadius = cornerRadius
				toView.layer.cornerCurve = .continuous
			}

			animator.addAnimations {
				toView.transform = .identity
				fromView.transform = CGAffineTransform(translationX: -width * self.parallaxFactor, y: 0)
				dimmingView.alpha = self.dimmingAlpha
				shadowView.transform = CGAffineTransform(translationX: -width, y: 0)
				toView.layer.cornerRadius = 0
			}

			animator.addCompletion { _ in
				dimmingView.removeFromSuperview()
				shadowView.removeFromSuperview()
				fromView.transform = .identity
				toView.layer.cornerRadius = toCornerRadius
				toView.layer.cornerCurve = toCornerCurve
			}

		case .pop:
			container.insertSubview(toView, belowSubview: fromView)
			container.insertSubview(dimmingView, aboveSubview: toView)
			container.insertSubview(shadowView, aboveSubview: dimmingView)

			dimmingView.alpha = dimmingAlpha
			shadowView.frame.origin.x = 0
			toView.transform = CGAffineTransform(translationX: -width * parallaxFactor, y: 0)

			if cornerRadius > 0 {
				fromView.layer.cornerRadius = cornerRadius
				fromView.layer.cornerCurve = .continuous
			}

			animator.addAnimations {
				fromView.transform = CGAffineTransform(translationX: width, y: 0)
				toView.transform = .identity
				dimmingView.alpha = 0
				shadowView.transform = CGAffineTransform(translationX: width, y: 0)
			}

			animator.addCompletion { _ in
				dimmingView.removeFromSuperview()
				shadowView.removeFromSuperview()
				fromView.transform = .identity
				toView.transform = .identity
				fromView.layer.cornerRadius = fromCornerRadius
				fromView.layer.cornerCurve = fromCornerCurve
				toView.layer.cornerRadius = toCornerRadius
				toView.layer.cornerCurve = toCornerCurve
			}
		}
	}

	private func makeShadowView(width: CGFloat, height: CGFloat) -> UIView {
		let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
		let gradient = CAGradientLayer()
		gradient.frame = view.bounds
		gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.07).cgColor]
		gradient.startPoint = CGPoint(x: 0, y: 0.5)
		gradient.endPoint = CGPoint(x: 1, y: 0.5)
		view.layer.addSublayer(gradient)
		view.isUserInteractionEnabled = false
		return view
	}
}
