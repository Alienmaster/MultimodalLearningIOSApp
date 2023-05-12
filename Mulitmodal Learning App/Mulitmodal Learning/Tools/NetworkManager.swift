//
//  NetworkManager.swift
//  Mulitmodal Learning
//
//  Created by xo on 14.08.22.
//

import Foundation
import UIKit

enum NetworkError: Error {
     case invalidURL
     case missingImageData
 }

/// Basic Rest Network Manager
class NetworkManager {
    // MARK: - Properties
    static let shared = NetworkManager()
    
    private let baseURL = "http://134.100.15.234:8080/"
    private let bookSuffix = "books"
    private let sentenceOneSuffix = "getSentence/?bookID=" // Add BookId
    private let sentenceTwoSuffix = "&senNr=" // Add Sentence Number
    private let imageSuffix = "images/?img_name=" // Add Image Path
    
    // MARK: - Interface
    func getBooks() async throws -> [Book] {
        let string = baseURL + bookSuffix
        guard let url = URL(string: string) else { throw NetworkError.invalidURL }
        let (data, _) = try await URLSession.shared.data(from: url)
        let jsonDict = try JSONSerialization.jsonObject(with: data) as? [AnyHashable: Any] ?? [:]
        
        var books = [Book]()
        for (key, value) in jsonDict {
            let id = key
            let title = (value as? [String: Any])?["title"]
            let wordCount = (value as? [String: Any])?["wordcount"]
            
            if let id = id as? String,
               let title = title as? String,
               let wordCount = wordCount as? Int {
                books.append(.init(id: id, wordCount: wordCount, title: title))
            }
        }
        
        var adjustedBooks = books.sorted(by: { $0.wordCount > $1.wordCount })
        if let indexOfShowcaseEntry = adjustedBooks.firstIndex(where: { $0.title == "Giraffe" }) {
            adjustedBooks.swapAt(indexOfShowcaseEntry, 2)
        }
        return adjustedBooks
    }
    
    func getSentence(bookId: String, sentenceNumber: Int) async throws -> SentenceConfiguration {
        let string = baseURL + sentenceOneSuffix +  bookId + sentenceTwoSuffix + String(sentenceNumber)
        guard let url = URL(string: string) else { throw NetworkError.invalidURL }
        let (data, _) = try await URLSession.shared.data(from: url)
        let dto = try JSONDecoder().decode(SentenceConfigurationDTO.self, from: data)
        
        var focusWords = [FocusWord]()
        for focusWordDict in dto.focuswords {
            let word = focusWordDict.key
            let definition = focusWordDict.value["definition"] as? String
            let image = focusWordDict.value["image"] as? String
    
            focusWords.append(.init(word: word, definition: definition, imagePath: image))
            
        }
        return .init(text: dto.sentence, image: dto.base, focusWords: focusWords)
    }
    
    func getImage(path: String) async throws -> UIImage {
        let string = baseURL + imageSuffix + path
        guard let url = URL(string: string) else { throw NetworkError.invalidURL }
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if let image = UIImage(data: data) {
          return image
        } else {
            throw NetworkError.missingImageData
        }
    }
}
