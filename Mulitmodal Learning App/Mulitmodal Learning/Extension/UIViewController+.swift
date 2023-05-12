//
//  UIViewController+.swift
//  Mulitmodal Learning
//
//  Created by xo on 16.06.22.
//

import UIKit

extension UIViewController {

    func embed<T>(controller viewController: T) where T: UIViewController {
        addChild(viewController)
        viewController.didMove(toParent: self)
    }
    
    func unEmbed(controller: UIViewController?) {
        guard let controller = controller else { return }
        
        controller.willMove(toParent: nil)
        if controller.isViewLoaded {
            controller.view.removeFromSuperview()
        }
        controller.removeFromParent()
    }
}
