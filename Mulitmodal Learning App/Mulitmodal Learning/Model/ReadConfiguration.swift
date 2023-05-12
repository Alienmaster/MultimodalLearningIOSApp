//
//  ReadConfiguration.swift
//  Mulitmodal Learning
//
//  Created by xo on 26.06.22.
//

import Foundation

struct Book {
    let id: String
    let wordCount: Int
    let title: String
}

struct SentenceConfigurationDTO: Codable {
    let sentence: String
    let base: String?
    let focuswords: [String: [String: String?]]
}

struct SentenceConfiguration {
    let text: String
    let image: String?
    let focusWords: [FocusWord]
}

struct FocusWord {
    let word: String
    let definition: String?
    let imagePath: String?
}
