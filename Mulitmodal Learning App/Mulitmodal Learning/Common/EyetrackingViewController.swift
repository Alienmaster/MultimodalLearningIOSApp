//
//  EyetrackingViewController.swift
//  Mulitmodal Learning
//
//  Created by xo on 16.06.22.
//

import EyeTracking
import UIKit

class EyeTrackingViewController: UIViewController {

    static let shared = EyeTrackingViewController()
    
    let eyeTracking = EyeTracking(configuration: Configuration(appID: "ios-eye-tracking-example"),
                                  pointer: Session.shared.pointer)
    var sessionID: String?
    var sessionTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        
        guard !DeviceHelper.isSimulator else { return }
        startNewSession()
    }

    func startNewSession() {
        if eyeTracking.currentSession != nil {
            // Only keep 1 current session data
            let session = self.eyeTracking.currentSession
            eyeTracking.endSession()
            try? EyeTracking.delete(session!)
        }
        
        eyeTracking.startSession()
        eyeTracking.loggingEnabled = false
        let session =  Session.shared
        eyeTracking.convertedLocationClosure = { [weak session] point in
            guard let closure = session?.locationClosure else { return }
            closure?(point)
        }
        sessionID = eyeTracking.currentSession?.id
    }
}
