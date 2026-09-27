//
//  WordProvider.swift
//  SampaguitaWidgetExtension
//
//  Created by Nick Istre on 9/27/26.
//
//  Decides which word the widget shows and when

import Foundation
import WidgetKit

struct WordProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> WordEntry {
        WordEntry(date: Date(), word: .sample)
    }

    func snapshot(for configuration: WidgetSettingsIntent, in context: Context) async -> WordEntry {
        WordEntry(date: Date(), word: .sample)
    }

    func timeline(for configuration: WidgetSettingsIntent, in context: Context) async -> Timeline<WordEntry> {
        var entries: [WordEntry] = []

        // Load the word list (if fails, use sample)
        var words = Word.load(for: configuration.language.language)
        if words.isEmpty {
            words = [.sample]
        }
        
        let textOpacity = SharedSettings.store.object(forKey: SharedSettings.textOpacityKey) as? Double ?? 1.0

        let minutesPerWord = configuration.interval.minutes
        let firstSlotStart = slotStart(containing: Date(), minutesPerWord: minutesPerWord)

        // Make five entries, one at the start of each upcoming slot
        for step in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: step * minutesPerWord, to: firstSlotStart)!

            // Shuffle the words once per round, then take this slot's word from the shuffled list
            let slot = slotNumber(for: entryDate, minutesPerWord: minutesPerWord)
            let round = slot / words.count
            let position = slot % words.count
            var generator = SeededGenerator(seed: round)
            let word = words.shuffled(using: &generator)[position]

            let entry = WordEntry(date: entryDate, word: word, textOpacity: textOpacity)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
    // The start of the slot a date falls in
    func slotStart(containing date: Date, minutesPerWord: Int) -> Date {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let minutesIntoDay = calendar.dateComponents([.minute], from: startOfDay, to: date).minute!
        let slotInDay = minutesIntoDay / minutesPerWord
        return calendar.date(byAdding: .minute, value: slotInDay * minutesPerWord, to: startOfDay)!
    }

    // A number that goes up by 1 for every slot, counted in the phone's own time zone
    func slotNumber(for date: Date, minutesPerWord: Int) -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let firstDay = calendar.startOfDay(for: Date(timeIntervalSince1970: 0))
        let days = calendar.dateComponents([.day], from: firstDay, to: startOfDay).day!
        let minutesIntoDay = calendar.dateComponents([.minute], from: startOfDay, to: date).minute!
        return days * (1440 / minutesPerWord) + minutesIntoDay / minutesPerWord
    }
}

struct WordEntry: TimelineEntry {
    let date: Date
    let word: Word
    var textOpacity: Double = 1.0
}
