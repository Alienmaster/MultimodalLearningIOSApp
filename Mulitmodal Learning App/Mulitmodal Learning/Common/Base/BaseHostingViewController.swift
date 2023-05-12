//
//  BaseHostingViewController.swift
//  Mulitmodal Learning
//
//  Created by xo on 04.07.22.
//

import Foundation
import SwiftUI

class BaseUIHostingController<Content>: UIHostingController<Content> where Content: View {

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
      return true
    }
    
    func eye(on location: CGPoint) {
        print("eye on location not implemented")
    }
}
