//
//  ContentView.swift
//  thrum
//
//  Created by David Umoru on 17/06/2026.
//

import SwiftUI

enum Experiment: String, CaseIterable, Identifiable {
    case detentSlider
    case snapToGrid
    case hapticPads
    case textures

    var id: String { rawValue }

    var title: String {
        switch self {
        case .detentSlider: return "Detent Slider"
        case .snapToGrid:   return "Snap to Grid"
        case .hapticPads:   return "Haptic Pads"
        case .textures:     return "Textures"
        }
    }

    var icon: String {
        switch self {
        case .detentSlider: return "slider.horizontal.3"
        case .snapToGrid:   return "square.grid.3x3"
        case .hapticPads:   return "dot.radiowaves.left.and.right"
        case .textures:     return "waveform.path"
        }
    }
}

struct ContentView: View {
    @State private var selection: Experiment? = .detentSlider

    var body: some View {
        NavigationSplitView {
            List(Experiment.allCases, selection: $selection) { experiment in
                Label(experiment.title, systemImage: experiment.icon)
                    .tag(experiment)
            }
            .navigationTitle("thrum")
        } detail: {
            if let selection {
                destination(for: selection)
            } else {
                ContentUnavailableView(
                    "Pick an experiment",
                    systemImage: "hand.tap",
                    description: Text("Choose one from the sidebar to feel it.")
                )
            }
        }
    }

    @ViewBuilder
    private func destination(for experiment: Experiment) -> some View {
        switch experiment {
        case .detentSlider: DetentSliderDemo()
        case .snapToGrid:   SnapToGridDragDemo()
        case .hapticPads:   HapticPadsDemo()
        case .textures:     TexturesDemo()
        }
    }
}

#Preview {
    ContentView()
}
