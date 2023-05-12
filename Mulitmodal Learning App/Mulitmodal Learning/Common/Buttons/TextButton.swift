//
//  TextButton.swift
//  Mulitmodal Learning
//
//  Created by xo on 11.08.22.
//

import UIKit
import SwiftUI

class TextButton: BaseButton {
    
    // MARK: - Properties
    enum ImageAlignment { case left, right }
    
    // MARK: - Init
    init(text: String, appFont: AppFont, color: UIColor,
         alignment: NSTextAlignment, imageConfiguration: (UIImage, ImageAlignment)? = nil,
         tolerance: CGFloat = 20) {
        super.init(tolerance: tolerance)
        
        let font = UIFont(name: appFont.name, size: appFont.size) ?? .init()
        setTitle(text, for: .normal)
        setTitleColor(color, for: .normal)
        
        titleLabel?.font = font
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.textAlignment = alignment
        
        if let imageConfiguration = imageConfiguration {
            setImage(imageConfiguration.0, for: .normal)
            
            imageEdgeInsets = .init(top: 0, left: -16, bottom: 0, right: 0)
            
            if imageConfiguration.1 == .right {
                transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
