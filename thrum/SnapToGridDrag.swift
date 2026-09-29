//
//  SnapToGridDrag.swift
//  thrum
//
//  Created by David Umoru on 17/06/2026.
//

import SwiftUI

struct SnapToGridDragDemo: View {
    @State private var spacing: CGFloat = 60
    @State private var col = 2
    @State private var row = 2

    var body: some View {
        ExperimentPage(experiment: .snapToGrid) {
            SnapGrid(spacing: spacing, col: $col, row: $row)
                .padding(28)
        } controls: {
            HStack {
                Readout(label: "Cell", value: "\(col), \(row)")
                Spacer()
                Stepper("Spacing: \(Int(spacing))", value: $spacing, in: 30...120, step: 10)
                    .fixedSize()
            }
        }
    }
}

private struct SnapGrid: View {
    let spacing: CGFloat
    @Binding var col: Int
    @Binding var row: Int

    @State private var ripples = RippleEmitter()
    @State private var fingerPoint: CGPoint?

    private let squareSize: CGFloat = 44
    private let color = Haptic.Pattern.alignment.color

    var body: some View {
        GeometryReader { geo in
            let cols = max(Int((geo.size.width - squareSize) / spacing), 1)
            let rows = max(Int((geo.size.height - squareSize) / spacing), 1)
            let inset = CGPoint(
                x: (geo.size.width - CGFloat(cols) * spacing) / 2,
                y: (geo.size.height - CGFloat(rows) * spacing) / 2
            )
            let point = { (c: Int, r: Int) in
                CGPoint(x: inset.x + CGFloat(c) * spacing, y: inset.y + CGFloat(r) * spacing)
            }
            let snapped = point(col, row)

            ZStack(alignment: .topLeading) {
                Canvas { context, _ in
                    for c in 0...cols {
                        for r in 0...rows {
                            let p = point(c, r)
                            let distance = hypot(p.x - snapped.x, p.y - snapped.y) / spacing
                            let glow = max(0, 1 - distance / 2.5)
                            let size = 3 + 2 * glow
                            context.fill(
                                Path(ellipseIn: CGRect(x: p.x - size / 2, y: p.y - size / 2, width: size, height: size)),
                                with: .color(glow > 0 ? color.opacity(0.25 + 0.6 * glow) : .white.opacity(0.22))
                            )
                        }
                    }
                }

                Canvas { context, size in
                    var guides = Path()
                    guides.move(to: CGPoint(x: 0, y: snapped.y))
                    guides.addLine(to: CGPoint(x: size.width, y: snapped.y))
                    guides.move(to: CGPoint(x: snapped.x, y: 0))
                    guides.addLine(to: CGPoint(x: snapped.x, y: size.height))
                    context.stroke(
                        guides,
                        with: .color(color.opacity(fingerPoint == nil ? 0.18 : 0.45)),
                        style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                    )
                }

                RippleLayer(emitter: ripples)

                if let fingerPoint {
                    Circle()
                        .strokeBorder(.white.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                        .frame(width: 22, height: 22)
                        .position(fingerPoint)
                        .allowsHitTesting(false)
                }

                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(
                        LinearGradient(colors: [color, color.opacity(0.75)], startPoint: .top, endPoint: .bottom)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .strokeBorder(.white.opacity(0.35), lineWidth: 1)
                    }
                    .shadow(color: color.opacity(fingerPoint == nil ? 0.3 : 0.6), radius: fingerPoint == nil ? 10 : 18)
                    .frame(width: squareSize, height: squareSize)
                    .scaleEffect(fingerPoint == nil ? 1 : 1.06)
                    .position(snapped)
                    .animation(.snappy(duration: 0.15), value: fingerPoint == nil)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .named("grid"))
                            .onChanged { value in
                                fingerPoint = value.location
                                let newCol = clamp(Int(((value.location.x - inset.x) / spacing).rounded()), to: cols)
                                let newRow = clamp(Int(((value.location.y - inset.y) / spacing).rounded()), to: rows)
                                if newCol != col || newRow != row {
                                    col = newCol
                                    row = newRow
                                    Haptic.play(.alignment, at: .drawCompleted)
                                    ripples.emit(at: point(newCol, newRow), color: color, radius: 40)
                                }
                            }
                            .onEnded { _ in fingerPoint = nil }
                    )
            }
            .coordinateSpace(.named("grid"))
            .onChange(of: spacing) { _, _ in
                col = clamp(col, to: cols)
                row = clamp(row, to: rows)
            }
        }
    }

    private func clamp(_ value: Int, to upper: Int) -> Int {
        min(max(value, 0), upper)
    }
}

#Preview {
    SnapToGridDragDemo()
        .frame(width: 760, height: 600)
}
