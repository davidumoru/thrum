//
//  thrumApp.swift
//  thrum
//
//  Created by David Umoru on 17/06/2026.
//

import SwiftUI

@main
struct thrumApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 720, minHeight: 520)
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 900, height: 640)
    }
}
