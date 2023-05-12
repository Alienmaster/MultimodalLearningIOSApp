//
//  OneTimeSnapButton.swift
//  Mulitmodal Learning
//
//  Created by xo on 22.09.22.
//

import UIKit

class OneTimeSnapButton: BaseButton {
    
    private var didSnap: Bool = false
    
    init() {
        super.init(tolerance: 150)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func eye(on location: CGPoint) {
        guard !didSnap, checkIfEyeTrackerHit(on: location, tolerance: tolerance) else { return }
        eyeTrackingInteractionManager.hitWithTolerance(button: self, oneTimeSnap: true)
        didSnap = true
    }
}
