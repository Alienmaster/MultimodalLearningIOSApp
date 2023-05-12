//
//  CalibrationView+ViewModel.swift
//  Mulitmodal Learning
//
//  Created by xo on 22.06.22.
//

import Foundation
import SwiftUI

extension CalibrationView {
    class ViewModel: ObservableObject {
        
        @Published var showIntroText = true
        @Published var circle1Shown = false
        @Published var circle2Shown = false
        @Published var circle3Shown = false
        @Published var circle4Shown = false
        @Published var showHaveText = false
        
        var topLeftCalibratedPoint: CGPoint = .zero
        var bottomLeftCalibratedPoint: CGPoint = .zero
        var topRightCalibratedPoint: CGPoint = .zero
        var bottomRightCalibratedPoint: CGPoint = .zero
        
        var completion: BoolClosure?
        
        init() {
            start()
        }
        
        private func start() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.show(first: true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.topLeftCalibratedPoint = Session.shared.lastLocationFromEyeTracker
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                        self?.show(second: true)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                            self?.topRightCalibratedPoint = Session.shared.lastLocationFromEyeTracker
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                                self?.show(fourth: true)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                                    self?.bottomRightCalibratedPoint = Session.shared.lastLocationFromEyeTracker
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                                        self?.show(third: true)
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                                            self?.bottomLeftCalibratedPoint = Session.shared.lastLocationFromEyeTracker
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                                                self?.show(haveFun: true)
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
                                                    self?.show()
                                                    self?.completion?(true)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        private func show(text: Bool = false, first: Bool = false,
                          second: Bool = false, third: Bool = false,
                          fourth: Bool = false, haveFun: Bool = false) {
            withAnimation { [weak self] in
                self?.showIntroText = text
                self?.circle1Shown = first
                self?.circle2Shown = second
                self?.circle3Shown = third
                self?.circle4Shown = fourth
                self?.showHaveText = haveFun
            }
        }
    }
}
