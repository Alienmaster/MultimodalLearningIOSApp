//
//  DeviceHelper.swift
//  Mulitmodal Learning
//
//  Created by xo on 22.06.22.
//

import Foundation
import UIKit

struct DeviceHelper {
    static let screenPortraitSize = UIScreen.main.fixedCoordinateSpace.bounds
    
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }
}
