//
//  SettingsPage.swift
//  Droppy
//

import KeyboardShortcuts
import SwiftUI

struct SettingsPage: View {
    let panelController: PanelController
    let checkForUpdates: () -> Void

    @Environment(SettingsStore.self) private var settings

    var body: some View {
        @Bindable var settings = settings

        Form {
            Section {
                KeyboardShortcuts.Recorder("Open Droppy", name: .openPanel)
            }
            
            Section {
                Picker("Panel location", selection: $settings.panelLocation) {
                    ForEach(PanelLocation.allCases) { span in
                        Text(span.rawValue)
                    }
                }
                
                if settings.panelLocation == .custom {
                    LabeledContent("Position") {
                        HStack {
                            Text("X")
                            TextField("", value: $settings.panelX, format: .number)
                                .padding(4)
                                .background(
                                  RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(white: 0.106))
                                )
                                .frame(width: 50)
                                .padding([.trailing], 20)
                                .onSubmit { panelController.updatePreviewFrame() }

                            Text("Y")
                            TextField("", value: $settings.panelY, format: .number)
                                .padding(4)
                                .background(
                                  RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(white: 0.106))
                                )
                                .frame(width: 50)
                                .onSubmit { panelController.updatePreviewFrame() }
                        }
                    }

                }

                LabeledContent("Size") {
                    HStack {
                        Text("W")
                        TextField("", value: $settings.panelWidth, format: .number)
                            .padding(4)
                            .background(
                              RoundedRectangle(cornerRadius: 4)
                                .fill(Color(white: 0.106))
                            )
                            .frame(width: 50)
                            .padding([.trailing], 20)
                            .onSubmit { panelController.updatePreviewFrame() }

                        Text("H")
                        TextField("", value: $settings.panelHeight, format: .number)
                            .padding(4)
                            .background(
                              RoundedRectangle(cornerRadius: 4)
                                .fill(Color(white: 0.106))
                            )
                            .frame(width: 50)
                            .onSubmit { panelController.updatePreviewFrame() }
                    }
                }
            }
            
            Section {
                Button("Check for Updates") {
                    checkForUpdates()
                }
            }
        }
        .formStyle(.grouped)
        .scrollDisabled(true)
        .fixedSize(horizontal: false, vertical: true)
        .onChange(of: settings.panelLocation) { _, _ in
            panelController.updatePreviewFrame()
        }
        .onAppear {
            updatePreview(settings: settings)
        }
        .onDisappear {
            panelController.hidePreview()
        }
        
        Text("Droppy \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")")
             .foregroundStyle(.secondary)
             .font(.caption)
             .frame(maxWidth: .infinity, alignment: .center)
             .padding(.bottom, 8)
    }

    private func updatePreview(settings: SettingsStore) {
        panelController.showPreview { newFrame in
            let sizeChanged = newFrame.width != settings.panelWidth || newFrame.height != settings.panelHeight
            if sizeChanged {
                settings.panelWidth = newFrame.width
                settings.panelHeight = newFrame.height
            } else {
                settings.panelX = newFrame.origin.x
                settings.panelY = newFrame.origin.y
            }
        }
    }
}

#Preview {
    SettingsPage(panelController: PanelController(store: NodeStore(), settings: SettingsStore()), checkForUpdates: {})
        .environment(SettingsStore())
}
