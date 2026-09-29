//
//  Theme.swift
//  thrum
//
//  Created by David Umoru on 29/09/2026.
//

import SwiftUI

enum Theme {
    static let pagePadding: CGFloat = 32
    static let stageCorner: CGFloat = 22
    static let cardCorner: CGFloat = 16

    static let stage = Color(red: 0.070, green: 0.071, blue: 0.078)
    static let stageRaised = Color.white.opacity(0.045)
    static let hairline = Color.white.opacity(0.08)
}

extension Haptic.Pattern {
    var color: Color {
        switch self {
        case .generic:     return Color(red: 0.38, green: 0.78, blue: 1.00)
        case .alignment:   return Color(red: 1.00, green: 0.64, blue: 0.28)
        case .levelChange: return Color(red: 0.74, green: 0.56, blue: 1.00)
        }
    }
}

struct StageSurface: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    Theme.stage
                    RadialGradient(
                        colors: [.white.opacity(0.06), .clear],
                        center: .top,
                        startRadius: 0,
                        endRadius: 520
                    )
                    DotField(spacing: 18, opacity: 0.05)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.stageCorner, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.stageCorner, style: .continuous)
                    .strokeBorder(Theme.hairline)
            }
            .shadow(color: .black.opacity(0.18), radius: 24, y: 12)
            .environment(\.colorScheme, .dark)
    }
}

extension View {
    func stageSurface() -> some View { modifier(StageSurface()) }
}

struct DotField: View {
    let spacing: CGFloat
    let opacity: Double

    var body: some View {
        Canvas { context, size in
            var y = spacing / 2
            while y < size.height {
                var x = spacing / 2
                while x < size.width {
                    context.fill(
                        Path(ellipseIn: CGRect(x: x - 0.75, y: y - 0.75, width: 1.5, height: 1.5)),
                        with: .color(.white.opacity(opacity))
                    )
                    x += spacing
                }
                y += spacing
            }
        }
        .allowsHitTesting(false)
    }
}

struct ExperimentPage<Stage: View, Controls: View>: View {
    let experiment: Experiment
    @ViewBuilder var stage: Stage
    @ViewBuilder var controls: Controls

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center, spacing: 14) {
                IconBadge(experiment: experiment, size: 40)
                VStack(alignment: .leading, spacing: 4) {
                    Text(experiment.title)
                        .font(.system(size: 22, weight: .semibold))
                    Text(experiment.instructions)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .frame(maxWidth: 560, alignment: .leading)
                }
            }

            stage
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .stageSurface()

            controls
        }
        .padding(.horizontal, Theme.pagePadding)
        .padding(.top, 8)
        .padding(.bottom, 20)
    }
}

extension ExperimentPage where Controls == EmptyView {
    init(experiment: Experiment, @ViewBuilder stage: () -> Stage) {
        self.experiment = experiment
        self.stage = stage()
        self.controls = EmptyView()
    }
}

struct Readout: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
                .textCase(.uppercase)
            Text(value)
                .font(.body.monospacedDigit().weight(.medium))
                .contentTransition(.numericText())
        }
    }
}

struct IconBadge: View {
    let experiment: Experiment
    var size: CGFloat = 36

    var body: some View {
        Image(systemName: experiment.icon)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(experiment.tint)
            .frame(width: size, height: size)
            .background {
                RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                    .fill(experiment.tint.opacity(0.14))
            }
            .overlay {
                RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                    .strokeBorder(experiment.tint.opacity(0.25))
            }
    }
}
