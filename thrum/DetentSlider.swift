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
        ExperimentPage(experiment: .detentSlider) {
            VStack(spacing: 36) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(notch)")
                        .font(.system(size: 104, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText(value: Double(notch)))
                        .animation(.snappy(duration: 0.18), value: notch)
                    Text("/ \(notchCount)")
                        .font(.system(size: 28, weight: .medium, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.tertiary)
                }
                .foregroundStyle(.white)

                DetentSlider(notch: $notch, notchCount: notchCount)
                    .frame(height: 64)
                    .frame(maxWidth: 620)
            }
            .padding(40)
        } controls: {
            HStack {
                Readout(label: "Value", value: "\(notch) / \(notchCount)")
                Spacer()
                Stepper("Notches: \(notchCount)", value: $notchCount, in: 2...40)
                    .fixedSize()
            }
        }
        .onChange(of: notchCount) { _, newCount in
            notch = min(notch, newCount)
        }
    }
}

private struct DetentSlider: View {
    @Binding var notch: Int
    let notchCount: Int

    @State private var ripples = RippleEmitter()
    @State private var isDragging = false
    @FocusState private var isFocused: Bool

    private let knobSize: CGFloat = 30
    private let color = Haptic.Pattern.levelChange.color

    var body: some View {
        GeometryReader { geo in
            let travel = max(geo.size.width - knobSize, 1)
            let step = travel / CGFloat(notchCount)
            let knobX = step * CGFloat(notch)
            let midY = geo.size.height / 2
            let knobCenter = { (n: Int) in CGPoint(x: knobSize / 2 + step * CGFloat(n), y: midY) }

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.1))
                    .frame(height: 8)

                Capsule()
                    .fill(
                        LinearGradient(colors: [color.opacity(0.5), color], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: knobX + knobSize / 2, height: 8)
                    .shadow(color: color.opacity(0.5), radius: 8)

                Canvas { context, size in
                    for i in 0...notchCount {
                        let x = knobSize / 2 + step * CGFloat(i)
                        let major = i % 5 == 0 || i == notchCount
                        let top = midY + 12
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: top))
                        path.addLine(to: CGPoint(x: x, y: top + (major ? 12 : 7)))
                        context.stroke(
                            path,
                            with: .color(i <= notch ? color : .white.opacity(0.25)),
                            style: StrokeStyle(lineWidth: major ? 2 : 1.5, lineCap: .round)
                        )
                    }
                }
                .allowsHitTesting(false)

                RippleLayer(emitter: ripples)

                Circle()
                    .fill(.white)
                    .overlay { Circle().fill(color).padding(10) }
                    .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
                    .shadow(color: color.opacity(isDragging ? 0.7 : 0), radius: 12)
                    .frame(width: knobSize, height: knobSize)
                    .background {
                        Circle()
                            .stroke(color.opacity(0.45), lineWidth: 3)
                            .padding(-5)
                            .opacity(isFocused ? 1 : 0)
                    }
                    .scaleEffect(isDragging ? 1.12 : 1)
                    .offset(x: knobX)
                    .animation(.snappy(duration: 0.18), value: isDragging)
                    .animation(.easeOut(duration: 0.15), value: isFocused)
                    .allowsHitTesting(false)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        let raw = (value.location.x - knobSize / 2) / step
                        setNotch(Int(raw.rounded()), rippleAt: knobCenter)
                    }
                    .onEnded { _ in isDragging = false }
            )
            .focusable()
            .focused($isFocused)
            .focusEffectDisabled()
            .onKeyPress(.leftArrow) { setNotch(notch - 1, rippleAt: knobCenter); return .handled }
            .onKeyPress(.rightArrow) { setNotch(notch + 1, rippleAt: knobCenter); return .handled }
            .accessibilityElement()
            .accessibilityLabel("Detent slider")
            .accessibilityValue("\(notch) of \(notchCount)")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: setNotch(notch + 1, rippleAt: knobCenter)
                case .decrement: setNotch(notch - 1, rippleAt: knobCenter)
                @unknown default: break
                }
            }
        }
    }

    private func setNotch(_ value: Int, rippleAt position: (Int) -> CGPoint) {
        let clamped = min(max(value, 0), notchCount)
        if clamped != notch {
            notch = clamped
            Haptic.play(.levelChange, at: .drawCompleted)
            ripples.emit(at: position(clamped), color: color, radius: 30)
        }
    }
}

#Preview {
    DetentSliderDemo()
        .frame(width: 760, height: 560)
}
