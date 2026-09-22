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

struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: Int) {
        state = UInt64(truncatingIfNeeded: seed)
    }
    
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
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

enum UpdateInterval: Int, AppEnum {
    case everyMinute = 1        // For testing. Remove before publishing.
    case everyHour = 60
    case every3Hours = 180
    case every6Hours = 360
    case every12Hours = 720
    case everyDay = 1440

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Update Interval"
    static let caseDisplayRepresentations: [UpdateInterval: DisplayRepresentation] = [
        .everyMinute: "Every minute (testing)",
        .everyHour: "Every hour",
        .every3Hours: "Every 3 hours",
        .every6Hours: "Every 6 hours",
        .every12Hours: "Every 12 hours",
        .everyDay: "Every day"
    ]
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Widget Settings"
    static let description = IntentDescription("Choose the language and how often the word changes.")

    @Parameter(title: "Language", default: .filipino)
    var language: Language

    @Parameter(title: "New Word", default: .everyHour)
    var interval: UpdateInterval
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

        let minutesPerWord = configuration.interval.rawValue
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

            let entry = SimpleEntry(date: entryDate, word: word, textOpacity: textOpacity)
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
