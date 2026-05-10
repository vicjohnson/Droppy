//
//  ContentView.swift
//  Droppy
//

import SwiftUI

struct ContentView: View {
    @Environment(NodeStore.self) private var store
    @State private var selectedID: UUID?
    @State private var formMode: EditNodeView.Mode?

    private var selectedFolder: Node? {
        guard let id = selectedID, let node = store.node(id: id), node.isFolder else { return nil }
        return node
    }

    var body: some View {
        List(store.root, id: \.id, children: \.children, selection: $selectedID) { node in
            NodeRow(node: node)
                .padding(4)
                .contextMenu {
                    if node.isFolder {
                        Button("Add to \(node.name)") {
                            formMode = .add(parentID: node.id)
                        }
                        Divider()
                    }
                    Button("Edit") {
                        formMode = .edit(node: node)
                    }
                    Button("Delete", role: .destructive) {
                        store.delete(node.id)
                    }
                }
        }
        .toolbar {
            Button(action: {
                formMode = .add(parentID: selectedFolder?.id)
            }) {
                Label("Add", systemImage: "plus")
            }
        }
        .sheet(item: $formMode) { mode in
            EditNodeView(mode: mode) {
                formMode = nil
            }
        }
        .frame(minWidth: 400, minHeight: 300)
        .navigationTitle("Droppy")
        .overlay {
            if store.root.isEmpty {
                VStack {
                    Text("No items")
                    Button("Add a snippet") {
                        formMode = .add(parentID: nil)
                    }
                }
            }
        }
//        .overlay(alignment: .bottom) {
//            GeometryReader { geo in
//                Text("\(Int(geo.size.width)) × \(Int(geo.size.height))")
//                    .font(.caption2)
//                    .foregroundStyle(.secondary)
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .padding(.bottom, 4)
//                    .frame(maxHeight: .infinity, alignment: .bottom)
//            }
//        }
    }
}

#Preview("ContentView") {
    let store = NodeStore()
    return ContentView()
        .environment(store)
}

#Preview("Empty") {
    let store = NodeStore(preview: true)
    store.root = []
    
    return ContentView()
        .environment(store)
}
