//
//  SettingsPage.swift
//  Droppy
//

import SwiftUI
import KeyboardShortcuts

struct SettingsPage: View {
    var body: some View {
        Form {
            KeyboardShortcuts.Recorder("Open Panel:", name: .openPanel)
        }
        .padding()
        .frame(minWidth: 300)
    }
}

#Preview {
    SettingsPage()
}
