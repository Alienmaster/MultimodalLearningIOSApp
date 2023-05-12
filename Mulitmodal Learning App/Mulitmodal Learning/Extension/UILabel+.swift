//
//  UILabel+.swift
//  Mulitmodal Learning
//
//  Created by xo on 15.09.22.
//

import UIKit

extension UILabel {
    func underline() {
        if let textString = self.text {
          let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                          value: NSUnderlineStyle.single.rawValue,
                                          range: NSRange(location: 0, length: attributedString.length))
          attributedText = attributedString
        }
    }
    
    func animate(toText text: String, duration: Double = 0.3) {
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: {
            self.text = text
        }, completion: nil)
    }
}
