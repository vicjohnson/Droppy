//
//  PanelController.swift
//  Droppy
//

import AppKit
import SwiftUI

final class PanelController {
    private var panel: NSPanel?
    private let store: NodeStore
    private var previousApp: NSRunningApplication?

    init(store: NodeStore) {
        self.store = store
    }

    func show() {
        previousApp = NSWorkspace.shared.frontmostApplication
        if panel == nil {
            panel = makePanel()
        }
        resetContent()
        positionPanel()
        panel?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        NotificationCenter.default.addObserver(
            forName: NSWindow.didResignKeyNotification,
            object: panel,
            queue: .main
        ) { [weak self] _ in
            self?.hide()
        }
    }

    func hide() {
        NotificationCenter.default.removeObserver(self, name: NSWindow.didResignKeyNotification, object: panel)
        panel?.orderOut(nil)
        previousApp?.activate()
    }

    func pasteAndHide(value: String) {
        panel?.orderOut(nil)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(value, forType: .string)
        previousApp?.activate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            simulatePaste()
        }
    }

    private func positionPanel() {
        guard let panel, let screen = NSScreen.main else { return }
        let margin: CGFloat = 16
        let x = screen.visibleFrame.maxX - panel.frame.width - margin
        let y = screen.visibleFrame.maxY - panel.frame.height - margin
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }

    private func resetContent() {
        panel?.contentView = makeContentView()
    }

    private func makeContentView() -> NSView {
        NSHostingView(rootView:
            PanelView(
                store: store,
                dismiss: { [weak self] in self?.hide() },
                paste: { [weak self] value in self?.pasteAndHide(value: value) }
            )
        )
    }

    private func makePanel() -> NSPanel {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 400),
            styleMask: [.titled, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.titlebarAppearsTransparent = true
        panel.title = ""
        panel.isMovableByWindowBackground = true
        panel.contentView = makeContentView()
        return panel
    }
}
