//
//  HapticPads.swift
//  thrum
//
//  Created by David Umoru on 17/06/2026.
//

import SwiftUI

struct HapticPadsDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Haptic Pads")
                    .font(.largeTitle.bold())
                Text("Glide your cursor across each pad — no clicking. Scrubbing fires the pattern repeatedly so you can feel its texture without the trackpad's own click getting in the way.")
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                ForEach(Haptic.Pattern.allCases) { pattern in
                    HapticPad(pattern: pattern)
                }
            }

            Spacer()
        }
        .padding(40)
    }
}

private struct HapticPad: View {
    let pattern: Haptic.Pattern

    @State private var isHovering = false
    @State private var lastPoint: CGPoint = .zero

    private let stride: CGFloat = 22

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "hand.point.up.left")
                .font(.system(size: 32))
                .foregroundStyle(.tint)
            Text(pattern.title)
                .font(.title3.bold())
            Text(pattern.note)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.quaternary.opacity(0.5))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.tint.opacity(isHovering ? 0.15 : 0))
                }
        }
        .scaleEffect(isHovering ? 1.02 : 1)
        .animation(.easeOut(duration: 0.12), value: isHovering)
        .onContinuousHover { phase in
            switch phase {
            case .active(let point):
                if hypot(point.x - lastPoint.x, point.y - lastPoint.y) >= stride {
                    lastPoint = point
                    Haptic.play(pattern)
                }
                isHovering = true
            case .ended:
                isHovering = false
            }
        }
    }
}

#Preview {
    HapticPadsDemo()
        .frame(width: 700, height: 420)
}
