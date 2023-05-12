//
//  View+.swift
//  Mulitmodal Learning
//
//  Created by xo on 16.06.22.
//

import SwiftUI

private let PoppinsRegularFontName = "Poppins-Regular"
private let PoppinsBoldFontName = "Poppins-Bold"

enum AppFont {
    case calibrationDescription
    
    case menuTitle
    case menuButton
    case calibrationButton
    
    case backButtonTitle
    case readingTitle
    case readingText
    case focusWordText
    
    case pageNumberText
    case nextBookText
    
    var name: String {
        switch self {
        case .calibrationButton: return PoppinsBoldFontName
        case .calibrationDescription: return PoppinsRegularFontName
            
        case .menuTitle: return PoppinsBoldFontName
        case .menuButton: return PoppinsBoldFontName
            
        case .backButtonTitle: return PoppinsBoldFontName
        case .readingTitle: return PoppinsBoldFontName
        case .readingText: return PoppinsRegularFontName
        case .focusWordText: return PoppinsBoldFontName
            
        case .pageNumberText: return PoppinsRegularFontName
        case .nextBookText: return Self.backButtonTitle.name
        }
    }
    
    var size: CGFloat {
        switch self {
        case .calibrationButton: return 18
        case .calibrationDescription: return 44
            
        case .menuTitle: return 44
        case .menuButton: return 28
            
        case .backButtonTitle: return 20
        case .readingTitle: return 20
        case .readingText: return 44 // 120
        case .focusWordText: return Self.readingText.size
        
        case .pageNumberText: return 32
        case .nextBookText: return Self.backButtonTitle.size
        }
    }
}

extension View {
    func apply(font: AppFont, size: CGFloat? = nil) -> some View {
        modifier(AppliedAppFont(name: font.name, size: size ?? font.size))
    }
}

struct AppliedAppFont: ViewModifier {
    var name: String
    var size: Double

    func body(content: Content) -> some View {
        content
            .font(.custom(name, size: size))
    }
}
