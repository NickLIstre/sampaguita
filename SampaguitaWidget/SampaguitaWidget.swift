//
//  SampaguitaWidget.swift
//  SampaguitaWidget
//
//  Created by Nick Istre on 9/21/26.
//

import WidgetKit
import SwiftUI

struct Word: Codable {
    let language: String
    let word: String
    let translation: String
    
    static let sample = Word(language: "fil", word: "salamat", translation: "thank you")
}

struct Provider: TimelineProvider {
    func loadWords() -> [Word] {
        guard let url = Bundle.main.url(forResource: "words", withExtension: "json"),
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
        var words = loadWords()
        if words.isEmpty {
            words = [.sample]
        }

        let startOfHour = Calendar.current.dateInterval(of: .hour, for: Date())!.start

        // Make five entries, one on each upcoming hour.
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: startOfHour)!

            // Choose word every hour
            let hoursSince1970 = Int(entryDate.timeIntervalSince1970 / 3600)
            let word = words[hoursSince1970 % words.count]

            let entry = SimpleEntry(date: entryDate, word: word)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let word: Word
}

struct SampaguitaWidgetEntryView : View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryInline:
            Text("\(entry.word.word) · \(entry.word.translation)")

        default:
            VStack {
                Text(entry.word.word)
                    .font(.headline)
                Text(entry.word.translation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct SampaguitaWidget: Widget {
    let kind: String = "SampaguitaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SampaguitaWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
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
