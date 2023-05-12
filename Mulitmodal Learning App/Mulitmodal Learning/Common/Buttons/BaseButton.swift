//
//  BaseButton.swift
//  Mulitmodal Learning
//
//  Created by xo on 12.08.22.
//

import UIKit

class BaseButton: UIButton {
    
    // MARK: - Properties
    var action: VoidClosure?
    
    internal let eyeTrackingInteractionManager = ButtonEyeTrackingInteractionManager.shared
    internal let tolerance: CGFloat
    
    internal var semaphoreActive = false
    internal var isDisabled = false
    
    // MARK: - Init
    init(tolerance: CGFloat = 20) {
        self.tolerance = tolerance
        super.init(frame: .zero)
        addTarget(self, action: #selector(executeAction), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Interface
    @objc func executeAction() {
        guard !semaphoreActive else { return }
        action?()
        handleSemaphore()
    }
    
    func set(disabled: Bool) {
        isDisabled = disabled
        animate(alpha: disabled ? 0.3 : 1.0)
    }
    
    func eye(on location: CGPoint) {
        guard !isDisabled, checkIfEyeTrackerHit(on: location, tolerance: tolerance) else { return }
        eyeTrackingInteractionManager.hitWithTolerance(button: self)
    }
    
    // MARK: - Helper
    private func handleSemaphore() {
        semaphoreActive = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.semaphoreActive = false
        }
    }
}
