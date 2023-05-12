//
//  ReadingViewController.swift
//  Mulitmodal Learning
//
//  Created by xo on 16.06.22.
//

import UIKit
import SwiftUI

class ReadingViewController: BaseViewController {
    
    // MARK: - Properties
    static let labelScreenWidthMultiplier: CGFloat = 0.7
        
    private let backButtonTextButton: TextButton = {
        let backButtonConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy, scale: .large)
        let backButtonImage = UIImage(systemName: "chevron.left", withConfiguration: backButtonConfig)?
            .withTintColor(UIColor(Color("AccentColor")), renderingMode: .alwaysOriginal)
        return TextButton(text: "Back to Menu", appFont: .backButtonTitle,
                          color: UIColor(Color("AccentColor")), alignment: .left,
                          imageConfiguration: (backButtonImage!, .left), tolerance: 40)
    }()
    
    private var multiLabelView: MultiLabelTextView?
    private let imageView = UIImageView()
    private let titleLabel = UILabel(frame: .zero)
    
    private let pageNumberLabel = UILabel(frame: .zero)
    private let nextPageButton = BaseButton(tolerance: 90)
    private let previousPageButton = BaseButton()
    
    private let nextBookPreviewButton: TextButton = {
        let backButtonConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy, scale: .large)
        let forwardBockButtonImage = UIImage(systemName: "chevron.right", withConfiguration: backButtonConfig)?
            .withTintColor(UIColor(Color("AccentColor")), renderingMode: .alwaysOriginal)
        
        return TextButton(text: "", appFont: .nextBookText,
                          color: UIColor(Color("AccentColor")), alignment: .right,
                          imageConfiguration: (forwardBockButtonImage!, .right), tolerance: 200)
    }()
    
    private lazy var buttons: [BaseButton] = [backButtonTextButton, nextPageButton,
                                              previousPageButton, nextBookPreviewButton]
    
    private let allBooks: [Book]
    private struct BookConfig {
        let book: Book
        var sentenceNumber: Int = 0
        var text: String = ""
        var currentBaseImage: UIImage? = nil
        var focusWordsAndImages: [(String, UIImage)] = []
    }
    
    private var bookConfig: BookConfig

    // MARK: - View's Lifecycle
    init(currentBook: Book, allBooks: [Book]) {
        self.allBooks = allBooks
        self.bookConfig = BookConfig(book: currentBook)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupButtons()
        layout()
        
        fetchCurrentData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Setup
    private func setup() {
        view.backgroundColor = UIColor(Color("BackgroundColor"))
        
        titleLabel.font = UIFont(name: AppFont.readingTitle.name, size: AppFont.readingTitle.size)
        titleLabel.textAlignment = .left
        titleLabel.textColor = UIColor(Color("TextColor")).withAlphaComponent(0.4)
        titleLabel.text = bookConfig.book.title
        
        pageNumberLabel.font = UIFont(name: AppFont.pageNumberText.name, size: AppFont.pageNumberText.size)
        pageNumberLabel.textColor = UIColor(Color("TextColor"))
        
        imageView.layer.cornerRadius = 24.0
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
    }
    
    private func setupButtons() {
        backButtonTextButton.action = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        nextBookPreviewButton.action = { [weak self] in self?.loadNextBook(goingForward: true) }
        
        let pageChangeButtonConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium, scale: .large)
        let previousPageButtonImage = UIImage(systemName: "chevron.left.circle", withConfiguration: pageChangeButtonConfig)?
            .withTintColor(UIColor(Color("AccentColor")), renderingMode: .alwaysOriginal)
        let nextPageButtonImage = UIImage(systemName: "chevron.right.circle", withConfiguration: pageChangeButtonConfig)?
            .withTintColor(UIColor(Color("AccentColor")), renderingMode: .alwaysOriginal)
        
        previousPageButton.setImage(previousPageButtonImage, for: .normal)
        previousPageButton.action = { [weak self] in
            self?.previousPageShouldBeLoaded()
        }
        
        nextPageButton.setImage(nextPageButtonImage, for: .normal)
        nextPageButton.action = { [weak self] in
            self?.nextPageShouldBeLoaded()
        }
    }
    
    private func setupNewMultiLineTextView() {
        let maximalWidth = DeviceHelper.screenPortraitSize.height * Self.labelScreenWidthMultiplier - (MultiLabelTextView.horizontalPadding * 2)
        self.multiLabelView = MultiLabelTextView(maximalWidth: maximalWidth)
        self.multiLabelView?.focusOfFocusWordStarted = { [weak self] word in self?.handleUserLooking(atFocusWord: word) }
        self.multiLabelView?.focusOfFocusWordStopped = { [weak self] in self?.focusOfFocusWordStopped() }
        
        view.addAndActivateAutoLayout(of: self.multiLabelView)
        
        NSLayoutConstraint.activate([
            multiLabelView?.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            multiLabelView?.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: MultiLabelTextView.horizontalPadding),
            multiLabelView?.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Self.labelScreenWidthMultiplier),
        ].compactMap({ $0 }))
        
        view.sendSubviewToBack(multiLabelView!)
    }
    
    
    // MARK: - Layout
    private func layout() {
        view.addAndActivateAutoLayout(of: titleLabel, backButtonTextButton, imageView,
                                      nextPageButton, previousPageButton, pageNumberLabel,
                                      nextBookPreviewButton)
        
        NSLayoutConstraint.activate([
            
            backButtonTextButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            backButtonTextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            
            titleLabel.centerYAnchor.constraint(equalTo: backButtonTextButton.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.35),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
                        
            previousPageButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -28),
            previousPageButton.leadingAnchor.constraint(equalTo: backButtonTextButton.leadingAnchor),
            
            pageNumberLabel.centerYAnchor.constraint(equalTo: previousPageButton.centerYAnchor),
            pageNumberLabel.leadingAnchor.constraint(equalTo: previousPageButton.trailingAnchor, constant: 128),
            pageNumberLabel.trailingAnchor.constraint(equalTo: nextPageButton.leadingAnchor, constant: -128),
            
            nextPageButton.bottomAnchor.constraint(equalTo: previousPageButton.bottomAnchor),
            
            nextBookPreviewButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -28),
            nextBookPreviewButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
        ])
    }
    
    // MARK: - Data Fetching & Presentation
    private func nextPageShouldBeLoaded() {
        bookConfig.sentenceNumber += 1
        fetchCurrentData(goingForward: true)
    }
    
    private func previousPageShouldBeLoaded() {
        bookConfig.sentenceNumber -= 1
        fetchCurrentData(goingForward: false)
    }
    
    private func loadNextBook(goingForward: Bool) {
        let nextBook = getNextBook(goingForward: goingForward)
        self.bookConfig = BookConfig(book: nextBook)
        titleLabel.animate(toText: bookConfig.book.title)
        fetchCurrentData()
    }
    
    private func fetchCurrentData(goingForward: Bool = true) {
        guard bookConfig.book.wordCount > bookConfig.sentenceNumber,
              bookConfig.sentenceNumber >= 0 else {
            return
        }
        
        Task { [weak self] in
            do {
                guard let self = self else { return }
                let sentence = try await NetworkManager.shared.getSentence(bookId: self.bookConfig.book.id,
                                                                           sentenceNumber: self.bookConfig.sentenceNumber)
                
                //guard sentence.image != nil else { return self.nextPageShouldBeLoaded() } text too short handle here
                
                self.bookConfig.text = sentence.text
                self.bookConfig.currentBaseImage = sentence.image == nil ? nil : try await NetworkManager.shared.getImage(path: sentence.image!)
                
                self.bookConfig.focusWordsAndImages = []
                for focusWord in sentence.focusWords {
                    if let focusWordImage = focusWord.imagePath == nil ? nil : try await NetworkManager.shared.getImage(path: focusWord.imagePath!) {
                        self.bookConfig.focusWordsAndImages.append((focusWord.word, focusWordImage))
                    }
                }
                
                self.updateUI()
            } catch {
                print("Request failed with error: \(error)")
            }
        }
    }
    
    private func updateUI() {
        multiLabelView?.removeFromSuperview()
        setupNewMultiLineTextView()
        multiLabelView?.setup(withText: bookConfig.text, focusWords: bookConfig.focusWordsAndImages.map({ $0.0 }))
        imageView.animate(image: bookConfig.currentBaseImage)
        
        pageNumberLabel.animate(toText: "\(bookConfig.sentenceNumber + 1)/\(bookConfig.book.wordCount)")
        nextBookPreviewButton.setTitle("Go to next book: \(getNextBook(goingForward: true).title)", for: .normal)
        
        let isLastPage = bookConfig.sentenceNumber >= bookConfig.book.wordCount - 1
        let isFirstPage = bookConfig.sentenceNumber <= 0
        nextPageButton.set(disabled: isLastPage)
        previousPageButton.set(disabled: isFirstPage)
    }
    
    // MARK: - Looking at
    override func eye(on location: CGPoint) {
        multiLabelView?.eye(on: location)
        buttons.forEach({ $0.eye(on: location) })
    }
    
    private func handleUserLooking(atFocusWord word: String) {
        guard let tuple = bookConfig.focusWordsAndImages.first(where: { word.contains($0.0) }) else { return }
        imageView.animate(image: tuple.1)
    }
    
    private func focusOfFocusWordStopped() {
        imageView.animate(image: bookConfig.currentBaseImage)
    }
    
    // MARK: - Helper
    func getNextBook(goingForward: Bool) -> Book {
        let currentIndexOfBook = allBooks.firstIndex(where: { $0.title == bookConfig.book.title }) ?? 0
        var indexOfNextBook = 0
        if goingForward {
            indexOfNextBook = (allBooks.count - 1) >= (currentIndexOfBook + 1) ? currentIndexOfBook + 1 : 0
        } else {
            indexOfNextBook = (currentIndexOfBook - 1) < 0 ? allBooks.count - 1 : currentIndexOfBook - 1
        }
        return allBooks[indexOfNextBook]
    }
}
