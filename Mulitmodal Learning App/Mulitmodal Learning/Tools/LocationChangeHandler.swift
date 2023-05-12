//
//  LocationChangeHandler.swift
//  Mulitmodal Learning
//
//  Created by xo on 21.09.22.
//

import UIKit

/// This class receives the location updates of the eye-tracking library and then converts it with the help of the CoordinateNormaliser.
/// Finally it directs the location to the sub views of the current navigation controller, so they can handle actions, like taps.
class LocationChangeHandler {
    private let session = Session.shared
    private let navigationController: UINavigationController
    private let eyeTrackingViewController: EyeTrackingViewController
    
    init(navigationController: UINavigationController, eyeTrackingViewController: EyeTrackingViewController) {
        self.navigationController = navigationController
        self.eyeTrackingViewController = eyeTrackingViewController
    }
    
    func locationChanged(location: CGPoint) {
        session.lastLocationFromEyeTracker = location

        guard session.calibrationFinished else { return }
        
        let eyeLocation =  CoordinateNormaliser.shared.convert(location: location)
        session.lastNormalisedLocation = eyeLocation
        
        guard !session.disableNormalisingPointerAndDirectingActionsToButtons else { return }
        eyeTrackingViewController.eyeTracking.manualPointerLocation = (eyeLocation)
        
        (navigationController.topViewController as? BaseViewController)?.eye(on: eyeLocation)
        (navigationController.topViewController as? MenuViewController)?.eye(on: eyeLocation)
    }
}
