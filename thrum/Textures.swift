//
//  Textures.swift
//  thrum
//
//  Created by David Umoru on 17/06/2026.
//

import SwiftUI

private struct Texture: Identifiable {
    var id: String { name }
    let name: String
    let grit: CGFloat
    let pattern: Haptic.Pattern
}

struct TexturesDemo: View {
    private let textures: [Texture] = [
        Texture(name: "Coarse", grit: 56, pattern: .levelChange),
        Texture(name: "Medium", grit: 28, pattern: .levelChange),
        Texture(name: "Fine",   grit: 12, pattern: .levelChange),
        Texture(name: "Ridged", grit: 44, pattern: .alignment),
    ]

    var body: some View {
        ExperimentPage(experiment: .textures) {
            VStack(spacing: 12) {
                ForEach(textures) { texture in
                    TextureStrip(texture: texture)
                }
            }
            .padding(20)
        }
    }
}

private struct TextureStrip: View {
    let texture: Texture

    @State private var lastX: CGFloat = 0
    @State private var hoverX: CGFloat?
    @State private var ripples = RippleEmitter()

    var body: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 3) {
                Text(texture.name)
                    .font(.headline)
                HStack(spacing: 5) {
                    Circle()
                        .fill(texture.pattern.color)
                        .frame(width: 6, height: 6)
                    Text("every \(Int(texture.grit)) pt")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 92, alignment: .leading)

            GeometryReader { geo in
                ZStack {
                    Canvas { context, size in
                        var x = texture.grit
                        while x < size.width {
                            let nearness = hoverX.map { max(0, 1 - abs($0 - x) / 90) } ?? 0
                            var ridge = Path()
                            ridge.move(to: CGPoint(x: x, y: 12))
                            ridge.addLine(to: CGPoint(x: x, y: size.height - 12))
                            context.stroke(
                                ridge,
                                with: .color(nearness > 0
                                    ? texture.pattern.color.opacity(0.3 + 0.7 * nearness)
                                    : .white.opacity(0.16)),
                                style: StrokeStyle(lineWidth: 1 + 1.5 * nearness, lineCap: .round)
                            )
                            x += texture.grit
                        }
                    }

                    RippleLayer(emitter: ripples)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.stageRaised)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(hoverX == nil ? Theme.hairline : texture.pattern.color.opacity(0.45))
                }
                .contentShape(Rectangle())
                .onContinuousHover { phase in
                    switch phase {
                    case .active(let point):
                        hoverX = point.x
                        if abs(point.x - lastX) >= texture.grit {
                            lastX = point.x
                            Haptic.play(texture.pattern)
                            ripples.emit(
                                at: CGPoint(x: point.x, y: geo.size.height / 2),
                                color: texture.pattern.color,
                                radius: 22
                            )
                        }
                    case .ended:
                        hoverX = nil
                    }
                }
            }
        }
        .frame(maxHeight: 84)
        .animation(.easeOut(duration: 0.15), value: hoverX == nil)
    }
}

#Preview {
    TexturesDemo()
        .frame(width: 820, height: 600)
}
