# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Capsule** is a macOS/iOS SwiftUI application (deployment target: macOS 15.2). It is currently a minimal starter project built from the Xcode default template.

## Build & Test Commands

```bash
# Build the app
xcodebuild -scheme capsule -configuration Debug build

# Run unit tests
xcodebuild -scheme capsule -destination 'platform=macOS' test

# Run a single test (replace TestName with the @Test function name)
xcodebuild -scheme capsule -destination 'platform=macOS' -only-testing:capsuleTests/TestName test
```

Tests use Apple's `Testing` framework (Swift async/await) for unit tests and `XCTest` for UI tests.

## Architecture

- **Entry point:** `capsule/capsuleApp.swift` — `@main` SwiftUI App struct with a single `WindowGroup`
- **Root view:** `capsule/ContentView.swift` — top-level SwiftUI `View`
- **Unit tests:** `capsuleTests/capsuleTests.swift` — uses `@Test` attributes (Apple Testing framework)
- **UI tests:** `capsuleUITests/capsuleUITests.swift` — uses `XCUIApplication`

The app uses SwiftUI scene-based lifecycle (`WindowGroup`). New features should follow SwiftUI conventions with views, view models, and environment objects as the app grows.

## App Sandbox

The app runs under macOS sandbox (`com.apple.security.app-sandbox`) with read-only user-selected file access. Any new entitlements must be added to `capsule/capsule.entitlements`.
