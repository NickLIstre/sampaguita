//
//  SampaguitaWidget.swift
//  SampaguitaWidget
//
//  Created by Nick Istre on 9/21/26.
//

import WidgetKit
import SwiftUI

struct Word: Codable {
    let word: String
    let translation: String

    static let sample = Word(word: "salamat", translation: "thank you")
}

enum Language: String {
    case filipino = "fil"
    case french = "fr"
}

struct Provider: TimelineProvider {
    func loadWords(for language: Language) -> [Word] {
        guard let url = Bundle.main.url(forResource: "words-\(language.rawValue)", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let words = try? JSONDecoder().decode([Word].self, from: data)
        else { return [] }
        return words
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), word: .sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), word: .sample)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Load the word list (if fails, use sample)
        var words = loadWords(for: .filipino)
        if words.isEmpty {
            words = [.sample]
        }
        
        let textOpacity = SharedSettings.store.object(forKey: SharedSettings.textOpacityKey) as? Double ?? 1.0

        let startOfHour = Calendar.current.dateInterval(of: .hour, for: Date())!.start

        // Make five entries, one on each upcoming hour.
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: startOfHour)!

            // Choose word every hour
            let hoursSince1970 = Int(entryDate.timeIntervalSince1970 / 3600)
            let word = words[hoursSince1970 % words.count]

            let entry = SimpleEntry(date: entryDate, word: word, textOpacity: textOpacity)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let word: Word
    var textOpacity: Double = 1.0
}

struct SampaguitaWidgetEntryView : View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryInline:
            Text("\(entry.word.word) · \(entry.word.translation)")
                .opacity(entry.textOpacity)

        case .systemSmall:
            WordFlower(word: entry.word.word,
                       translation: entry.word.translation,
                       textOpacity: entry.textOpacity)

        default:
            VStack {
                Text(entry.word.word)
                    .font(.headline)
                Text(entry.word.translation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .opacity(entry.textOpacity)
        }
    }
}

struct SampaguitaWidget: Widget {
    let kind: String = "SampaguitaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SampaguitaWidgetEntryView(entry: entry)
                .containerBackground(Theme.background, for: .widget)
        }
        .configurationDisplayName("Word of the Hour")
        .description("Learn a new Filipino word every hour.")
        .supportedFamilies([.accessoryRectangular, .accessoryInline, .systemSmall])
    }
}

#Preview(as: .accessoryRectangular) {
    SampaguitaWidget()
} timeline: {
    SimpleEntry(date: .now, word: .sample)
    SimpleEntry(date: .now, word: .sample)
}

#Preview("Home Screen", as: .systemSmall) {
    SampaguitaWidget()
} timeline: {
    SimpleEntry(date: .now, word: .sample)
    SimpleEntry(date: .now, word: Word(word: "kumusta", translation: "how are you"))
}
