//
//  PaddedActionLabel.swift
//  Mulitmodal Learning
//
//  Created by xo on 15.09.22.
//

import UIKit

class PaddedActionLabel: UILabel {
    
    static let singlePadding: CGFloat = 8.0
    let topInset: CGFloat = PaddedActionLabel.singlePadding
    let bottomInset: CGFloat = PaddedActionLabel.singlePadding
    let leftInset: CGFloat = PaddedActionLabel.singlePadding
    let rightInset: CGFloat = PaddedActionLabel.singlePadding
    
    var action: VoidClosure? = nil
    
    init() {
        super.init(frame: .zero)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(gestureRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += topInset + bottomInset
            contentSize.width += leftInset + rightInset
            return contentSize
        }
    }
    
    @objc func tapped() {
        action?()
    }
}
