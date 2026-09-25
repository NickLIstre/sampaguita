import SwiftUI

struct SpinningWordFlower: View {
    var textOpacity = 1.0

    @AppStorage(SharedSettings.languageKey, store: SharedSettings.store)
    private var language = Language.filipino

    @State private var word = Word.sample

    private var words: [Word] {
        Word.load(for: language)
    }

    // Dragging
    @State private var rotation = 0.0
    @State private var lastFingerAngle: Double?
    @State private var spinThisDrag = 0.0
    @State private var coastStart: Date?
    @State private var coastSpeed = 0.0
    @State private var coastTask: Task<Void, Never>?

    // How long the flower keeps its speed, in seconds
    private let friction = 0.6
    // Reduce motion if enabled in Accessibility settings
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

            TimelineView(.animation(paused: coastStart == nil)) { timeline in
                WordFlower(word: word.word,
                           translation: word.translation,
                           textOpacity: textOpacity,
                           rotation: .degrees(currentRotation(at: timeline.date)))
            }
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if coastStart != nil {
                            rotation = currentRotation(at: .now)
                            coastStart = nil
                            coastTask?.cancel()
                        }

                        let fingerAngle = angle(of: value.location, around: center)
                        if let lastFingerAngle {
                            let change = shortestTurn(from: lastFingerAngle, to: fingerAngle)
                            rotation += change
                            spinThisDrag += change
                        }
                        lastFingerAngle = fingerAngle
                    }
                    .onEnded { value in
                        // Reduce Motion: stop spinning after release
                        let speed = reduceMotion ? 0 : fingerTurnSpeed(for: value, around: center)
                        let totalSpin = abs(spinThisDrag + speed * friction)

                        lastFingerAngle = nil
                        spinThisDrag = 0
                        coastTask?.cancel()

                        guard abs(speed) > 20 else {
                            coastStart = nil
                            if totalSpin >= 360 {
                                showNewWord()
                            }
                            return
                        }

                        coastSpeed = speed
                        coastStart = .now

                        coastTask = Task {
                            // Wait until flower almost stops spinning then show the new word
                            try? await Task.sleep(for: .seconds(friction * 3), tolerance: .zero)
                            guard !Task.isCancelled else { return }
                            if totalSpin >= 360 {
                                showNewWord()
                            }

                            try? await Task.sleep(for: .seconds(friction * 2), tolerance: .zero)
                            guard !Task.isCancelled else { return }
                            rotation = currentRotation(at: .now)
                            coastStart = nil
                        }
                    }
            )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(word.word), \(word.translation)")
        .accessibilityHint("Spin the flower to see another word")
        .accessibilityAction(named: "Another word") {
            showNewWord()
        }
        .sensoryFeedback(.success, trigger: word.word)
        .onAppear {
            word = words.randomElement() ?? .sample
        }
        .onChange(of: language) {
            showNewWord()
        }
    }

    // Where the petals are at a moment in time
    func currentRotation(at date: Date) -> Double {
        guard let coastStart else { return rotation }
        let secondsSinceRelease = date.timeIntervalSince(coastStart)
        return rotation + coastSpeed * friction * (1 - exp(-secondsSinceRelease / friction))
    }

    // The direction from the center to a point
    func angle(of point: CGPoint, around center: CGPoint) -> Double {
        atan2(point.y - center.y, point.x - center.x) * 180 / .pi
    }

    func shortestTurn(from oldAngle: Double, to newAngle: Double) -> Double {
        var change = newAngle - oldAngle
        if change > 180 { change -= 360 }
        if change < -180 { change += 360 }
        return change
    }

    func fingerTurnSpeed(for value: DragGesture.Value, around center: CGPoint) -> Double {
        let dx = value.location.x - center.x
        let dy = value.location.y - center.y
        let distanceSquared = max(dx * dx + dy * dy, 1)
        let turnSpeed = (dx * value.velocity.height - dy * value.velocity.width) / distanceSquared
        return turnSpeed * 180 / .pi
    }

    func showNewWord() {
        let otherWords = words.filter { $0.word != word.word }
        guard let newWord = otherWords.randomElement() else { return }
        withAnimation(reduceMotion ? nil : .spring(duration: 0.4, bounce: 0.5)) {
            word = newWord
        }
    }
}

#Preview {
    SpinningWordFlower()
        .frame(width: 200, height: 200)
}
