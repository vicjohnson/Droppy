//
//  AppState.swift
//  Droppy
//

import AppKit
import KeyboardShortcuts

@MainActor
@Observable
final class AppState {
    private var store: NodeStore
    private var panelController: PanelController

    init(store: NodeStore) {
        self.store = store
        self.panelController = PanelController(store: store)

        KeyboardShortcuts.onKeyUp(for: .openPanel) { [self] in
            panelController.show()
        }
    }
}

func simulatePaste() {
    let source = CGEventSource(stateID: .hidSystemState)
    let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
    let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
    keyDown?.flags = .maskCommand
    keyUp?.flags = .maskCommand
    keyDown?.post(tap: .cgAnnotatedSessionEventTap)
    keyUp?.post(tap: .cgAnnotatedSessionEventTap)
}
