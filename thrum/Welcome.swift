//
//  Welcome.swift
//  thrum
//
//  Created by David Umoru on 17/06/2026.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var selection: Experiment?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 2)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 36) {
                hero

                VStack(alignment: .leading, spacing: 14) {
                    SectionTitle("Experiments")
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(Experiment.demos) { experiment in
                            ExperimentCard(experiment: experiment) {
                                selection = experiment
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 14) {
                    SectionTitle("The three patterns")
                    Text("macOS offers exactly three haptics and no custom waveforms. Each has its own color here, so every ring you see tells you which one you just felt.")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 560, alignment: .leading)
                    HStack(spacing: 14) {
                        ForEach(Haptic.Pattern.allCases) { pattern in
                            PatternChip(pattern: pattern)
                        }
                    }
                }
            }
            .padding(Theme.pagePadding)
            .frame(maxWidth: 880, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
    }

    private var hero: some View {
        HStack(spacing: 32) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("thrum")
                        .font(.system(size: 56, weight: .bold))
                        .tracking(-1.5)
                        .foregroundStyle(.white)
                    Text("A playground for the Mac trackpad's haptics.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Label {
                    Text("**Keep a finger on the trackpad.** You only feel the Taptic Engine while a finger rests on it, so every experiment is driven by gliding or dragging, never clicking.")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                } icon: {
                    Image(systemName: "hand.point.up.left.fill")
                        .foregroundStyle(.white)
                }
                .font(.callout)
                .frame(maxWidth: 380, alignment: .leading)
            }

            Spacer(minLength: 0)

            PulseRings()
                .frame(width: 200, height: 200)
        }
        .padding(36)
        .frame(maxWidth: .infinity)
        .stageSurface()
    }
}

private struct PulseRings: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let maxRadius = min(size.width, size.height) / 2
                let phase = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
                    .truncatingRemainder(dividingBy: 2.4) / 2.4

                for i in 0..<4 {
                    let t = (Double(i) / 4 + phase).truncatingRemainder(dividingBy: 1)
                    let radius = maxRadius * (0.22 + 0.78 * t)
                    let rect = CGRect(
                        x: center.x - radius, y: center.y - radius,
                        width: radius * 2, height: radius * 2
                    )
                    context.stroke(
                        Path(ellipseIn: rect),
                        with: .color(.white.opacity(0.85 * (1 - t))),
                        lineWidth: 5 * (1 - t) + 1
                    )
                }

                let dot = maxRadius * 0.12
                context.fill(
                    Path(ellipseIn: CGRect(x: center.x - dot, y: center.y - dot, width: dot * 2, height: dot * 2)),
                    with: .color(.white)
                )
            }
        }
        .accessibilityHidden(true)
    }
}

private struct SectionTitle: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(.title3.weight(.semibold))
    }
}

private struct ExperimentCard: View {
    let experiment: Experiment
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 14) {
                IconBadge(experiment: experiment, size: 40)
                VStack(alignment: .leading, spacing: 4) {
                    Text(experiment.title)
                        .font(.headline)
                    Text(experiment.summary)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Image(systemName: "arrow.right")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(isHovering ? experiment.tint : Color.secondary.opacity(0.5))
                    .offset(x: isHovering ? 2 : 0)
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background {
                RoundedRectangle(cornerRadius: Theme.cardCorner, style: .continuous)
                    .fill(.quaternary.opacity(isHovering ? 0.8 : 0.45))
            }
            .overlay {
                RoundedRectangle(cornerRadius: Theme.cardCorner, style: .continuous)
                    .strokeBorder(isHovering ? experiment.tint.opacity(0.45) : .clear)
            }
            .contentShape(RoundedRectangle(cornerRadius: Theme.cardCorner, style: .continuous))
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .animation(.easeOut(duration: 0.15), value: isHovering)
    }
}

private struct PatternChip: View {
    let pattern: Haptic.Pattern

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Circle()
                    .fill(pattern.color)
                    .frame(width: 8, height: 8)
                Text(pattern.title)
                    .font(.headline)
            }
            Text(pattern.note)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: Theme.cardCorner, style: .continuous)
                .fill(pattern.color.opacity(0.08))
        }
        .overlay {
            RoundedRectangle(cornerRadius: Theme.cardCorner, style: .continuous)
                .strokeBorder(pattern.color.opacity(0.22))
        }
    }
}

#Preview {
    WelcomeView(selection: .constant(.welcome))
        .frame(width: 820, height: 720)
}
