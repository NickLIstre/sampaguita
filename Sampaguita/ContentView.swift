//
//  ContentView.swift
//  Sampaguita
//
//  Created by Nick Istre on 9/21/26.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @AppStorage(SharedSettings.textOpacityKey, store: SharedSettings.store)
    private var textOpacity = 1.0
    @AppStorage(SharedSettings.languageKey, store: SharedSettings.store)
    private var language = Language.filipino
    @AppStorage(SharedSettings.updateIntervalKey, store: SharedSettings.store)
    private var updateInterval = UpdateInterval.everyHour

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SpinningWordFlower(textOpacity: textOpacity)
                    .frame(width: 200, height: 200)
                    .padding(.vertical)

                ScrollView {
                    VStack(spacing: 28) {
                        SettingBlock("Language") {
                            Picker("Language", selection: $language) {
                                ForEach(Language.allCases, id: \.self) { language in
                                    Text(language.name).tag(language)
                                }
                            }
                            .labelsHidden()
                        }

                        SettingBlock("New Word") {
                            Picker("New word", selection: $updateInterval) {
                                ForEach(UpdateInterval.allCases, id: \.self) { interval in
                                    Text(interval.name).tag(interval)
                                }
                            }
                            .labelsHidden()
                        }

                        SettingBlock("Text Opacity") {
                            Slider(value: $textOpacity, in: 0.2...1.0) { editing in
                                // Only refresh the widget when the user lets go of the slider.
                                if !editing {
                                    WidgetCenter.shared.reloadAllTimelines()
                                }
                            }
                            .accessibilityLabel("Text opacity")
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
                }
                .scrollBounceBehavior(.basedOnSize)
                .onChange(of: language) {
                    WidgetCenter.shared.reloadAllTimelines()
                }
                .onChange(of: updateInterval) {
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
            .background(Theme.background)
            .navigationTitle("Sampaguita")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Sampaguita")
                        .font(.largeTitle.bold())
                        .fontDesign(.serif)
                        .foregroundStyle(Theme.text)
                }
            }
        }
    }
}

struct SettingBlock<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Theme.text)
            content
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
}
