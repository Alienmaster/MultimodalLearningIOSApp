//
//  ProgressRing.swift
//  Mulitmodal Learning
//
//  Created by xo on 22.09.22.
//

import SwiftUI

struct ProgressRing: View {
    
    class ViewModel: ObservableObject {
        @Published var progress: Double
        let lineWidth: CGFloat
        let color: Color
        let backgroundColor: Color
        
        private var animationTimer: Timer? = nil
        private let progressStepSize: CGFloat = 0.01
        private var timeInterval: CGFloat {
            progressStepSize * Constants.durationTillButtonExecution
        }
        
        init() {
            self.progress = 0.0
            self.lineWidth = 8
            self.color = .white
            self.backgroundColor = .white.opacity(0.2)
        }
        
        func startAnimation() {
            stopAnimation()
            
            animationTimer = Timer.scheduledTimer(withTimeInterval: timeInterval,
                                                  repeats: progress < 1.0, block : { [weak self] _ in
                guard let self = self else { return }
                self.progress += self.progressStepSize
                
                if self.progress >= 1.0 {
                    self.progress = 0.0
                    self.animationTimer?.invalidate()
                }
            })
        }
        
        func stopAnimation() {
            animationTimer?.invalidate()
            progress = 0.0
        }
    }
    
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        Circle()
            .trim(from: 0, to: CGFloat(viewModel.progress))
            .rotation(.degrees(-90))
            .stroke(style: .init(lineWidth: viewModel.lineWidth, lineCap: .round))
            .foregroundColor(viewModel.color)
            .background(
                Circle()
                    .rotation(.degrees(-90))
                    .stroke(style: .init(lineWidth: viewModel.lineWidth, lineCap: .round))
                    .foregroundColor(viewModel.backgroundColor)
            )
            .padding(viewModel.lineWidth)
    }
}

struct ProgressRing_Previews: PreviewProvider {
    static var previews: some View {
        ProgressRing(viewModel: .init())
            .background(.black)
    }
}
