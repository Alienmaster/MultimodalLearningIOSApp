//
//  ValibrationView.swift
//  Mulitmodal Learning
//
//  Created by xo on 22.06.22.
//

import SwiftUI

struct CircleData: Hashable {
    let width: CGFloat
    let opacity: Double
}

struct CalibrationView: View {
    
    // MARK: - Properties
    @ObservedObject var viewModel: ViewModel
    @State var isAnimating = false
    
    var body: some View {
        Button {
            viewModel.completion?(false)
        } label: {
            ZStack {
                HStack {
                    VStack {
                        pulsingView
                            .opacity(viewModel.circle1Shown ? 1.0 : 0.0)
                        Spacer()
                        pulsingView
                            .opacity(viewModel.circle3Shown ? 1.0 : 0.0)
                    }
                    
                    Spacer()
                    VStack {
                        pulsingView
                            .opacity(viewModel.circle2Shown ? 1.0 : 0.0)
                        Spacer()
                        pulsingView
                            .opacity(viewModel.circle4Shown ? 1.0 : 0.0)
                    }
                }
                
                Text("Don't move your head &\nlook into the circles.")
                    .apply(font: .calibrationDescription)
                    .foregroundColor(Color("TextColor"))
                    .multilineTextAlignment(.center)
                    .opacity(viewModel.showIntroText ? 1.0 : 0.0)
                
                Text("Have Fun looking around in the menu.\nEye-Tracking starts in 10 seconds.")
                    .apply(font: .calibrationDescription)
                    .foregroundColor(Color("TextColor"))
                    .multilineTextAlignment(.center)
                    .opacity(viewModel.showHaveText ? 1.0 : 0.0)
                    .padding()
            }
        }
        .ignoresSafeArea()
        .onAppear {
            self.isAnimating = true
        }
    }
    
    var pulsingView: some View {
        ZStack {
            Circle()
                .fill(Color.green)
                .frame(width: 50, height: 50)
                .scaleEffect(isAnimating ? 0.9 :0.97)
                .animation(.easeInOut(duration: 0.5).repeatForever(), value: isAnimating)
            
            Circle()
                .fill(Color("BackgroundColor"))
                .frame(width: 7, height: 7)
        }
    }
}

// MARK: - Preview
struct CalibrationView_Preview: PreviewProvider {
    static var previews: some View {
        CalibrationView(viewModel: .init())
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
