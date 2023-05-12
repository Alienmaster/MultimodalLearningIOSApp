//
//  MenuViewController.swift
//  Mulitmodal Learning
//
//  Created by xo on 15.06.22.
//

import UIKit
import SwiftUI

extension UIResponder {
    @objc dynamic func userWantsToRecalibrate() {
        next?.userWantsToRecalibrate()
    }
}

class MenuViewController: BaseViewController {
    
    // MARK: -    
    private let titleLabel = UILabel(frame: .zero)
    private let calibrationButton = TextButton(text: "Calibrate", appFont: .calibrationButton,
                                               color: UIColor(Color("AccentColor")), alignment: .right)
    private let nextPageButton = BaseButton()
    private let collectionView = MenuCollectionView()
    private let previousPageButton = BaseButton()
    
    private var books = [Book]()
    
    // MARK: -
    init() {
        super.init(nibName: nil, bundle: nil)
        setup()
        layout()
        downloadAndInjectBooks()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setup() {
        titleLabel.font = UIFont(name: AppFont.menuTitle.name, size: AppFont.menuTitle.size)
        titleLabel.textColor = UIColor(Color("TextColor"))
        titleLabel.text = "What do you want to learn about today?"
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        
        calibrationButton.addTarget(self, action: #selector(calibrate), for: .touchUpInside)
        
        collectionView.selectionClosure = { [weak self] config in
            self?.collectionViewConfigPressed(book: config)
        }
        
        setupNextPreviousButton()
        handleButtonAppearance()
    }
    
    private func setupNextPreviousButton() {
        let pageChangeButtonConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium, scale: .large)
        let previousPageButtonImage = UIImage(systemName: "chevron.left.circle", withConfiguration: pageChangeButtonConfig)?
            .withTintColor(UIColor(Color("AccentColor")), renderingMode: .alwaysOriginal)
        let nextPageButtonImage = UIImage(systemName: "chevron.right.circle", withConfiguration: pageChangeButtonConfig)?
            .withTintColor(UIColor(Color("AccentColor")), renderingMode: .alwaysOriginal)
        
        previousPageButton.setBackgroundImage(previousPageButtonImage, for: .normal)
        nextPageButton.setBackgroundImage(nextPageButtonImage, for: .normal)
        
        previousPageButton.action = { [weak self] in
            guard let self = self else { return }
            self.collectionView.setup(newPage: (self.collectionView.page - 1))
            self.handleButtonAppearance()
        }
        
        nextPageButton.action = { [weak self] in
            guard let self = self else { return }
            self.collectionView.setup(newPage: (self.collectionView.page + 1))
            self.handleButtonAppearance()
        }
    }
    
    private func handleButtonAppearance() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            if self.collectionView.page == 0 {
                let thereIsUpcomingPage = (self.collectionView.books.count > 6 && self.collectionView.books.count  % 6 == 0)
                self.nextPageButton.set(disabled: !thereIsUpcomingPage)
                self.previousPageButton.set(disabled: true)
            } else if (self.collectionView.page + 1) >= self.collectionView.books.count / 6 {
                self.nextPageButton.set(disabled: true)
                self.previousPageButton.set(disabled: false)
            } else {
                self.nextPageButton.set(disabled: false)
                self.previousPageButton.set(disabled: false)
            }
        }
    }
    
    private func downloadAndInjectBooks() {
        Task {
            do {
                let books = try await NetworkManager.shared.getBooks()
                self.books = books
                collectionView.setup(newButtonConfigurations: books)
                handleButtonAppearance()
            } catch {
                print("Request failed with error: \(error)")
            }
        }
    }
    
    // MARK: - Layout
    private func layout() {
        let contentCenterHelperView = UIView(frame: .zero)
        
        view.addAndActivateAutoLayout(of: titleLabel, calibrationButton, previousPageButton,
                                      collectionView, nextPageButton, contentCenterHelperView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            contentCenterHelperView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            contentCenterHelperView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            previousPageButton.centerYAnchor.constraint(equalTo: contentCenterHelperView.centerYAnchor),
            previousPageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),

            collectionView.centerYAnchor.constraint(equalTo: contentCenterHelperView.centerYAnchor),
            collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nextPageButton.centerYAnchor.constraint(equalTo: contentCenterHelperView.centerYAnchor),
            nextPageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            
            calibrationButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            calibrationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        
        view.bringSubviewToFront(calibrationButton)
    }
    
    // MARK: -
    override func eye(on location: CGPoint) {
        collectionView.eye(on: location)
        [nextPageButton, previousPageButton].forEach({ $0.eye(on: location) })
    }
    
    func collectionViewConfigPressed(book: Book) {
        let readingVC = ReadingViewController(currentBook: book, allBooks: books)
        navigationController?.pushViewController(readingVC, animated: true)
    }
    
    @objc func calibrate() {
        userWantsToRecalibrate()
    }
}
