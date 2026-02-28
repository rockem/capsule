//
//  capsuleApp.swift
//  capsule
//
//  Created by eli segal on 26/02/2026.
//

import AppKit
import SwiftUI

// Borderless NSPanel that can still receive keyboard focus
class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var panel: FloatingPanel!
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_: Notification) {
        // Hide Dock icon — Capsule lives only in the menu bar
        NSApp.setActivationPolicy(.accessory)

        let hostingController = NSHostingController(rootView: ContentView())
        hostingController.sizingOptions = .preferredContentSize

        panel = FloatingPanel(
            contentRect: .zero,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        panel.contentViewController = hostingController
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.isMovableByWindowBackground = true
        DispatchQueue.main.async { self.panel.center() }

        // Menu bar status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            if let image = NSImage(named: "AppIcon") {
                image.size = NSSize(width: 18, height: 18)
                button.image = image
            }
            button.setAccessibilityLabel("Capsule")
            let menu = NSMenu()
            menu.addItem(withTitle: "Open Capsule", action: #selector(togglePanel), keyEquivalent: "")
                .target = self
            menu.addItem(.separator())
            menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
            statusItem.menu = menu
        }
    }

    @objc private func togglePanel() {
        if panel.isVisible {
            panel.orderOut(nil)
        } else {
            panel.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

@main
struct capsuleApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Window is managed by AppDelegate; this satisfies @main requirement
        Settings { EmptyView() }
    }
}
