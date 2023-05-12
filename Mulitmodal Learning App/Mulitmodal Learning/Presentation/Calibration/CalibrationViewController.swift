//
//  CalibrationViewController.swift
//  Mulitmodal Learning
//
//  Created by xo on 22.06.22.
//

import UIKit
import SwiftUI

extension UIResponder {
    @objc dynamic func calibrationViewWantsToBeDismissed() {
        next?.calibrationViewWantsToBeDismissed()
    }
}

class CalibrationViewController: UIHostingController<CalibrationView> {

    // MARK: -
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
      return true
    }
    
    // MARK: -
    init() {
        let viewModel = CalibrationView.ViewModel()
        super.init(rootView: CalibrationView(viewModel: viewModel))
        setup()
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    func setup() {
        Session.shared.calibrationFinished = false
        view.backgroundColor = UIColor(Color("BackgroundColor"))
        
        rootView.viewModel.completion = { [weak self] successfullyFinished in
            self?.handleCalibrationFinish()
            self?.calibrationViewWantsToBeDismissed()
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                Session.shared.calibrationFinished = successfullyFinished
            }
        }
    }
    
    private func handleCalibrationFinish() {
        let viewModel = rootView.viewModel
        CoordinateNormaliser.shared.setup(tlp: viewModel.topLeftCalibratedPoint,
                                          trp: viewModel.topRightCalibratedPoint,
                                          blp: viewModel.bottomLeftCalibratedPoint,
                                          brp: viewModel.bottomRightCalibratedPoint)
    }
}
