//
//  ButtonEyeTrackingInteractionManager.swift
//  Mulitmodal Learning
//
//  Created by xo on 21.09.22.
//

import UIKit

/// This class handles the button and pointer interaction, so buttons are triggered after 3 seconds + snapping and recalibrating.
/// When a button (BaseButton) gets the location from above and acknowledges being hit, it calls the hitWithTolerance function of this class.
/// From there on the button will be snapped, and the system recalibrates.
/// Also the success of the button being looked at for 3 seconds as well as receiving new button calls is handled here.
class ButtonEyeTrackingInteractionManager {
    
    //MARK: - Properties
    static let shared = ButtonEyeTrackingInteractionManager()
    
    private var session = Session.shared
    private var coordinateNormaliser = CoordinateNormaliser.shared
    private var eyeTrackingViewController = EyeTrackingViewController.shared
    
    private var buttonCheckerConfigurations = [ContinuousButtonCheckerConfiguration]()
    
    private var lastLockedButton: BaseButton?
    
    //MARK: - Interface
    func hitWithTolerance(button: BaseButton, oneTimeSnap: Bool = false) {
        guard !buttonCheckerConfigurations.contains(button: button) else {
            return buttonCheckerConfigurations.resetFailTimer(for: button)
        }
        
        buttonCheckerConfigurations.clearAllConfigurations()
        
        guard button != lastLockedButton else { return }
        handleLastLockedButton(button: button)
        
        if !oneTimeSnap {
            let config = generateConfig(for: button)
            buttonCheckerConfigurations.append(config)
            session.pointer.startAnimation(context: button)
        }
        
        disabledAndAdjustPointer(button: button, oneTimeSnap: oneTimeSnap)
    }
    
    // MARK: - Helper
    /// Handles that a button is not locked on too many times in short intervalls
    private func handleLastLockedButton(button: BaseButton) {
        self.lastLockedButton = button
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.durationTillButtonExecution + 1) { [weak self] in
            guard let self = self else { return }
            if self.lastLockedButton == button {
                self.lastLockedButton = nil
            }
        }
    }
    
    private func generateConfig(for button: BaseButton) -> ContinuousButtonCheckerConfiguration {
        ContinuousButtonCheckerConfiguration(button: button,
                                             executeOnSuccess: { [weak self, weak button] in
            guard let self = self, let button = button,
                  self.buttonCheckerConfigurations.contains(button: button) else { return }
            button.executeAction()
            self.buttonCheckerConfigurations.removeConfig(of: button)
        }, executeOnFail: { [weak self, weak button] in
            guard let self = self, let button = button else { return }
            self.buttonCheckerConfigurations.removeConfig(of: button)
            self.session.pointer.stopAnimation(context: button)
        }, executeOnRecalibration: {
            [weak self, weak button] in
            guard let self = self, let button = button else { return }
            self.disabledAndAdjustPointer(button: button)
        })
    }
    
    private func disabledAndAdjustPointer(button: BaseButton, oneTimeSnap: Bool = false) {
        session.disableNormalisingPointerAndDirectingActionsToButtons = true
        let buttonCenterInEyeTrackingCoordinateSystem = centerPointer(on: button)
        //session.pointer.blinkImage()
        DispatchQueue.main.asyncAfter(deadline: .now() + (oneTimeSnap ? 0.2 : 0.5)) { [weak self] in
            guard let self = self else { return }
            self.coordinateNormaliser.adjust(currentLocation: self.session.lastNormalisedLocation,
                                             actualLocation: buttonCenterInEyeTrackingCoordinateSystem)
            self.session.disableNormalisingPointerAndDirectingActionsToButtons = false
        }
    }
    
    private func centerPointer(on view: UIView) -> CGPoint {
        guard let eyeTrackerCoordinateSpace = Session.shared.eyeTrackerCoordinateSystem else { return .zero }
        let buttonCenterInEyeTrackingCoordinateSystem = view.superview!.coordinateSpace.convert(view.center, to: eyeTrackerCoordinateSpace)
        let pointerFrame = session.pointer.frame
        eyeTrackingViewController.eyeTracking.manualPointerLocation = .init(x: buttonCenterInEyeTrackingCoordinateSystem.x - pointerFrame.width / 2,
                                                                            y: buttonCenterInEyeTrackingCoordinateSystem.y - pointerFrame.height / 2)
        return buttonCenterInEyeTrackingCoordinateSystem
    }
}

// MARK: - Array Extension
fileprivate extension Array where Element == ContinuousButtonCheckerConfiguration {
    func contains(button: BaseButton) -> Bool {
        map({ $0.button }).contains(button)
    }
    
    func resetFailTimer(for button: BaseButton) {
        first(where: { $0.button == button })?.resetFailTimer()
    }
    
    mutating func removeConfig(of button: BaseButton) {
        removeAll(where: { $0.button == button })
    }
    
    func clearAllConfigurations() {
        forEach({ $0.executeOnFail() })
    }
}
