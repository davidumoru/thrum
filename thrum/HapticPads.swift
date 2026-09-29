//
//  HapticPads.swift
//  thrum
//
//  Created by David Umoru on 17/06/2026.
//

import SwiftUI

struct HapticPadsDemo: View {
    var body: some View {
        ExperimentPage(experiment: .hapticPads) {
            HStack(spacing: 14) {
                ForEach(Haptic.Pattern.allCases) { pattern in
                    HapticPad(pattern: pattern)
                }
            }
            .padding(20)
        }
    }
}

private struct HapticPad: View {
    let pattern: Haptic.Pattern

    @State private var hoverPoint: CGPoint?
    @State private var lastPoint: CGPoint = .zero
    @State private var ripples = RippleEmitter()

    private let stride: CGFloat = 22

    var body: some View {
        ZStack {
            if let hoverPoint {
                GeometryReader { geo in
                    RadialGradient(
                        colors: [pattern.color.opacity(0.28), .clear],
                        center: UnitPoint(x: hoverPoint.x / geo.size.width, y: hoverPoint.y / geo.size.height),
                        startRadius: 0,
                        endRadius: 180
                    )
                }
                .transition(.opacity)
            }

            PadGlyph(color: pattern.color, isActive: hoverPoint != nil)
                .frame(width: 96, height: 96)

            RippleLayer(emitter: ripples)

            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(pattern.color)
                        .frame(width: 8, height: 8)
                    Text(pattern.title)
                        .font(.headline)
                    Spacer()
                }

                Spacer()

                Text(pattern.note)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .allowsHitTesting(false)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.stageRaised)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCorner, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.cardCorner, style: .continuous)
                .strokeBorder(hoverPoint == nil ? Theme.hairline : pattern.color.opacity(0.5))
        }
        .contentShape(RoundedRectangle(cornerRadius: Theme.cardCorner, style: .continuous))
        .animation(.easeOut(duration: 0.15), value: hoverPoint == nil)
        .onContinuousHover { phase in
            switch phase {
            case .active(let point):
                hoverPoint = point
                if hypot(point.x - lastPoint.x, point.y - lastPoint.y) >= stride {
                    lastPoint = point
                    Haptic.play(pattern)
                    ripples.emit(at: point, color: pattern.color, radius: 34)
                }
            case .ended:
                hoverPoint = nil
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct PadGlyph: View {
    let color: Color
    let isActive: Bool

    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                Circle()
                    .stroke(color.opacity((isActive ? 0.55 : 0.22) - Double(i) * 0.06), lineWidth: 1.5)
                    .padding(CGFloat(i) * 16)
            }
            Circle()
                .fill(color.opacity(isActive ? 0.9 : 0.4))
                .frame(width: 12, height: 12)
        }
        .scaleEffect(isActive ? 1.06 : 1)
        .allowsHitTesting(false)
    }
}

#Preview {
    HapticPadsDemo()
        .frame(width: 820, height: 520)
}
