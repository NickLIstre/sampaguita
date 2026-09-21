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

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                WordFlower(word: "salamat", translation: "thank you", textOpacity: textOpacity)
                    .frame(width: 200, height: 200)
                    .padding(.vertical)

                Form {
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
