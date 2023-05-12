//
//  MultiLabelTextView.swift
//  Mulitmodal Learning
//
//  Created by xo on 22.06.22.
//

import UIKit
import SwiftUI

class MultiLabelTextView: UIView {
    
    // MARK: - Properties
    static let horizontalPadding: CGFloat = 16.0
    
    private let maximalWidth: CGFloat
    private let normalWordFont = UIFont(name: AppFont.readingText.name, size: AppFont.readingText.size)!
    private let focusWordFont = UIFont(name: AppFont.focusWordText.name, size: AppFont.focusWordText.size)!
    private var generatedLabels = [UILabel]()
    
    private var focusWords = [String]()
    private var currentFocusedWordString: String = ""
    
    var focusOfFocusWordStarted: ((String) -> Void)? = nil
    var focusOfFocusWordStopped: VoidClosure? = nil
    
    init(maximalWidth: CGFloat?) {
        self.maximalWidth = maximalWidth ?? DeviceHelper.screenPortraitSize.height - (Self.horizontalPadding * 2)
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    func setup(withText text: String, focusWords: [String]) {
        self.focusWords = focusWords
        
        let separatedText = text.components(separatedBy: " ")
        layout(texts: separatedText)
    }
    
    private func layout(texts: [String]) {
        
        var lastParagraphBeforeIndex = 0
        for (index, text) in texts.enumerated() {
            let label = generateLabel(text: text, isFirst: index == 0)
            generatedLabels.append(label)
            
            let labelsWidth = text.size(withFont: normalWordFont).width + PaddedActionLabel.singlePadding * 2

            let widthTillLabel = generatedLabels[lastParagraphBeforeIndex...index]
                .map({ $0.text!.size(withFont: $0.font) })
                .map({ $0.width + PaddedActionLabel.singlePadding * 2 })
                .reduce(0.0, +)
            
            let needsParagraph = CGFloat(widthTillLabel) + labelsWidth >= maximalWidth
            if needsParagraph { lastParagraphBeforeIndex = index}
            let isLastLabel = index == texts.count - 1
            
            addAndActivateAutoLayout(of: label)
            var constraints = [NSLayoutConstraint]()
            
            if index == 0 {
                constraints += [label.topAnchor.constraint(equalTo: topAnchor),
                                label.leadingAnchor.constraint(equalTo: leadingAnchor)]
            } else if needsParagraph && !isLastLabel {
                constraints += [label.topAnchor.constraint(equalTo: generatedLabels[lastParagraphBeforeIndex - 1].bottomAnchor),
                                label.leadingAnchor.constraint(equalTo: leadingAnchor)]
            } else if needsParagraph && isLastLabel {
                constraints += [label.topAnchor.constraint(equalTo: generatedLabels[lastParagraphBeforeIndex - 1].bottomAnchor),
                                label.bottomAnchor.constraint(equalTo: bottomAnchor),
                                label.leadingAnchor.constraint(equalTo: leadingAnchor)]
            } else if isLastLabel {
                constraints += [label.topAnchor.constraint(equalTo: generatedLabels[index - 1].topAnchor) ,
                                label.bottomAnchor.constraint(equalTo: bottomAnchor),
                                label.leadingAnchor.constraint(equalTo: generatedLabels[index - 1].trailingAnchor),]
            } else {
                constraints += [label.topAnchor.constraint(equalTo: generatedLabels[index - 1].topAnchor),
                                label.leadingAnchor.constraint(equalTo: generatedLabels[index - 1].trailingAnchor)]
            }
            
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    private var snapButton: BaseButton? = nil
    
    private func generateLabel(text: String, isFirst: Bool) -> UILabel {
        let label = PaddedActionLabel()
        label.text = text + " "
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        
        if isFirst {
            let snapButton = OneTimeSnapButton()
            label.addAndActivateAutoLayout(of: snapButton)
            NSLayoutConstraint.activate([
                snapButton.heightAnchor.constraint(equalTo: label.heightAnchor),
                snapButton.widthAnchor.constraint(equalTo: label.widthAnchor),
                snapButton.centerXAnchor.constraint(equalTo: label.centerXAnchor),
                snapButton.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            ])
            self.snapButton = snapButton
        }
        
        if focusWords.containsSubString(of: label.text) {
            label.isUserInteractionEnabled = true
            label.font = focusWordFont
            label.textColor = UIColor(Color("AccentColor"))
            label.action = { [weak self] in
                self?.handleLookOn(label: label)
            }
        } else {
            label.isUserInteractionEnabled = false
            label.font = normalWordFont
            label.textColor = UIColor(Color("TextColor"))
        }
        
        return label
    }
    
    func eye(on location: CGPoint) {
        snapButton?.eye(on: location)
        for label in generatedLabels {
            if label.checkIfEyeTrackerHit(on: location, tolerance: 30) {
                handleLookOn(label: label)
            } else {
                if label.text != currentFocusedWordString {
                    label.animateBackground(color: .clear)
                }
            }
        }
    }
    
    private func handleLookOn(label: UILabel) {
        let currentWordIsFocusWord = focusWords.containsSubString(of: label.text)
        guard currentWordIsFocusWord else { return }
        
        killCurrentFocusWordIfNeeded()
        
        currentFocusedWordString = label.text ?? ""
        let highlightColor = UIColor(Color("AccentColor")).withAlphaComponent(0.2)
        label.animateBackground(color: highlightColor)
        focusOfFocusWordStarted?(label.text ?? "")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
            self?.currentFocusedWordString = ""
            label.animateBackground(color: .clear)
            self?.focusOfFocusWordStopped?()
        }
    }
    
    private func killCurrentFocusWordIfNeeded() {
        guard currentFocusedWordString != "" else { return }
        let labelWithFocusWord = generatedLabels.first(where: { $0.text != nil && $0.text!.contains(currentFocusedWordString) })
        labelWithFocusWord?.animateBackground(color: .clear)
        
        currentFocusedWordString = ""
        focusOfFocusWordStopped?()
    }
}

extension String {
    func size(withFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return (self as NSString).size(withAttributes: fontAttributes)
    }
}

private extension Array where Element == String {
    func containsSubString(of string: String?) -> Bool {
        guard let string = string else { return false }
        return map({ string.contains($0) }).contains(true)
    }
}
