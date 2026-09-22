//
//  SampaguitaWidget.swift
//  SampaguitaWidget
//
//  Created by Nick Istre on 9/21/26.
//

import WidgetKit
import AppIntents
import SwiftUI


struct Word: Codable {
    let word: String
    let translation: String

    static let sample = Word(word: "salamat", translation: "thank you")
}

enum Language: String, AppEnum {
    case filipino = "fil"
    case french = "fr"

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Language"
    static let caseDisplayRepresentations: [Language: DisplayRepresentation] = [
        .filipino: "Filipino",
        .french: "French"
    ]
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Choose Language"
    static let description = IntentDescription("Pick which language this widget shows.")

    @Parameter(title: "Language", default: .filipino)
    var language: Language
}

struct Provider: AppIntentTimelineProvider {
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

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), word: .sample)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Load the word list (if fails, use sample)
        var words = loadWords(for: configuration.language)
        if words.isEmpty {
            words = [.sample]
        }
        
        let textOpacity = SharedSettings.store.object(forKey: SharedSettings.textOpacityKey) as? Double ?? 1.0

        let startOfHour = Calendar.current.dateInterval(of: .minute, for: Date())!.start

        // Make five entries, one on each upcoming hour.
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset, to: startOfHour)!

            // Choose word every hour
            let hoursSince1970 = Int(entryDate.timeIntervalSince1970 / 60)
            let word = words[hoursSince1970 % words.count]

            let entry = SimpleEntry(date: entryDate, word: word, textOpacity: textOpacity)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        return Timeline(entries: entries, policy: .atEnd)
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
            HStack(spacing: 8) {
                FlowerView { }
                    .frame(width: 44, height: 44)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(entry.word.word)
                        .font(.headline)
                    Text(entry.word.translation)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .opacity(entry.textOpacity)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct SampaguitaWidget: Widget {
    let kind: String = "SampaguitaWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            SampaguitaWidgetEntryView(entry: entry)
                .containerBackground(Theme.background, for: .widget)
        }
        .configurationDisplayName("Word of the Hour")
        .description("Learn a new word every hour.")
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
