//
//  SampaguitaWidget.swift
//  SampaguitaWidget
//
//  Created by Nick Istre on 9/21/26.
//
//  The widget itself and everything it uses

import WidgetKit
import AppIntents
import SwiftUI

struct SampaguitaWidget: Widget {
    let kind: String = "SampaguitaWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: WidgetSettingsIntent.self, provider: WordProvider()) { entry in
            WordWidgetView(entry: entry)
                .containerBackground(Theme.background, for: .widget)
        }
        .configurationDisplayName("Word Flower")
        .description("A word and its meaning :)")
        .supportedFamilies([.accessoryRectangular, .accessoryInline, .systemSmall])
    }
}

#Preview(as: .accessoryRectangular) {
    SampaguitaWidget()
} timeline: {
    WordEntry(date: .now, word: .sample)
    WordEntry(date: .now, word: .sample)
}

#Preview("Home Screen", as: .systemSmall) {
    SampaguitaWidget()
} timeline: {
    WordEntry(date: .now, word: .sample)
    WordEntry(date: .now, word: Word(word: "kumusta", translation: "how are you"))
}
