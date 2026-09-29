# thrum

A playground for the macOS trackpad's haptics.

`thrum` is a small SwiftUI app that explores what the Mac trackpad's Taptic Engine
can do. The modern Force Touch trackpad doesn't physically click — every "click" you
feel is a haptic illusion. This app turns that capability into a set of interactive
experiments you can feel.

## Requirements

- macOS 15.5 or later
- A Force Touch trackpad (built into modern MacBooks, or a Magic Trackpad)
- Xcode 16+ to build

## Run it

### Option 1: Command line (build.sh)

Build and launch directly from the terminal without opening Xcode:

```bash
# Build and run
./build.sh run

# Or build only (outputs to build/Build/Products/Debug/thrum.app)
./build.sh
```

### Option 2: Xcode

1. Open `thrum.xcodeproj` in Xcode.
2. Select the `thrum` scheme and press **Run** (⌘R).

> **Keep a finger on the trackpad.** The Taptic Engine only produces a sensation you
> can actually feel while a finger is resting on the trackpad. Every experiment here is
> driven by sliding, dragging, or scrubbing — never by clicks, which would trigger the
> system's own click haptic and mask the app's feedback.

## Experiments

| Experiment        | What it demonstrates                                                                                                                                                |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Detent Slider** | A hand-built slider that fires a `levelChange` tick each time the knob crosses a notch — the same feel as a Figma slider. Supports drag, arrow keys, and VoiceOver. |
| **Snap to Grid**  | Drag a square around a grid; an `alignment` haptic fires each time it locks onto a new grid point.                                                                  |
| **Haptic Pads**   | Glide your cursor across three pads to compare the built-in patterns side by side, without a click haptic getting in the way.                                       |
| **Textures**      | Scrub across strips of varying "grit." Closer ridges fire ticks more densely, so coarse feels bumpy and fine feels like a buzz.                                     |

## How the haptics work

macOS exposes haptics through `NSHapticFeedbackManager`, with just three built-in
patterns and no custom waveforms (unlike Core Haptics on iOS):

- `generic` — a single soft tap
- `alignment` — a crisp snap, used when things line up
- `levelChange` — a clicky detent, used by sliders and steppers

`thrum` wraps these in a small `Haptic` helper (`Haptics.swift`) and builds every
experiment by combining them with continuous user interaction. Because the three
patterns are deliberately subtle, the experiments lean on **density** and **motion**
— the dimensions you can most easily feel on this hardware — rather than expecting the
patterns alone to feel dramatically different.

## Project structure

```text
thrum/
├── thrumApp.swift       App entry point and window sizing
├── ContentView.swift    Sidebar navigation + experiment routing
├── Haptics.swift        Wrapper around NSHapticFeedbackManager
├── Welcome.swift        Landing screen
├── DetentSlider.swift   Experiment: detent slider
├── SnapToGridDrag.swift Experiment: snap-to-grid drag
├── HapticPads.swift     Experiment: pattern comparison pads
└── Textures.swift       Experiment: scrubbable texture strips
```

Adding an experiment is a matter of creating its view and registering one case in the
`Experiment` enum (title, icon, and a line in the detail router).

## License

See [LICENSE](LICENSE).
