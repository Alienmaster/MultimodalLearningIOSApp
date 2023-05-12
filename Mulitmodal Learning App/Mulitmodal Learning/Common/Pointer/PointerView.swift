//
//  PointerView.swift
//  Mulitmodal Learning
//
//  Created by xo on 19.09.22.
//

import UIKit

class PointerView: UIView {
    
    // MARK: - Properties
    typealias Context = UIView
    
    let imageView = UIImageView()
    let progressRing = BaseUIHostingController(rootView: ProgressRing(viewModel: .init()))
    var context: Context? = nil
    
    var progressRingViewModel: ProgressRing.ViewModel {
        progressRing.rootView.viewModel
    }
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setup() {
        let buttonConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy, scale: .large)
        let eyeImage = UIImage(systemName: "eye", withConfiguration: buttonConfig)?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        imageView.image = eyeImage
        backgroundColor = .clear
        progressRing.view.backgroundColor = .clear
    }
    
    // MARK: - Layout
    private func layout() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addAndActivateAutoLayout(of: imageView, progressRing.view)
        
        NSLayoutConstraint.activate([
            progressRing.view.heightAnchor.constraint(equalToConstant: 90),
            progressRing.view.widthAnchor.constraint(equalTo: progressRing.view.heightAnchor),
            progressRing.view.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressRing.view.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        imageView.setConstraintsEqual(to: self)
    }
    
    // MARK: - Interface
    func startAnimation(context: Context? = nil) {
        self.context = context
        progressRingViewModel.startAnimation()
    }
    
    func stopAnimation(context: Context? = nil) {
        if let context {
            guard self.context == context else { return }
        }
        
        progressRingViewModel.stopAnimation()
    }
    
    func blinkImage() {
        imageView.image = imageView.image?.withTintColor(.red, renderingMode: .alwaysOriginal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.imageView.image = self?.imageView.image?.withTintColor(.white, renderingMode: .alwaysOriginal)
        }
    }
}
