//
//  Haptics.swift
//  thrum
//
//  Created by David Umoru on 17/06/2026.
//

import AppKit

enum Haptic {
    enum Pattern: String, CaseIterable, Identifiable {
        case generic
        case alignment
        case levelChange

        var id: String { rawValue }

        var title: String {
            switch self {
            case .generic:     return "Generic"
            case .alignment:   return "Alignment"
            case .levelChange: return "Level Change"
            }
        }

        var note: String {
            switch self {
            case .generic:     return "A single soft tap."
            case .alignment:   return "A crisp snap, like aligning to a guide."
            case .levelChange: return "A clicky detent, like a slider notch."
            }
        }

        var systemPattern: NSHapticFeedbackManager.FeedbackPattern {
            switch self {
            case .generic:     return .generic
            case .alignment:   return .alignment
            case .levelChange: return .levelChange
            }
        }
    }

    static func play(_ pattern: Pattern) {
        NSHapticFeedbackManager.defaultPerformer.perform(
            pattern.systemPattern,
            performanceTime: .now
        )
    }
}
