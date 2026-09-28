//
//  WidgetSettings.swift
//  SampaguitaWidgetExtension
//
//  Created by Nick Istre on 9/27/26.
//
//  The settings that show on the widget

import AppIntents
import WidgetKit

enum IntervalChoice: Int, AppEnum {
    case sameAsApp = 0
    case everyMinute = 1        // For testing. Remove before publishing.
    case everyHour = 60
    case every3Hours = 180
    case every6Hours = 360
    case every12Hours = 720
    case everyDay = 1440

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Update Interval"
    static let caseDisplayRepresentations: [IntervalChoice: DisplayRepresentation] = [
        .sameAsApp: "Same as app",
        .everyMinute: "Every minute (testing)",
        .everyHour: "Every hour",
        .every3Hours: "Every 3 hours",
        .every6Hours: "Every 6 hours",
        .every12Hours: "Every 12 hours",
        .everyDay: "Every day"
    ]

    // How many minutes each word lasts: this widget's own choice, or the app's setting
    var minutes: Int {
        (UpdateInterval(rawValue: rawValue) ?? SharedSettings.updateInterval).rawValue
    }
}

enum LanguageChoice: String, AppEnum {
    case sameAsApp = "app"
    case filipino = "fil"
    case french = "fr"
    case german = "de"
    case italian = "it"
    case portuguese = "pt"
    case spanish = "es"

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Language"
    static let caseDisplayRepresentations: [LanguageChoice: DisplayRepresentation] = [
        .sameAsApp: "Same as app",
        .filipino: "Filipino",
        .french: "French",
        .german: "German",
        .italian: "Italian",
        .portuguese: "Portuguese",
        .spanish: "Spanish"
    ]

    // Which language to show: this widget's own choice, or the app's setting
    var language: Language {
        Language(rawValue: rawValue) ?? SharedSettings.language
    }
}

struct WidgetSettingsIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Widget Settings"
    static let description = IntentDescription("Choose the language and how often the word changes.")

    @Parameter(title: "Language", default: .sameAsApp)
    var language: LanguageChoice

    @Parameter(title: "New Word", default: .sameAsApp)
    var interval: IntervalChoice
}
