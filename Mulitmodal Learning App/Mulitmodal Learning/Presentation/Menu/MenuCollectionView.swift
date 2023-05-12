//
//  MenuCollectionView.swift
//  Mulitmodal Learning
//
//  Created by xo on 11.08.22.
//

import Foundation
import UIKit

class MenuCollectionView: UIView {
    
    // MARK: - Properties
    var selectionClosure: ((Book) -> Void)? = nil
    
    private(set) var page = 0
    private(set) var books: [Book] = []
    private var selectedButtonTitle = ""
    
    private let topLeftButton = AsyncImageButton()
    private let topMidButton = AsyncImageButton()
    private let topRightButton = AsyncImageButton()
    private let bottomLeftButton = AsyncImageButton()
    private let bottomMidButton = AsyncImageButton()
    private let bottomRightButton = AsyncImageButton()
    
    private lazy var buttons = [topLeftButton, topMidButton, topRightButton,
                                bottomLeftButton, bottomMidButton, bottomRightButton]
    
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
    func setup(newButtonConfigurations: [Book]? = nil, newPage: Int? = nil, newSelectedButtonTitle: String? = nil) {
        if let newPage = newPage {
            guard newPage >= 0,
                  newPage < ((newButtonConfigurations ?? books).count / 6) else { return }
            self.page = newPage
        }
        
        if let newSelectedButtonTitle = newSelectedButtonTitle {
            self.selectedButtonTitle = newSelectedButtonTitle
        }
        
        if let newButtonConfigurations = newButtonConfigurations {
            self.books = newButtonConfigurations
        }
        
        guard !self.books.isEmpty else { return }
        
        let start = (page * 6)
        var end = (6 * (page + 1)) - 1
        
        if end > books.count { end = books.count - 1 }
        let currentBooks = books[start...end]
        for (button, book) in zip(buttons, currentBooks) {
            button.setup(book: book)
            button.action = { [weak self] in
                self?.selectionClosure?(book)
            }
        }
    }
    
    // MARK: - Layout
    private func layout() {
        addAndActivateAutoLayout(of: topLeftButton, topMidButton, topRightButton,
                                 bottomLeftButton, bottomMidButton, bottomRightButton)
        
        let padding: CGFloat = 50.0
        NSLayoutConstraint.activate([
            topLeftButton.topAnchor.constraint(equalTo: topAnchor),
            topLeftButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            topMidButton.topAnchor.constraint(equalTo: topAnchor),
            topMidButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            topMidButton.leadingAnchor.constraint(equalTo: topLeftButton.trailingAnchor, constant: padding),
            
            topRightButton.topAnchor.constraint(equalTo: topAnchor),
            topRightButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            topRightButton.leadingAnchor.constraint(equalTo: topMidButton.trailingAnchor, constant: padding),
            
            bottomLeftButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomLeftButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomLeftButton.topAnchor.constraint(equalTo: topLeftButton.bottomAnchor, constant: padding),
            
            bottomMidButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomMidButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            bottomMidButton.leadingAnchor.constraint(equalTo: bottomLeftButton.trailingAnchor, constant: padding),
            
            bottomRightButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomRightButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomRightButton.leadingAnchor.constraint(equalTo: bottomMidButton.trailingAnchor, constant: padding),
        ])
    }
    
    // MARK: - Eye
    func eye(on location: CGPoint) {
        buttons.forEach({ $0.eye(on: location) })
    }
}
