import UIKit

extension UINavigationController {
	@objc func handleInteraction(_ gestureRecognizer: UIPanGestureRecognizer) {
		guard let delegate = customDelegate else {
			return
		}
		guard let gestureRecognizerView = gestureRecognizer.view else {
			delegate.interactionController = nil
			return
		}

		let translation = gestureRecognizer.translation(in: gestureRecognizerView).x
		let width = gestureRecognizerView.bounds.size.width
		let percent = min(1, max(0, translation / width))

		switch gestureRecognizer.state {
		case .possible:
			break

		case .began:
			delegate.interactionController = UIPercentDrivenInteractiveTransition()
			popViewController(animated: true)
			delegate.interactionController?.update(percent)

		case .changed:
			delegate.interactionController?.update(percent)

		case .ended:
			let velocity = gestureRecognizer.velocity(in: gestureRecognizerView).x

			if velocity > 675 || (percent >= 0.2 && velocity > -200) {
				// Override the animator's timing to easeOut to prevent overshoot
				// (spring or other curves can cause the toView to overshoot past its
				// resting position when the interactive transition completes quickly).
				if let animator = delegate.currentAnimatorProvider?.currentAnimator {
					let remainingFraction = 1.0 - animator.fractionComplete
					animator.pauseAnimation()
					animator.continueAnimation(
						withTimingParameters: UICubicTimingParameters(animationCurve: .easeOut),
						durationFactor: CGFloat(remainingFraction),
					)
				}

				delegate.interactionController?.finish()
			} else {
				delegate.interactionController?.cancel()
			}

			delegate.interactionController = nil

		case .failed, .cancelled:
			delegate.interactionController?.cancel()
			delegate.interactionController = nil

		@unknown default:
			break
		}
	}
}
