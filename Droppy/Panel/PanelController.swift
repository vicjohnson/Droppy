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
    private var statusItem: NSStatusItem?

    init(store: NodeStore) {
        self.store = store
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem?.button?.image = NSImage(systemSymbolName: "list.clipboard", accessibilityDescription: "Droppy")
        statusItem?.button?.action = #selector(statusItemClicked)
        statusItem?.button?.target = self
    }

    @objc private func statusItemClicked() {
        show()
    }

    func show() {
        let frontmost = NSWorkspace.shared.frontmostApplication
        if frontmost?.bundleIdentifier != Bundle.main.bundleIdentifier {
            previousApp = frontmost
        }
        if panel == nil {
            panel = makePanel()
        }
        resetContent()
        positionPanel()
        panel?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        // Close on click outside
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
        let savedItems = NSPasteboard.general.pasteboardItems?.map { item -> NSPasteboardItem in
            let copy = NSPasteboardItem()
            for type in item.types {
                if let data = item.data(forType: type) {
                    copy.setData(data, forType: type)
                }
            }
            return copy
        }

        panel?.orderOut(nil)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(value, forType: .string)
        previousApp?.activate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.simulatePaste()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NSPasteboard.general.clearContents()
                if let items = savedItems {
                    NSPasteboard.general.writeObjects(items)
                }
            }
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
        panel.isMovableByWindowBackground = true
        panel.title = ""
        panel.titlebarAppearsTransparent = true
        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        panel.contentView = makeContentView()
        return panel
    }
    
    private func simulatePaste() {
        let source = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        keyDown?.flags = .maskCommand
        keyUp?.flags = .maskCommand
        keyDown?.post(tap: .cgAnnotatedSessionEventTap)
        keyUp?.post(tap: .cgAnnotatedSessionEventTap)
    }
}
