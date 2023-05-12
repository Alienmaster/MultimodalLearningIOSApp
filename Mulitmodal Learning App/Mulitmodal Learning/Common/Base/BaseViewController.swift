//
//  BaseViewController.swift
//  Mulitmodal Learning
//
//  Created by xo on 16.06.22.
//

import UIKit

class BaseViewController: UIViewController {
    
    // MARK: - Properties
    internal var navigationBarShouldBeHidden = true

    //MARK: - iOS override properties
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
      return true
    }
    
    // MARK: - LifeCycle
    deinit {
        print("Deinit: \(String(describing: type(of:self)))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        setupDoubleTapResettingCoordinateNormaliser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if navigationBarShouldBeHidden {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    // MARK: -
    func eye(on location: CGPoint) {
        print("eye on location not implemented")
    }
    
    private func setupDoubleTapResettingCoordinateNormaliser() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(doubleTappedBackground))
        view.addGestureRecognizer(gesture)
    }
    
    @objc func doubleTappedBackground() {
        CoordinateNormaliser.shared.adjustedXOffset = 0
        CoordinateNormaliser.shared.adjustedYOffset = 0
    }
}
