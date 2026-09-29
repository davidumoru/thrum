//
//  ContentView.swift
//  thrum
//
//  Created by David Umoru on 17/06/2026.
//

import SwiftUI

enum Experiment: String, CaseIterable, Identifiable {
    case welcome
    case detentSlider
    case snapToGrid
    case hapticPads
    case textures

    var id: String { rawValue }

    /// Every case except the welcome screen.
    static var demos: [Experiment] { allCases.filter { $0 != .welcome } }

    var title: String {
        switch self {
        case .welcome:      return "Welcome"
        case .detentSlider: return "Detent Slider"
        case .snapToGrid:   return "Snap to Grid"
        case .hapticPads:   return "Haptic Pads"
        case .textures:     return "Textures"
        }
    }

    var icon: String {
        switch self {
        case .welcome:      return "hand.wave"
        case .detentSlider: return "slider.horizontal.3"
        case .snapToGrid:   return "square.grid.3x3"
        case .hapticPads:   return "dot.radiowaves.left.and.right"
        case .textures:     return "waveform.path"
        }
    }

    var summary: String {
        switch self {
        case .welcome:      return ""
        case .detentSlider: return "A slider that ticks at every notch."
        case .snapToGrid:   return "Drag a square and feel it lock onto the grid."
        case .hapticPads:   return "The three built-in patterns, side by side."
        case .textures:     return "Scrub strips of varying grit, from bumpy to buzz."
        }
    }

    var instructions: String {
        switch self {
        case .welcome:
            return ""
        case .detentSlider:
            return "Drag the knob. You'll feel a tick each time it crosses a notch."
        case .snapToGrid:
            return "Drag the square. You'll feel a snap each time it locks onto a new grid point — macOS's alignment haptic."
        case .hapticPads:
            return "Glide across each pad without clicking. Scrubbing fires the pattern repeatedly so you can feel its texture."
        case .textures:
            return "Glide your finger across each strip without clicking. Closer ridges fire more densely: coarse feels bumpy, fine feels like a buzz."
        }
    }

    var tint: Color {
        switch self {
        case .welcome:      return .primary
        case .detentSlider: return Haptic.Pattern.levelChange.color
        case .snapToGrid:   return Haptic.Pattern.alignment.color
        case .hapticPads:   return Haptic.Pattern.generic.color
        case .textures:     return Color(red: 0.36, green: 0.86, blue: 0.62)
        }
    }
}

struct ContentView: View {
    @State private var selection: Experiment?

    init(selection: Experiment? = .welcome) {
        _selection = State(initialValue: selection)
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Label(Experiment.welcome.title, systemImage: Experiment.welcome.icon)
                    .tag(Experiment.welcome)

                Section("Experiments") {
                    ForEach(Experiment.demos) { experiment in
                        Label {
                            Text(experiment.title)
                        } icon: {
                            Image(systemName: experiment.icon)
                                .foregroundStyle(experiment.tint)
                        }
                        .tag(experiment)
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 190, ideal: 210)
        } detail: {
            Group {
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("")
        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
    }

    @ViewBuilder
    private func destination(for experiment: Experiment) -> some View {
        switch experiment {
        case .welcome:      WelcomeView(selection: $selection)
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
