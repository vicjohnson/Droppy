//
//  SettingsPage.swift
//  Droppy
//

import SwiftUI
import KeyboardShortcuts

struct SettingsPage: View {
    let panelController: PanelController

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
                            
                            Text("Y")
                            TextField("", value: $settings.panelY, format: .number)
                                .padding(4)
                                .background(
                                  RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(white: 0.106))
                                )
                                .frame(width: 50)
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
                        
                        Text("H")
                        TextField("", value: $settings.panelHeight, format: .number)
                            .padding(4)
                            .background(
                              RoundedRectangle(cornerRadius: 4)
                                .fill(Color(white: 0.106))
                            )
                            .frame(width: 50)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .scrollDisabled(true)
        .fixedSize(horizontal: false, vertical: true)
        .onChange(of: settings.panelLocation) { _, _ in
            panelController.updatePreviewFrame()
        }
        .onChange(of: settings.customPanelFrame) { _, _ in
            panelController.updatePreviewFrame()
        }
        .onAppear {
            updatePreview(settings: settings)
        }
        .onDisappear {
            panelController.hidePreview()
        }
    }

    private func updatePreview(settings: SettingsStore) {
        panelController.showPreview { newFrame in
            settings.panelX = newFrame.origin.x
            settings.panelY = newFrame.origin.y
        }
    }
}

#Preview {
    SettingsPage(panelController: PanelController(store: NodeStore(), settings: SettingsStore()))
        .environment(SettingsStore())
}
