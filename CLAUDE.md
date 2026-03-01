# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Capsule** is a macOS 15.2+ menu bar command launcher. A borderless floating panel appears when the user clicks the
menu bar icon; the user types a shell command, sees the output inline, and `cd` is tracked across runs. Pressing Escape
hides the panel; it can be re-opened from the menu bar.

## Build & Test Commands

```bash
# Build the app
xcodebuild -scheme capsule -configuration Debug build

# Run all tests (unit + UI)
xcodebuild -scheme capsule -destination 'platform=macOS' test CODE_SIGNING_ALLOWED=NO

# Lint & format
pre-commit run --all-files
```

Unit tests use Apple's `Testing` framework (`@Test`, `#expect`). UI tests use `XCTest` via `CapsuleAppDriver`.

## Architecture

The app bypasses the standard SwiftUI `WindowGroup` lifecycle. The `@main` struct satisfies the Swift entry-point
requirement with `Settings { EmptyView() }`, while `AppDelegate` manages everything else.

### Lifecycle & window management (`capsuleApp.swift`)

- `NSApp.setActivationPolicy(.accessory)` hides the Dock icon at launch.
- `AppDelegate` creates a `FloatingPanel` (`NSPanel` subclass with `canBecomeKey/Main = true`) at `.floating` window
  level but does **not** show it on launch.
- An `NSStatusItem` with the app icon sits in the menu bar.
  Its menu has **Open Capsule** (toggles panel visibility) and **Quit**.
- `togglePanel` calls `makeKeyAndOrderFront` + `NSApp.activate(ignoringOtherApps: true)` to show and focus the panel.

### UI (`ContentView.swift`, `ResultPanel.swift`)

- All UI state lives in `ContentView`: `command`, `lastCommand`, `result`, `isRunning`, `isOutputExpanded`, `currentDirectory`.
- The TextField auto-focuses via `.onAppear { DispatchQueue.main.async { focused = true } }` — the async dispatch is
  required for SwiftUI's focus engine to be ready.
- Escape hides the panel via `NSApp.keyWindow?.orderOut(nil)` (does not quit).
- `ResultPanel` renders the output of the last command in a scrollable monospaced view (max 300 pt tall), anchored to
  the bottom.

### Command execution (`CommandRunner.swift`)

- Stateless enum. Each call spawns `$SHELL -l -c` in the given directory.
- The shell script: `cd '<dir>'; <command>; _ec=$?; printf '\n__CAPSULE_PWD__:%s' "$PWD"; exit $_ec`
- stdout and stderr share one `Pipe`. The `__CAPSULE_PWD__` sentinel at the end of output is stripped by `parse(_:)` to
  extract the post-command working directory.

## UI Testing

UI tests go through `CapsuleAppDriver` (page-object wrapper around `XCUIApplication`). `launch()` clicks the **Capsule**
menu bar status item, then **Open Capsule**, before waiting for the panel.

When adding new UI elements that tests need to find, give them `.accessibilityIdentifier(...)`. Current identifiers:

| Identifier | Element |
| --- | --- |
| `commandInputField` | The command `TextField` |
| `currentDirectoryLabel` | The `Text` showing the working directory |
| `lastCommandHeader` | The `Text` showing `$ <last command>` in the output panel |

## App Sandbox

The app runs **without** the macOS sandbox (`com.apple.security.app-sandbox = false` in `capsule/capsule.entitlements`)
so it can launch arbitrary shell processes.

## Code Quality

Pre-commit hooks are configured in `.pre-commit-config.yaml`: trailing whitespace, EOF newlines, YAML/JSON checks,
SwiftFormat (Swift 6), and SwiftLint (see `.swiftlint.yml`). Install with `pre-commit install`.
