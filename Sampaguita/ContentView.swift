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

                Form {
                    Section("Language") {
                        Picker("Language", selection: $language) {
                            ForEach(Language.allCases, id: \.self) { language in
                                Text(language.name).tag(language)
                            }
                        }
                    }
                    Section("New Word") {
                        Picker("New word", selection: $updateInterval) {
                            ForEach(UpdateInterval.allCases, id: \.self) { interval in
                                Text(interval.name).tag(interval)
                            }
                        }
                    }
                    Section("Text") {
                        Slider(value: $textOpacity, in: 0.2...1.0) { editing in
                            // Only refresh the widget when the user lets go of the slider.
                            if !editing {
                                WidgetCenter.shared.reloadAllTimelines()
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
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
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
