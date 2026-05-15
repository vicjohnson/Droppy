//
//  DroppyApp.swift
//  Droppy
//

import SwiftUI
import KeyboardShortcuts

@main
struct DroppyApp: App {
    @State private var settings: SettingsStore
    @State private var store: NodeStore
    @State private var panelController: PanelController

    init() {
        let store = NodeStore()
        let settings = SettingsStore()
        let controller = PanelController(store: store, settings: settings)
        
        _settings = State(initialValue: settings)
        _store = State(initialValue: store)
        _panelController = State(initialValue: controller)
        
        KeyboardShortcuts.onKeyUp(for: .openPanel) { [controller] in
            controller.show()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
        .defaultPosition(.topTrailing)
        .defaultSize(width: 400, height: 1400)

        Settings {
            SettingsPage(panelController: panelController)
                .environment(store)
                .environment(settings)
        }
        .defaultSize(width: 400, height: 500)
        .windowResizability(.contentSize)
    }
}
