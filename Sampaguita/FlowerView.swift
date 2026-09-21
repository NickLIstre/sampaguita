//
//  FlowerView.swift
//  Sampaguita
//
//  Created by Nick Istre on 9/21/26.
//

import SwiftUI
import WidgetKit

struct FlowerView<Content: View>: View {
    var petalCount = 5
    var petalColor: Color = Theme.petal
    var centerColor: Color = Theme.center
    @ViewBuilder var content: Content
    @Environment(\.widgetRenderingMode) private var renderingMode

    private var isFullColor: Bool {
        renderingMode == .fullColor
    }

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            ZStack {
                // Petals
                ForEach(0..<petalCount, id: \.self) { index in
                    Ellipse()
                        .fill(isFullColor ? petalColor : .white.opacity(0.45))
                        .shadow(color: .black.opacity(isFullColor ? 0.5 : 0), radius: 2)
                        .frame(width: size * 0.29, height: size * 0.62)
                        .offset(y: -size * 0.19)
                        .rotationEffect(.degrees(Double(index) / Double(petalCount) * 360))
                }

                // Center
                Circle()
                    .fill(isFullColor ? centerColor : .white)
                    .frame(width: size * 0.42, height: size * 0.42)
                    .overlay {
                        content
                            .padding(size * 0.05)
                    }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct WordFlower: View {
    let word: String
    let translation: String
    var textOpacity = 1.0

    var body: some View {
        FlowerView {
            VStack(spacing: 2) {
                Text(word)
                    .font(.headline)
                    .foregroundStyle(.black)
                    .lineLimit(word.contains(" ") ? 2 : 1)
                Text(translation)
                    .font(.caption)
                    .foregroundStyle(.black.opacity(0.6))
                    .lineLimit(2)
            }
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.4)
            .opacity(textOpacity)
        }
    }
}

#Preview("Word flower") {
    WordFlower(word: "kumusta", translation: "how are you")
        .frame(width: 170, height: 170)
}
