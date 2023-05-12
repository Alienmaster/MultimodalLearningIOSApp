//
//  UIImageView+.swift
//  Mulitmodal Learning
//
//  Created by xo on 16.06.22.
//

import UIKit

extension UIImageView {
    convenience init(contentMode: ContentMode, image: UIImage? = nil) {
        self.init(image: image)
        self.contentMode = contentMode
    }
    
    func animate(image: UIImage?, duration: CGFloat = 0.3) {
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.image = image
        }, completion: nil)
    }
}
