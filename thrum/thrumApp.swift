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
                .frame(minWidth: 820, minHeight: 540)
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 1040, height: 720)
    }
}
