//
//  SharedSettings.swift
//  Sampaguita
//
//  Created by Nick Istre on 9/21/26.
//
//  Writes the settings on the home screen and connects them to the widget

import Foundation

enum UpdateInterval: Int, CaseIterable {
    case everyMinute = 1        // For testing. Remove before publishing.
    case everyHour = 60
    case every3Hours = 180
    case every6Hours = 360
    case every12Hours = 720
    case everyDay = 1440

    var name: String {
        switch self {
        case .everyMinute: "Every minute (testing)"
        case .everyHour: "Every hour"
        case .every3Hours: "Every 3 hours"
        case .every6Hours: "Every 6 hours"
        case .every12Hours: "Every 12 hours"
        case .everyDay: "Every day"
        }
    }
}

enum SharedSettings {
    static let appGroup = "group.com.blackbaccaraproductions.Sampaguita"
    static let store = UserDefaults(suiteName: appGroup)!

    static let textOpacityKey = "textOpacity"
    static let languageKey = "language"
    static let updateIntervalKey = "updateInterval"

    // The language chosen in the app (Filipino until something else is picked).
    static var language: Language {
        guard let code = store.string(forKey: languageKey),
              let language = Language(rawValue: code)
        else { return .filipino }
        return language
    }
    // How often the word changes, as chosen in the app (hourly by default)
    static var updateInterval: UpdateInterval {
        UpdateInterval(rawValue: store.integer(forKey: updateIntervalKey)) ?? .everyHour
    }
}
