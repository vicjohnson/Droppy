//
//  NodeStore.swift
//  Droppy
//

import Foundation

@Observable
final class NodeStore {
    var root: [PasteNode] = []

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("nodes.json")
    }()

    init() {
        load()
        #if DEBUG
        if root.isEmpty {
            loadSampleData()
        }
        #endif
    }

    private func loadSampleData() {
        root = [
            PasteNode(key: "d", name: "Development", content: .folder(children: [
                PasteNode(key: "l", name: "Localhost URL", content: .snippet(value: "http://localhost:3000")),
                PasteNode(key: "g", name: "Git email", content: .snippet(value: "vic@example.com")),
            ])),
            PasteNode(key: "p", name: "Personal", content: .folder(children: [
                PasteNode(key: "e", name: "Email", content: .snippet(value: "vic@example.com")),
            ])),
            PasteNode(key: "h", name: "Hello World", content: .snippet(value: "Hello World")),
        ]
        save()
    }

    // MARK: - Mutations

    func addFolder(key: String, name: String, to parentID: UUID? = nil) {
        let node = PasteNode(key: key, name: name, content: .folder(children: []))
        insert(node, into: parentID)
        save()
    }

    func addSnippet(key: String, name: String, value: String, to parentID: UUID? = nil) {
        let node = PasteNode(key: key, name: name, content: .snippet(value: value))
        insert(node, into: parentID)
        save()
    }

    func delete(_ id: UUID) {
        root = remove(id, from: root)
        save()
    }

    func update(id: UUID, key: String, name: String, value: String?) {
        root = updateNode(id: id, key: key, name: name, value: value, in: root)
        save()
    }

    // MARK: - Lookup

    func node(id: UUID) -> PasteNode? {
        find(id, in: root)
    }

    func isDuplicateKey(_ key: String, in parentID: UUID?, excludingID: UUID? = nil) -> Bool {
        let siblings = parentID.flatMap { find($0, in: root)?.children } ?? root
        return siblings.contains { $0.key == key && $0.id != excludingID }
    }

    // MARK: - Persistence

    private func save() {
        do {
            let data = try JSONEncoder().encode(root)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save nodes: \(error)")
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([PasteNode].self, from: data) {
            root = decoded
        }
    }

    // MARK: - Tree helpers

    private func insert(_ node: PasteNode, into parentID: UUID?) {
        if let parentID {
            root = insertInto(parentID, in: root, node: node)
        } else {
            root.append(node)
        }
    }

    private func insertInto(_ parentID: UUID, in nodes: [PasteNode], node: PasteNode) -> [PasteNode] {
        nodes.map { n in
            if n.id == parentID, case .folder(var children) = n.content {
                children.append(node)
                return PasteNode(id: n.id, key: n.key, name: n.name, content: .folder(children: children))
            } else if case .folder(let children) = n.content {
                return PasteNode(id: n.id, key: n.key, name: n.name, content: .folder(children: insertInto(parentID, in: children, node: node)))
            }
            return n
        }
    }

    private func remove(_ id: UUID, from nodes: [PasteNode]) -> [PasteNode] {
        nodes.compactMap { n in
            if n.id == id { return nil }
            if case .folder(let children) = n.content {
                return PasteNode(id: n.id, key: n.key, name: n.name, content: .folder(children: remove(id, from: children)))
            }
            return n
        }
    }

    private func updateNode(id: UUID, key: String, name: String, value: String?, in nodes: [PasteNode]) -> [PasteNode] {
        nodes.map { n in
            if n.id == id {
                let content: PasteNode.Content
                if case .folder(let children) = n.content {
                    content = .folder(children: children)
                } else {
                    content = .snippet(value: value ?? "")
                }
                return PasteNode(id: n.id, key: key, name: name, content: content)
            } else if case .folder(let children) = n.content {
                return PasteNode(id: n.id, key: n.key, name: n.name, content: .folder(children: updateNode(id: id, key: key, name: name, value: value, in: children)))
            }
            return n
        }
    }

    private func find(_ id: UUID, in nodes: [PasteNode]) -> PasteNode? {
        for node in nodes {
            if node.id == id { return node }
            if let children = node.children, let found = find(id, in: children) { return found }
        }
        return nil
    }
}
