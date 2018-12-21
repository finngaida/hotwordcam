//
//  AnimationHelper.swift
//  Capture
//
//  Created by Finn Gaida on 05.07.17.
//  Copyright © 2017 Morsel Interactive. All rights reserved.
//

import UIKit

/// Default animation
///
/// - Parameters:
///   - duration:
///   - delay:
///   - completion:
///   - animations: 
func animateSpring(duration: TimeInterval = 0.25, delay: TimeInterval = 0, damping: CGFloat = 0.5, velocity: CGFloat = 0, completion: (() -> Void)? = nil, animations: @escaping () -> Void) {
    UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: [.allowUserInteraction, .beginFromCurrentState], animations: animations, completion: { _ in completion?() })
}

/// Mimic the Principle default animation curve
func animateLin(duration: TimeInterval = 0.25, delay: TimeInterval = 0, completion: (()->())? = nil, animations: @escaping () -> Void) {
    let animator = UIViewPropertyAnimator(duration: duration, controlPoint1: CGPoint(x: 0.25, y: 0.1), controlPoint2: CGPoint(x: 0.25, y: 1), animations: animations)
    if let c = completion {
        animator.addCompletion({ _ in
            c()
        })
    }
    animator.startAnimation(afterDelay: delay)
}
