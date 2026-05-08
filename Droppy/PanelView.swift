//
//  PanelView.swift
//  Droppy

import SwiftUI

struct PanelView: View {
    let store: NodeStore
    let dismiss: () -> Void
    let paste: (String) -> Void

    @State private var stack: [(name: String, nodes: [PasteNode])] = []
    @FocusState private var focused: Bool

    private var current: [PasteNode] {
        stack.last?.nodes ?? store.root
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
//                if !stack.isEmpty {
//                    Button(action: goBack) {
//                        Image(systemName: "chevron.left")
//                    }
//                    .buttonStyle(.plain)
//                    .foregroundStyle(.secondary)
//                }
                
                Button("Home") { stack.removeAll() }
                    .buttonStyle(.plain)
                    .foregroundStyle(stack.isEmpty ? .primary : .secondary)
                
                ForEach(stack.indices, id: \.self) { i in
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Button(stack[i].name) { stack.removeSubrange((i + 1)...) }
                        .buttonStyle(.plain)
                        .foregroundStyle(i == stack.indices.last ? .primary : .secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            Divider()

            if current.isEmpty {
                Text("No items")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(current) { node in
                            NodeRow(node: node)
                            Divider()
                        }
                    }
                }
            }
        }
        .frame(width: 320, height: 400)
        .background(.regularMaterial)
        .focusable()
        .focused($focused)
        .focusEffectDisabled()
        .onKeyPress(phases: .down) { press in
            handleKey(press)
        }
        .onAppear { focused = true }
    }

    private func handleKey(_ press: KeyPress) -> KeyPress.Result {
        if press.key == .escape {
            if stack.isEmpty {
                dismiss()
            } else {
                goBack()
            }
            return .handled
        }

        let char = String(press.characters)
        if let match = current.first(where: { $0.key == char }) {
            activate(match)
            return .handled
        }

        return .ignored
    }

    private func activate(_ node: PasteNode) {
        switch node.content {
        case .folder(let children):
            stack.append((name: node.name, nodes: children))
        case .snippet(let value):
            paste(value)
        }
    }

    private func goBack() {
        stack.removeLast()
    }
}

private struct NodeRow: View {
    let node: PasteNode

    var body: some View {
        HStack(spacing: 12) {
            Text(node.key)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 20)
            
            Text(node.name)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if node.isFolder {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            } else {
                Text(node.value ?? "")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

#Preview {
    let store = NodeStore()
    return PanelView(store: store, dismiss: {}, paste: { _ in })
}
