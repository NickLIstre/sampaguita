//
//  Words.swift
//  Sampaguita
//
//  Created by Nick Istre on 9/22/26.
//

import Foundation
import AppIntents

struct Word: Codable {
    let word: String
    let translation: String

    static let sample = Word(word: "salamat", translation: "thank you")

    // Loads the word list for a language from its JSON file (empty if it fails).
    static func load(for language: Language) -> [Word] {
        guard let url = Bundle.main.url(forResource: "words-\(language.rawValue)", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let words = try? JSONDecoder().decode([Word].self, from: data)
        else { return [] }
        return words
    }
}

enum Language: String, AppEnum, CaseIterable {
    case filipino = "fil"
    case french = "fr"

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Language"
    static let caseDisplayRepresentations: [Language: DisplayRepresentation] = [
        .filipino: "Filipino",
        .french: "French"
    ]
    // The name shown in the app's picker.
    var name: String {
        switch self {
        case .filipino: "Filipino"
        case .french: "French"
        }
    }
}
