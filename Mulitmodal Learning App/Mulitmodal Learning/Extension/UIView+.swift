//
//  UIView+.swift
//  Mulitmodal Learning
//
//  Created by xo on 16.06.22.
//

import UIKit

extension UIView {
    func addAndActivateAutoLayout(of views: UIView?...) {
        for view in views{
            if let v = view {
                v.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(v)
            }
        }
    }
    
    
    func setConstraintsEqual(to view: UIView, padding: CGFloat) {
        let layoutConstraints = getConstraintsWhenSetEqual(to: view, padding: .init(top: padding, left: padding,
                                                                                    bottom: padding, right: padding))
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    
    func setConstraintsEqual(to view: UIView, padding: UIEdgeInsets = .zero) {
        let layoutConstraints = getConstraintsWhenSetEqual(to: view, padding: padding)
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    func getConstraintsWhenSetEqual(to view: UIView, padding: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        return [
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: padding.top),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding.left),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding.right),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding.bottom)
        ]
    }
    
    func animateBackground(color: UIColor, duration: CGFloat = 0.3) {
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: {
            self.backgroundColor = color
        }, completion: nil)
    }
    
    func animate(alpha: CGFloat, duration: CGFloat = 0.3) {
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: {
            self.alpha = alpha
        }, completion: nil)
    }
}

extension UIView {
    func checkIfEyeTrackerHit(on location: CGPoint, tolerance: CGFloat = 10) -> Bool {
        guard let coordinateSpace = Session.shared.eyeTrackerCoordinateSystem else { return false }
        let pointInCoordinateSystem = coordinateSpace.convert(.init(x: location.x, y: location.y),
                                                              to: self.coordinateSpace)
        var boundsToCheck = bounds
        boundsToCheck = CGRect(x: bounds.minX - tolerance,
                               y: bounds.minY - tolerance,
                               width: bounds.width + tolerance * 2,
                               height: bounds.height + tolerance * 2)
        
        return boundsToCheck.contains(pointInCoordinateSystem)
    }
}
