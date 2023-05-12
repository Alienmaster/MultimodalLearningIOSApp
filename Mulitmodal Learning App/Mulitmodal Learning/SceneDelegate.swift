//
//  SceneDelegate.swift
//  Mulitmodal Learning
//
//  Created by xo on 15.06.22.
//

import UIKit
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var subscriptions = Set<AnyCancellable>()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let navigationController = NavigationControllerContainer(rootViewController: MenuViewController())
        self.window?.rootViewController = navigationController
        setupApp()
    }
    
    private func setupApp() {
        setupEyePointerPresentationBasedOnCalibration()
    }
    
    private func setupEyePointerPresentationBasedOnCalibration() {
        EyeTrackingViewController.shared.eyeTracking.hidePointer()
        
        Session.shared.$calibrationFinished.sink { successfullyFinished in
            if successfullyFinished {
                EyeTrackingViewController.shared.eyeTracking.showPointer()
            } else {
                EyeTrackingViewController.shared.eyeTracking.hidePointer()
            }
        }.store(in: &subscriptions)
    }
}

