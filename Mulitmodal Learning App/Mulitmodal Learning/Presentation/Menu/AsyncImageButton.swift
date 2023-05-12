//
//  AsyncImageButton.swift
//  Mulitmodal Learning
//
//  Created by xo on 19.09.22.
//

import UIKit
import SwiftUI

class AsyncImageButton: BaseButton {
    
    // MARK: - Properties
    static let dimension: CGFloat = 260.0
    
    private let button = BaseButton()
    private let topicImageView = UIImageView(contentMode: .scaleAspectFill)
    private let topicTitleLabel = PaddedActionLabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Init
    init() {
        super.init()
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setup() {
        topicImageView.layer.cornerRadius = 24
        topicImageView.layer.masksToBounds = true
        
        topicTitleLabel.font = UIFont(name: AppFont.menuButton.name, size: AppFont.menuButton.size)
        topicTitleLabel.textAlignment = .left
        topicTitleLabel.textColor = UIColor(Color("TextColor"))
        topicTitleLabel.layer.cornerRadius = 8
        topicTitleLabel.layer.masksToBounds = true
        topicTitleLabel.backgroundColor = .black.withAlphaComponent(0.6)
        topicTitleLabel.numberOfLines = 0
        topicTitleLabel.lineBreakMode = .byWordWrapping
        
        activityIndicator.hidesWhenStopped = true
    }
    
    func setup(book: Book) {
        topicTitleLabel.animate(toText: book.title)
        //activityIndicator.startAnimating()
        
        Task { [weak self] in
            do {
                guard let self = self else { return }
                
                let sentence = try await NetworkManager.shared.getSentence(bookId: book.id, sentenceNumber: 0)
                let image = try await NetworkManager.shared.getImage(path: sentence.image!)
                
                self.activityIndicator.stopAnimating()
                self.topicImageView.animate(image: image)
            } catch {
                print("Request failed with error: \(error)")
            }
        }
    }
    
    // MARK: - Layout
    private func layout() {
        addAndActivateAutoLayout(of: topicImageView, topicTitleLabel, activityIndicator)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Self.dimension),
            widthAnchor.constraint(equalTo: heightAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            topicTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            topicTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            topicTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -36)
        ])
        
        topicImageView.setConstraintsEqual(to: self)
    }
}
