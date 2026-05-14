//
//  SettingsPage.swift
//  Droppy
//

import SwiftUI
import KeyboardShortcuts

struct SettingsPage: View {
    @Environment(SettingsStore.self) private var settings
    
    @State private var asdf: Int = 0
    
    var body: some View {
        @Bindable var settings = settings
        
        Form {
            Section {
                KeyboardShortcuts.Recorder("Open Droppy", name: .openPanel)
            }
            
            Section {
                Picker("Panel location", selection: $settings.panelLocation) {
                    ForEach(PanelLocation.allCases) { span in
                        Text(span.rawValue.capitalized)
                    }
                }
                
                if settings.panelLocation == .custom {
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
            }
        }
        .formStyle(.grouped)
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    SettingsPage()
        .environment(SettingsStore())
}
