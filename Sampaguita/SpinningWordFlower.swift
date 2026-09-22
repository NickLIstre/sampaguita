import SwiftUI

struct SpinningWordFlower: View {
    var textOpacity = 1.0

    @State private var words = Word.load(for: .filipino)
    @State private var word = Word.sample

    // Dragging
    @State private var rotation = 0.0
    @State private var lastFingerAngle: Double?
    @State private var spinThisDrag = 0.0
    @State private var coastStart: Date?
    @State private var coastSpeed = 0.0
    @State private var coastTask: Task<Void, Never>?

    // How long the flower keeps its speed, in seconds
    private let friction = 0.6

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
                        coastSpeed = fingerTurnSpeed(for: value, around: center)
                        coastStart = .now

                        let totalSpin = abs(spinThisDrag + coastSpeed * friction)
                        lastFingerAngle = nil
                        spinThisDrag = 0

                        coastTask = Task {
                            try? await Task.sleep(for: .seconds(friction * 3))
                            guard !Task.isCancelled else { return }
                            // A full spin or more shows new word
                            if totalSpin >= 360 {
                                showNewWord()
                            }

                            try? await Task.sleep(for: .seconds(friction * 5))
                            guard !Task.isCancelled else { return }
                            rotation = currentRotation(at: .now)
                            coastStart = nil
                        }
                    }
            )
        }
        .sensoryFeedback(.success, trigger: word.word)
        .onAppear {
            word = words.randomElement() ?? .sample
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
        withAnimation(.spring(duration: 0.4, bounce: 0.5)) {
            word = newWord
        }
    }
}

#Preview {
    SpinningWordFlower()
        .frame(width: 200, height: 200)
}
