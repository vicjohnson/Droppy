# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Building

Open `Droppy.xcodeproj` in Xcode. There are no CLI build or test commands — build with Cmd+B, run with Cmd+R. The only external dependency is the `KeyboardShortcuts` Swift package, resolved automatically by Xcode.

## Architecture

Droppy is a macOS snippet launcher. The user presses a global hotkey, a floating panel appears, and they navigate a key-driven tree of text snippets. Selecting a snippet copies it to the clipboard and simulates Cmd+V in the previously active app.

### Data model

`Node` (`Model/Node.swift`) is a recursive value type with two cases:
- `.folder(children: [Node])` — navigable group
- `.snippet(value: String)` — pasteable text

`NodeStore` (`Data/NodeStore.swift`) is `@Observable` and holds the root `[Node]` array. All tree mutations (insert, update, delete) are recursive value-type operations that rebuild the tree and immediately persist to JSON in Application Support. `NodeStore` is the single source of truth, passed via SwiftUI environment to the settings window.

### Two UI contexts

**Settings window** (`App/`) — a standard SwiftUI `WindowGroup` for managing the snippet tree. `ContentView` renders the tree in a `List`; `EditNodeView` is a sheet for adding/editing nodes; `NodeRow` is the list row component.

**Floating panel** (`Panel/`) — an `NSPanel` managed by `PanelController`. It's keyboard-driven: pressing a node's key activates it (drill into folders or paste snippets). `PanelView` holds a `@State var stack: [Node]` representing the folder navigation history. `Breadcrumbs` renders the nav trail. `PanelRow` is the panel's row component.

### App entry point

`DroppyApp` owns both `NodeStore` and `PanelController` as `@State` properties. It registers the `KeyboardShortcuts.onKeyUp` handler in `init`, capturing `PanelController` by reference. The global shortcut name (`openPanel`) is defined in `Model/Constants.swift`.

`PanelController` handles the full panel lifecycle: capturing the frontmost app before showing, positioning the panel, and on paste — writing to `NSPasteboard` then simulating Cmd+V via `CGEvent` after a short delay to let the previous app reactivate.
