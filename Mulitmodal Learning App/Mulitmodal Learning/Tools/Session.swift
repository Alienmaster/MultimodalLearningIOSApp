//
//  Session.swift
//  Mulitmodal Learning
//
//  Created by xo on 22.06.22.
//

import UIKit
import Combine

/// This class contains properties which are shared all over the app.
class Session {
    static let shared = Session()
    
    // MARK: - Calibration
    @Published var calibrationFinished: Bool = false
    
    // MARK: - Location
    var eyeTrackerCoordinateSystem: UICoordinateSpace? = nil
    var locationClosure: LocationClosure? = nil
    
    var lastLocationFromEyeTracker: CGPoint = .init(x: 0, y: 0)
    var lastNormalisedLocation: CGPoint = .init(x: 0, y: 0)
    
    // MARK: - Live Eye Tracking Stuff
    var disableNormalisingPointerAndDirectingActionsToButtons: Bool = false
    let pointer = PointerView()
}
