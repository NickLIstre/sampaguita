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
            Form {
                Section("Text") {
                    Slider(value: $textOpacity, in: 0.2...1.0) { editing in
                        // Only refresh the widget when the user lets go of the slider.
                        if !editing {
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                    }

                    Text("salamat")
                        .font(.headline)
                        .opacity(textOpacity)
                }
            }
            .navigationTitle("Sampaguita")
        }
    }
}

#Preview {
    ContentView()
}
