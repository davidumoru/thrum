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
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Textures")
                    .font(.largeTitle.bold())
                Text("Glide your finger across each strip — no clicking. Closer ridges fire ticks more densely, so coarse feels bumpy and fine feels like a buzz.")
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 14) {
                ForEach(textures) { texture in
                    TextureStrip(texture: texture)
                }
            }

            Spacer()
        }
        .padding(40)
    }
}

private struct TextureStrip: View {
    let texture: Texture

    @State private var lastX: CGFloat = 0
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 16) {
            Text(texture.name)
                .font(.headline)
                .frame(width: 80, alignment: .leading)

            GeometryReader { geo in
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.quaternary.opacity(0.5))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.tint.opacity(isHovering ? 0.15 : 0))
                        }

                    Path { path in
                        var x = texture.grit
                        while x < geo.size.width {
                            path.move(to: CGPoint(x: x, y: 10))
                            path.addLine(to: CGPoint(x: x, y: geo.size.height - 10))
                            x += texture.grit
                        }
                    }
                    .stroke(.secondary.opacity(0.4), lineWidth: 1)
                }
                .contentShape(Rectangle())
                .onContinuousHover { phase in
                    switch phase {
                    case .active(let point):
                        if abs(point.x - lastX) >= texture.grit {
                            lastX = point.x
                            Haptic.play(texture.pattern)
                        }
                        isHovering = true
                    case .ended:
                        isHovering = false
                    }
                }
            }
            .frame(height: 56)
        }
        .animation(.easeOut(duration: 0.12), value: isHovering)
    }
}

#Preview {
    TexturesDemo()
        .frame(width: 700, height: 480)
}
