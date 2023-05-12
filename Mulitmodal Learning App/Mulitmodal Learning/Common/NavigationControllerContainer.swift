//
//  NavigationContainer.swift
//  Mulitmodal Learning
//
//  Created by xo on 22.06.22.
//

import UIKit
import SwiftUI
import Combine

class NavigationControllerContainer: BaseViewController {
    
    // MARK: - Properties
    private let eyeTrackingViewController = EyeTrackingViewController.shared
    private let navController: UINavigationController
    private var calibrationVC: UIViewController? = nil
    
    private let session = Session.shared
    private lazy var locationChangeHandler = LocationChangeHandler(navigationController: navController,
                                                                   eyeTrackingViewController: eyeTrackingViewController)
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Init
    init(rootViewController: UIViewController) {
        self.navController = UINavigationController(rootViewController: rootViewController)
        super.init(nibName: nil, bundle: nil)
        setup()
        layout()
        preparePresentation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup & Layout
    private func setup() {
        embed(controller: navController)
        embed(controller: eyeTrackingViewController)
        
        session.eyeTrackerCoordinateSystem = eyeTrackingViewController.view.coordinateSpace
        session.locationClosure = { [weak self] location in
            self?.locationChangeHandler.locationChanged(location: location)
        }
    }
    
    private func preparePresentation() {
        view.backgroundColor = UIColor(Color("BackgroundColor"))        
        navController.view.alpha = 0.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.userWantsToRecalibrate()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.navController.view.alpha = 1.0
        }
    }
    
    private func layout() {
        view.addAndActivateAutoLayout(of: navController.view, eyeTrackingViewController.view)
        navController.view.setConstraintsEqual(to: view)
        eyeTrackingViewController.view.setConstraintsEqual(to: view)
    }
    
}

// MARK: - Calibration
extension NavigationControllerContainer {
    override func userWantsToRecalibrate() {
        let vc = CalibrationViewController()
        self.calibrationVC = vc
        embed(controller: vc)
        
        vc.view.alpha = 0
        view.addAndActivateAutoLayout(of: vc.view)
        vc.view.setConstraintsEqual(to: view)
        
        eyeTrackingViewController.eyeTracking.hidePointer()
        
        UIView.animate(withDuration: 0.3, animations: { [weak vc] in
            vc?.view.alpha = 1.0
        }, completion: nil)
    }
    
    override func calibrationViewWantsToBeDismissed() {
        guard let vc = calibrationVC else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak vc] in
            vc?.view.alpha = 0.0
        }) { [weak self, weak vc] _ in
            vc?.view.removeFromSuperview()
            self?.unEmbed(controller: vc)
            self?.calibrationVC = nil
        }
    }
}
