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

        panel = createMainPanel()
        statusItem = createMenuItem()
    }

    fileprivate func createMainPanel() -> FloatingPanel {
        let hostingController = NSHostingController(rootView: ContentView())
        hostingController.sizingOptions = .preferredContentSize
        let newPanel = FloatingPanel(
            contentRect: .zero,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        newPanel.contentViewController = hostingController
        newPanel.level = .floating
        newPanel.backgroundColor = .clear
        newPanel.isOpaque = false
        newPanel.hasShadow = true
        newPanel.isMovableByWindowBackground = true
        DispatchQueue.main.async { newPanel.center() }
        return newPanel
    }
    
    fileprivate func createMenuItem() -> NSStatusItem {
        // Menu bar status item
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            if let image = NSImage(named: "AppIcon") {
                image.size = NSSize(width: Appearence.menuBarIconSize, height: Appearence.menuBarIconSize)
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
        return statusItem
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
struct CapsuleApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Window is managed by AppDelegate; this satisfies @main requirement
        Settings { EmptyView() }
    }
}
