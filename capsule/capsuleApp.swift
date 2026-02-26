//
//  capsuleApp.swift
//  capsule
//
//  Created by eli segal on 26/02/2026.
//

import SwiftUI
import AppKit

// Borderless NSPanel that can still receive keyboard focus
class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var panel: FloatingPanel!

    func applicationDidFinishLaunching(_ notification: Notification) {
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
        panel.center()
        panel.makeKeyAndOrderFront(nil)
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
