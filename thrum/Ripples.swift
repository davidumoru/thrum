//
//  Ripples.swift
//  thrum
//
//  Created by David Umoru on 29/09/2026.
//

import SwiftUI

@MainActor @Observable
final class RippleEmitter {
    struct Ripple: Identifiable {
        let id = UUID()
        let point: CGPoint
        let color: Color
        let radius: CGFloat
        let birth: Date
    }

    static let lifetime: TimeInterval = 0.45
    private static let maxLive = 24

    private(set) var ripples: [Ripple] = []

    func emit(at point: CGPoint, color: Color, radius: CGFloat = 36) {
        prune()
        ripples.append(Ripple(point: point, color: color, radius: radius, birth: .now))
        if ripples.count > Self.maxLive {
            ripples.removeFirst(ripples.count - Self.maxLive)
        }
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(Self.lifetime + 0.05))
            self?.prune()
        }
    }

    private func prune() {
        let now = Date.now
        ripples.removeAll { now.timeIntervalSince($0.birth) > Self.lifetime }
    }
}

struct RippleLayer: View {
    let emitter: RippleEmitter

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(paused: emitter.ripples.isEmpty)) { timeline in
            Canvas { context, _ in
                for ripple in emitter.ripples {
                    let t = timeline.date.timeIntervalSince(ripple.birth) / RippleEmitter.lifetime
                    guard t >= 0, t < 1 else { continue }

                    let growth = reduceMotion ? 1 : 0.3 + 0.7 * (1 - pow(1 - t, 3))
                    let radius = ripple.radius * 0.7 * growth
                    let rect = CGRect(
                        x: ripple.point.x - radius,
                        y: ripple.point.y - radius,
                        width: radius * 2,
                        height: radius * 2
                    )
                    context.stroke(
                        Path(ellipseIn: rect),
                        with: .color(ripple.color.opacity(0.35 * (1 - t))),
                        lineWidth: 1
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}
