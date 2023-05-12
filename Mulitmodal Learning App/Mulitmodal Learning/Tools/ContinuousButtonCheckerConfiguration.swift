//
//  ContinuousButtonCheckerConfiguration.swift
//  Mulitmodal Learning
//
//  Created by xo on 22.09.22.
//

import UIKit

/// This configuration class is used inside an array from the ButtonEyeTrackingInteractionManager, to keep all the incoming buttons the pointer hovers over.
/// The class holds the reference on a button, and starts according timers, which execute injected closures for success, fail and recalibration.
/// For example after 3 seconds of no fail the success closure is executed.
/// The success timer works like the following: after Constants.durationTillButtonExecution seconds, the success closure is called (button tapped), when the fail closure was not executed.
/// The fail timer works like the following: After one second the fail closure is called. Although, if the ButtonEyeTrackingInteractionManager receives a 'user is looking at this button'
/// The fail timer is reseted. This mechanism prevents small look aways of the button to make it fail. After a couple of resets, the success timer will finish before the fail timer, which is then obsolete. 
class ContinuousButtonCheckerConfiguration {
    let button: BaseButton
    let executeOnSuccess: VoidClosure
    let executeOnFail: VoidClosure
    let executeOnRecalibration: VoidClosure
    
    private var didExecute: Bool = false
    
    private var successTimer: Timer? = nil
    private var failTimer: Timer? = nil
    private var calibrationTimer: Timer? = nil
    
    internal init(button: BaseButton,
                  executeOnSuccess: @escaping VoidClosure,
                  executeOnFail: @escaping VoidClosure,
                  executeOnRecalibration: @escaping VoidClosure) {
        self.button = button
        self.executeOnSuccess = executeOnSuccess
        self.executeOnFail = executeOnFail
        self.executeOnRecalibration = executeOnRecalibration
        
        startSuccessTimer()
        startFailTimer()
        startCalibrationTimer()
    }
    
    func startSuccessTimer() {
        successTimer = Timer.scheduledTimer(withTimeInterval: Constants.durationTillButtonExecution,
                                            repeats: false, block : { [weak self] _ in
            guard let self = self, !self.didExecute else { return }
            self.didExecute = true
            self.executeOnSuccess()
        })
    }
    
    func startCalibrationTimer() {
        calibrationTimer = Timer.scheduledTimer(withTimeInterval: 1.1,
                                                repeats: true, block : { [weak self] _ in
            guard let self = self, !self.didExecute else { return }
            self.executeOnRecalibration()
        })
    }
    
    func startFailTimer() {
        failTimer = Timer.scheduledTimer(withTimeInterval: 1.0,
                                         repeats: false, block : { [weak self] _ in
            guard let self = self, !self.didExecute else { return }
            self.didExecute = true
            self.executeOnFail()
        })
    }
    
    
    func resetFailTimer() {
        failTimer?.invalidate()
        startFailTimer()
    }
}
