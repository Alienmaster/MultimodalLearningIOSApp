//
//  CoordinateNormalizer.swift
//  Mulitmodal Learning
//
//  Created by xo on 27.x6.22.
//

import UIKit

/// The EyeTracking wrapper library gives us unprecise eye-tracking coordinates. Therefore in the calibration process we track the four corner coordinates.
/// With these we can create a more precise screen rectangle. These four corner values are injected into the setup function below, during the calibration process.
/// Afterwards, all locations are converted to more precise locations on the device using the information from corner coordinates from the calibration.
/// The Adjust function at the bottom of the class is used when the pointer is snapped on a button centre. Then we assume that the user will look into the button centre.
/// When we now know that the user is looking into the centre of a button, but our convert function tells us he is looking 100 pixel higher,
/// our adjust function will calculate and set an x and y offset so that the convert function will also output that the user is looking at the button centre.
/// This is the dynamic recalibration mechanism.
class CoordinateNormaliser {
    
    static let shared = CoordinateNormaliser()
    
    var widthOfCoordinateSystem: CGFloat? = nil
    var heightOfCoordinateSystem: CGFloat? = nil
    var xValueToSubtractPointIntoZeroCorner: CGFloat? = nil
    var yValueToSubtractPointIntoZeroCorner: CGFloat? = nil
    
    var adjustedXOffset: CGFloat = .zero
    var adjustedYOffset: CGFloat = .zero
    
    func setup(tlp: CGPoint, trp: CGPoint, blp: CGPoint, brp: CGPoint) {
        // We could also only take tlp x & y but with the + blp/trp / 2 we kinda get an average
        let xValueToSubtractPointIntoZeroCorner = (tlp.x + blp.x) / 2
        let yValueToSubtractPointIntoZeroCorner = (tlp.y + trp.y) / 2
        self.xValueToSubtractPointIntoZeroCorner = xValueToSubtractPointIntoZeroCorner
        self.yValueToSubtractPointIntoZeroCorner = yValueToSubtractPointIntoZeroCorner
        
        self.widthOfCoordinateSystem = (trp.x + brp.x) / 2 - xValueToSubtractPointIntoZeroCorner
        self.heightOfCoordinateSystem = (blp.y + brp.y) / 2 - yValueToSubtractPointIntoZeroCorner
        
        self.adjustedXOffset = .zero
        self.adjustedYOffset = .zero
    }
    
    func convert(location: CGPoint) -> CGPoint {
        guard let widthOfCoordinateSystem = widthOfCoordinateSystem, let heightOfCoordinateSystem = heightOfCoordinateSystem,
              let xValueToSubtractPointIntoZeroCorner = xValueToSubtractPointIntoZeroCorner,
              let yValueToSubtractPointIntoZeroCorner = yValueToSubtractPointIntoZeroCorner else { return location }
        
        let portraitBounds = DeviceHelper.screenPortraitSize
        
        let locationXWidthPercentageInCoordinateSystem = (location.x - xValueToSubtractPointIntoZeroCorner) / widthOfCoordinateSystem
        let locationYPercentageInCoordinateSystem = (location.y - yValueToSubtractPointIntoZeroCorner) / heightOfCoordinateSystem
        let locationInDeviceCoordinateSystemX = portraitBounds.height * locationXWidthPercentageInCoordinateSystem
        let locationInDeviceCoordinateSystemY = portraitBounds.width * locationYPercentageInCoordinateSystem
        
        return .init(x: locationInDeviceCoordinateSystemX + adjustedXOffset,
                     y: locationInDeviceCoordinateSystemY + adjustedYOffset)
    }
    
    func adjust(currentLocation: CGPoint, actualLocation: CGPoint) {
        let xAdjustment = actualLocation.x - currentLocation.x
        let yAdjustment = actualLocation.y - currentLocation.y
        
        let errorTolerance: CGFloat = 500
        guard abs(xAdjustment) < errorTolerance && abs(yAdjustment) < errorTolerance else { return }
        
        self.adjustedXOffset += xAdjustment
        self.adjustedYOffset += yAdjustment
    }
}
