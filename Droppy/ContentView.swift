//
//  ContentView.swift
//  Droppy
//

import SwiftUI

struct ContentView: View {
    @Environment(NodeStore.self) private var store
    @State private var selectedID: UUID?
    @State private var formMode: NodeFormView.Mode?

    private var selectedFolder: PasteNode? {
        guard let id = selectedID, let node = store.node(id: id), node.isFolder else { return nil }
        return node
    }

    var body: some View {
        List(store.root, id: \.id, children: \.children, selection: $selectedID) { node in
            NodeRow(node: node)
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
            NodeFormView(mode: mode) {
                formMode = nil
            }
        }
        .frame(minWidth: 400, minHeight: 300)
        .navigationTitle("Droppy")
        .overlay(alignment: .bottom) {
            GeometryReader { geo in
                Text("\(Int(geo.size.width)) × \(Int(geo.size.height))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 4)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
    }
}

private struct NodeRow: View {
    let node: PasteNode

    var body: some View {
        HStack(spacing: 8) {
            Text(node.key)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 20)
            Text(node.name)
            Spacer()
            if let value = node.value {
                Text(value)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(4)
    }
}

struct NodeFormView: View {
    enum Mode: Identifiable {
        case add(parentID: UUID?)
        case edit(node: PasteNode)

        var id: String {
            switch self {
            case .add: return "add"
            case .edit(let node): return node.id.uuidString
            }
        }
    }

    let mode: Mode
    let onDone: () -> Void

    @Environment(NodeStore.self) private var store
    @State private var key: String
    @State private var name: String
    @State private var value: String

    init(mode: Mode, onDone: @escaping () -> Void) {
        self.mode = mode
        self.onDone = onDone
        switch mode {
        case .add:
            _key = State(initialValue: "")
            _name = State(initialValue: "")
            _value = State(initialValue: "")
        case .edit(let node):
            _key = State(initialValue: node.key)
            _name = State(initialValue: node.name)
            _value = State(initialValue: node.value ?? "")
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var isEditingFolder: Bool {
        if case .edit(let node) = mode { return node.isFolder }
        return false
    }

    private var parentID: UUID? {
        if case .add(let id) = mode { return id }
        return nil
    }

    private var excludingID: UUID? {
        if case .edit(let node) = mode { return node.id }
        return nil
    }

    private var isDuplicateKey: Bool {
        guard !key.isEmpty else { return false }
        return store.isDuplicateKey(key, in: parentID, excludingID: excludingID)
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                TextField("Name", text: $name)
                TextField("Key", text: $key)
                    .onChange(of: key) {
                        if key.count > 1 { key = String(key.suffix(1)) }
                    }
                
                if !isEditingFolder {
                    TextField("Value", text: $value, axis: .vertical)
                        .lineLimit(1...6)
                }
            }
            .formStyle(.grouped)
            
            if isDuplicateKey {
                Text("Key \"\(key)\" is already used")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding([.bottom], 16)
            }
        }
        .frame(width: 340)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { onDone() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("\(isEditing ? "Save" : "Add") \(value.isEmpty ? " folder" : " snippet")") {
                    commit()
                    onDone()
                }
                .disabled(key.isEmpty || name.isEmpty || isDuplicateKey)
            }
        }
    }

    private func commit() {
        switch mode {
        case .add(let parentID):
            if value.isEmpty {
                store.addFolder(key: key, name: name, to: parentID)
            } else {
                store.addSnippet(key: key, name: name, value: value, to: parentID)
            }
        case .edit(let node):
            store.update(id: node.id, key: key, name: name, value: node.isFolder ? nil : value)
        }
    }
}

#Preview("ContentView") {
    let store = NodeStore()
    return ContentView()
        .environment(store)
}
