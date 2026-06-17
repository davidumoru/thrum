//
//  Welcome.swift
//  thrum
//
//  Created by David Umoru on 17/06/2026.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("thrum")
                        .font(.system(size: 48, weight: .bold))
                    Text("A playground for the Mac trackpad's haptics.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Label {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Keep a finger on the trackpad")
                            .font(.headline)
                        Text("The Taptic Engine only produces a sensation you can feel while a finger is resting on the trackpad. Every experiment here is driven by sliding or dragging, never by clicks.")
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "hand.point.up.left.fill")
                        .font(.title)
                        .foregroundStyle(.tint)
                }
                .padding(20)
                .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 16) {
                    Text("Experiments")
                        .font(.headline)
                    ForEach(Experiment.demos) { experiment in
                        Label(experiment.title, systemImage: experiment.icon)
                            .font(.body)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(40)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    WelcomeView()
        .frame(width: 700, height: 600)
}
