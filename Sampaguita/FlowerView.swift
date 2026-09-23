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
    var rotation: Angle = .zero
    @ViewBuilder var content: Content
    @Environment(\.widgetRenderingMode) private var renderingMode

    private var isFullColor: Bool {
        renderingMode == .fullColor
    }
    private var petalFill: Color {
        switch renderingMode {
        case .fullColor: petalColor
        case .accented: .white.opacity(0.6)     // Tinted or Clear Home Screen
        default: .white.opacity(0.45)           // Lock Screen
        }
    }

    private var centerFill: Color {
        switch renderingMode {
        case .fullColor: centerColor
        case .accented: .clear
        default: .white
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            ZStack {
                // Petals
                ZStack {
                    ForEach(0..<petalCount, id: \.self) { index in
                        Ellipse()
                            .fill(petalFill)
                            .shadow(color: .black.opacity(isFullColor ? 0.5 : 0), radius: 2)
                            .frame(width: size * 0.29, height: size * 0.62)
                            .offset(y: -size * 0.19)
                            .rotationEffect(.degrees(Double(index) / Double(petalCount) * 360))
                    }
                }
                .frame(width: size, height: size)
                .rotationEffect(rotation)
                .widgetAccentable()
                .mask {
                    // Cut a hole where the center circle goes, so no petal shows through it
                    Rectangle()
                        .overlay {
                            Circle()
                                .frame(width: size * 0.42, height: size * 0.42)
                                .blendMode(.destinationOut)
                        }
                        .compositingGroup()
                }

                // Center
                Circle()
                    .fill(centerFill)
                    .frame(width: size * 0.42, height: size * 0.42)
                    .overlay { Circle().stroke(.black.opacity(0.12), lineWidth: 1) }
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
    var rotation: Angle = .zero
    @Environment(\.widgetRenderingMode) private var renderingMode

    // Black on the center in full color, white when tinted
    private var textColor: Color {
        renderingMode == .fullColor ? .black : .white
    }

    var body: some View {
        FlowerView(rotation: rotation) {
            VStack(spacing: 2) {
                Text(word)
                    .font(.headline)
                    .foregroundStyle(textColor)
                    .lineLimit(word.contains(" ") ? 2 : 1)
                Text(translation)
                    .font(.caption)
                    .foregroundStyle(textColor.opacity(0.7))
                    .lineLimit(2)
            }
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.4)
            .opacity(textOpacity)
            .id(word)
            .transition(.scale.combined(with: .opacity))
        }
    }
}

#Preview("Word flower") {
    WordFlower(word: "kumusta", translation: "how are you")
        .frame(width: 170, height: 170)
}
