//
//  DetentSlider.swift
//  thrum
//
//  Created by David Umoru on 17/06/2026.
//

import SwiftUI

struct DetentSliderDemo: View {
    @State private var notchCount = 10
    @State private var notch = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Detent Slider")
                    .font(.largeTitle.bold())
                Text("Drag the knob. You'll feel a tick each time it crosses a notch — the same trick Figma uses.")
                    .foregroundStyle(.secondary)
            }

            DetentSlider(notch: $notch, notchCount: notchCount)
                .frame(height: 44)

            HStack {
                Text("Value: \(notch) / \(notchCount)")
                    .font(.title2.monospacedDigit())
                Spacer()
                Stepper("Notches: \(notchCount)", value: $notchCount, in: 2...40)
                    .fixedSize()
            }
            .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(40)
        .onChange(of: notchCount) { _, newCount in
            notch = min(notch, newCount)
        }
    }
}

private struct DetentSlider: View {
    @Binding var notch: Int
    let notchCount: Int

    private let knobSize: CGFloat = 28

    var body: some View {
        GeometryReader { geo in
            let travel = max(geo.size.width - knobSize, 1)
            let step = travel / CGFloat(notchCount)
            let knobX = step * CGFloat(notch)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.quaternary)
                    .frame(height: 6)

                Capsule()
                    .fill(.tint)
                    .frame(width: knobX + knobSize / 2, height: 6)

                HStack(spacing: 0) {
                    ForEach(0...notchCount, id: \.self) { i in
                        Circle()
                            .fill(.secondary.opacity(0.4))
                            .frame(width: 3, height: 3)
                        if i < notchCount { Spacer() }
                    }
                }
                .padding(.horizontal, knobSize / 2)

                Circle()
                    .fill(.white)
                    .shadow(radius: 2, y: 1)
                    .frame(width: knobSize, height: knobSize)
                    .offset(x: knobX)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let raw = (value.location.x - knobSize / 2) / step
                                setNotch(Int(raw.rounded()))
                            }
                    )
            }
            .focusable()
            .onKeyPress(.leftArrow) { setNotch(notch - 1); return .handled }
            .onKeyPress(.rightArrow) { setNotch(notch + 1); return .handled }
            .accessibilityElement()
            .accessibilityLabel("Detent slider")
            .accessibilityValue("\(notch) of \(notchCount)")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: setNotch(notch + 1)
                case .decrement: setNotch(notch - 1)
                @unknown default: break
                }
            }
        }
    }

    private func setNotch(_ value: Int) {
        let clamped = min(max(value, 0), notchCount)
        if clamped != notch {
            notch = clamped
            Haptic.play(.levelChange)
        }
    }
}

#Preview {
    DetentSliderDemo()
        .frame(width: 600, height: 400)
}
