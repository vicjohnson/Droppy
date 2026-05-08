//
//  DroppyApp.swift
//  Droppy
//

import SwiftUI

@main
struct DroppyApp: App {
    @State private var store: NodeStore
    @State private var appState: AppState

    init() {
        let store = NodeStore()
        _store = State(initialValue: store)
        _appState = State(initialValue: AppState(store: store))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
        .defaultPosition(.topTrailing)
        .defaultSize(width: 400, height: 1400)

        Settings {
            SettingsPage()
                .environment(store)
        }
    }
}

