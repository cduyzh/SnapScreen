import AppKit
import SwiftUI

/// 管理 SnapScreen Pro 付费墙窗口的独立控制器
public final class PaywallWindowController: NSObject, NSWindowDelegate {
    public static let shared = PaywallWindowController()

    private var window: NSPanel?
    private var triggerReason: String?

    private override init() {
        super.init()
    }

    /// 显示付费墙浮窗
    public func show(reason: String? = nil) {
        self.triggerReason = reason

        if let existing = window {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 660, height: 720),
            styleMask: [.titled, .closable, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.title = "SnapScreen Pro"
        panel.titlebarAppearsTransparent = true
        panel.titleVisibility = .hidden
        panel.isMovableByWindowBackground = true
        panel.level = .floating
        panel.center()
        panel.isReleasedWhenClosed = false
        panel.delegate = self
        panel.backgroundColor = .clear
        panel.hasShadow = true

        let paywallView = PaywallView { [weak self] in
            self?.close()
        }

        let hostingView = NSHostingView(rootView: paywallView)
        hostingView.wantsLayer = true
        hostingView.layer?.cornerRadius = 14
        hostingView.layer?.masksToBounds = true
        panel.contentView = hostingView

        self.window = panel
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    public func close() {
        window?.orderOut(nil)
        window = nil
    }

    public func windowWillClose(_ notification: Notification) {
        window = nil
    }
}
