//
//  Settings.swift
//  Droppy
//
//  Created by Victor Johnson on 5/14/26.
//

import CoreGraphics
import Foundation
import Observation

@MainActor
@Observable
class SettingsStore {
    private let userDefaults = UserDefaults.standard
    
    var panelLocation: PanelLocation = .topRight {
        didSet {
            userDefaults.set(panelLocation.rawValue, forKey: Setting.panelLocation)
        }
    }

    var panelWidth: Double = 320 { didSet { saveFrame() } }
    var panelHeight: Double = 400 { didSet { saveFrame() } }
    var panelX: Double = 0 { didSet { saveFrame() } }
    var panelY: Double = 0 { didSet { saveFrame() } }

    var customPanelFrame: CGRect {
        CGRect(x: panelX, y: panelY, width: panelWidth, height: panelHeight)
    }

    init() {
        if let panelLocation = userDefaults.string(forKey: Setting.panelLocation) {
            self.panelLocation = PanelLocation(rawValue: panelLocation) ?? .topRight
        }
        if let str = userDefaults.string(forKey: Setting.customPanelFrame) {
            let rect = NSRectFromString(str)
            self.panelX = rect.origin.x
            self.panelY = rect.origin.y
            self.panelWidth = rect.size.width
            self.panelHeight = rect.size.height
        }
    }

    private func saveFrame() {
        userDefaults.set(NSStringFromRect(customPanelFrame), forKey: Setting.customPanelFrame)
    }

    private enum Setting {
        static let panelLocation = "panelLocation"
        static let customPanelFrame = "customPanelFrame"
    }
}
