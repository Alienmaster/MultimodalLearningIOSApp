//
//  ButtonsSwiftUI.swift
//  Mulitmodal Learning
//
//  Created by xo on 04.07.22.
//

import SwiftUI

typealias IdBoolClosure = (String, Bool) -> Void
extension Button {
    
    enum CustomButtonStyle {
        case primary, bordered, link, custom
        
        func foregroundColor(isSelected: Bool) -> Color {
            switch self {
            case .primary: return .white
            case .bordered: return isSelected ? Color("BackgroundColor") : Color.accentColor
            case .link: return Color.accentColor
            case .custom: return Color.accentColor
            }
        }
        
        func backgroundColor(isSelected: Bool) -> Color {
            switch self {
            case .primary: return Color.accentColor
            case .bordered: return isSelected ? Color.accentColor : Color("BackgroundColor")
            case .link: return Color("BackgroundColor")
            case .custom: return .clear
            }
        }
        
        func overlayStrokeColor(isSelected: Bool) -> Color {
            switch self {
            case .primary: return .clear
            case .bordered: return isSelected ? Color("BackgroundColor") : Color.accentColor
            case .link: return .clear
            case .custom: return .clear
            }
        }
    }
    
    func styleAndHandleEyeTap(with location: CGPoint, style: CustomButtonStyle,
                              wasSelected: Bool = false, id: String? = nil,
                              tolerance: CGFloat = 40,
                              selectionClosure: IdBoolClosure? = nil) -> some View {
        GeometryReader { geometry in
            let frame = adjust(frame: geometry.frame(in: CoordinateSpace.global), tolerance: tolerance)
            let locationHits = frame.contains(.init(x: location.x, y: location.y))
            let _ = selectionClosure?(id ?? "", locationHits)
            let isSelected =  wasSelected ? wasSelected : locationHits
            self
                .foregroundColor(style.foregroundColor(isSelected: isSelected))
                .background(style.backgroundColor(isSelected: isSelected))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(style.overlayStrokeColor(isSelected: isSelected), lineWidth: 6)
                )
                .cornerRadius(12)
        }
    }
    
    func handleEyeTap(with location: CGPoint, id: String? = nil,
                      tolerance: CGFloat = 40,
                      selectionClosure: IdBoolClosure? = nil) -> some View {
        GeometryReader { geometry in
            let frame = adjust(frame: geometry.frame(in: CoordinateSpace.global), tolerance: tolerance)
            let locationHits = frame.contains(.init(x: location.x, y: location.y))
            let _ = selectionClosure?(id ?? "", locationHits)
            self
        }
    }
    
    private func adjust(frame: CGRect, tolerance: CGFloat) -> CGRect {
        CGRect(x: frame.minX - tolerance,
               y: frame.minY - tolerance,
               width: frame.width + tolerance * 2,
               height: frame.height + tolerance * 2)
    }
}
