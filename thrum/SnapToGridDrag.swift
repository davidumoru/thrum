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
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Snap to Grid")
                    .font(.largeTitle.bold())
                Text("Drag the square. You'll feel a snap each time it locks onto a new grid point — macOS's alignment haptic.")
                    .foregroundStyle(.secondary)
            }

            SnapGrid(spacing: spacing, col: $col, row: $row)
                .frame(maxWidth: .infinity, minHeight: 300)

            HStack {
                Text("Cell: \(col), \(row)")
                    .font(.title2.monospacedDigit())
                Spacer()
                Stepper("Spacing: \(Int(spacing))", value: $spacing, in: 30...120, step: 10)
                    .fixedSize()
            }
            .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(40)
    }
}

private struct SnapGrid: View {
    let spacing: CGFloat
    @Binding var col: Int
    @Binding var row: Int

    private let squareSize: CGFloat = 44

    var body: some View {
        GeometryReader { geo in
            let origin = squareSize / 2
            let cols = max(Int((geo.size.width - squareSize) / spacing), 1)
            let rows = max(Int((geo.size.height - squareSize) / spacing), 1)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.quaternary.opacity(0.5))

                ForEach(0...cols, id: \.self) { c in
                    ForEach(0...rows, id: \.self) { r in
                        Circle()
                            .fill(.secondary.opacity(0.3))
                            .frame(width: 4, height: 4)
                            .position(
                                x: origin + CGFloat(c) * spacing,
                                y: origin + CGFloat(r) * spacing
                            )
                    }
                }

                RoundedRectangle(cornerRadius: 8)
                    .fill(.tint)
                    .frame(width: squareSize, height: squareSize)
                    .position(
                        x: origin + CGFloat(col) * spacing,
                        y: origin + CGFloat(row) * spacing
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .named("grid"))
                            .onChanged { value in
                                let newCol = clamp(Int(((value.location.x - origin) / spacing).rounded()), to: cols)
                                let newRow = clamp(Int(((value.location.y - origin) / spacing).rounded()), to: rows)
                                if newCol != col || newRow != row {
                                    col = newCol
                                    row = newRow
                                    Haptic.play(.alignment)
                                }
                            }
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
        .frame(width: 600, height: 500)
}
