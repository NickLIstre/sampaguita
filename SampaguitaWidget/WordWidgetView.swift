//
//  WordWidgetView.swift
//  SampaguitaWidgetExtension
//
//  Created by Nick Istre on 9/27/26.
//
//  Styling for the widget

import SwiftUI
import WidgetKit

struct WordWidgetView : View {
    var entry: WordProvider.Entry

    @Environment(\.widgetFamily) var family

    var body: some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(entry.word.word), \(entry.word.translation)")
    }

    @ViewBuilder
    private var content: some View {
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
