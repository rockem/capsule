# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Capsule** is a macOS 15.2+ floating command launcher. A borderless panel stays above all windows; the user types a shell command, sees the output inline, and `cd` is tracked across runs.

## Build & Test Commands

```bash
# Build the app
xcodebuild -scheme capsule -configuration Debug build

# Run unit tests (add CODE_SIGNING_ALLOWED=NO if running without a signing identity)
xcodebuild -scheme capsule -destination 'platform=macOS' test CODE_SIGNING_ALLOWED=NO

# Run a single test (replace TestName with the @Test function name)
xcodebuild -scheme capsule -destination 'platform=macOS' -only-testing:capsuleTests/TestName test CODE_SIGNING_ALLOWED=NO
```

Tests use Apple's `Testing` framework (Swift async/await) for unit tests and `XCTest` for UI tests.

## Architecture

The app bypasses the standard SwiftUI `WindowGroup` lifecycle. The `@main` struct satisfies the Swift entry-point requirement with `Settings { EmptyView() }`, while `AppDelegate` creates a custom `FloatingPanel` (`NSPanel` subclass with `canBecomeKey/Main = true`) and hosts `ContentView` inside it at `.floating` window level.

Key files:
- **`capsuleApp.swift`** — `FloatingPanel` + `AppDelegate` (panel creation, always-on-top), `capsuleApp` entry point
- **`ContentView.swift`** — all UI state (`command`, `result`, `isRunning`, `isOutputExpanded`, `currentDirectory`); calls `CommandRunner.run` via `Task.detached`
- **`CommandRunner.swift`** — stateless command execution. Each invocation spawns `$SHELL -l -c` with the user's current directory, injects a `__CAPSULE_PWD__` sentinel to capture the post-command `$PWD`, and returns a `Result` (output, exitCode, newDirectory)
- **`ShellSession.swift`** — alternative persistent shell approach (`ObservableObject`); keeps a single long-running login shell process open and communicates via pipes + a UUID sentinel. **Not currently wired up in ContentView.**

## App Sandbox

The app runs **without** the macOS sandbox (`com.apple.security.app-sandbox = false` in `capsule/capsule.entitlements`) so it can launch arbitrary shell processes.
