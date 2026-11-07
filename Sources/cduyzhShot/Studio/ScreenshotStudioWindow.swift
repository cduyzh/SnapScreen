import AppKit
import CoreGraphics
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Studio Mode
public enum StudioMode: String, Equatable {
    case settings = "settings"
    case capture = "capture"
}

/// 每轮渲染使用独立参数，防止快速切换时混用不同选项。
public final class ScreenshotStudioWindowController: NSObject, NSWindowDelegate {
    public static let shared = ScreenshotStudioWindowController()

    private var window: NSWindow?
    private var currentSourceImage: CGImage?
    private let model = ScreenshotStudioModel()
    private let presentation = StudioPresentation()
    private var renderedPreviewImage: CGImage?
    private var savePanel: NSSavePanel?
    private var previewWork: DispatchWorkItem?
    private var renderRevision = 0
    public private(set) var currentMode: StudioMode = .capture
    private let renderQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.cduyzh.shot.studio-render"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInitiated
        return queue
    }()

    private override init() {
        super.init()
        model.onConfigChanged = { [weak self] newConfig in
            guard let self else { return }
            if self.currentMode == .settings {
                if UserPreferences.shared.studioConfig != newConfig {
                    UserPreferences.shared.studioConfig = newConfig
                    UserDefaults.standard.synchronize()
                }
            }
            self.updatePreview()
        }
    }

    public func openStudio(image: CGImage, mode: StudioMode = .capture) {
        currentMode = mode
        presentation.mode = mode
        currentSourceImage = image
        model.apply(config: UserPreferences.shared.studioConfig)
        renderedPreviewImage = nil
        presentation.preview = nil
        presentation.sourceSize = "\(image.width) × \(image.height)"
        presentation.message = ""
        presentation.outputSize = ""
        presentation.isExporting = false

        let windowTitle = (mode == .settings) ? "美化预设设置" : "图片美化"
        let windowSubtitle = (mode == .settings) ? "默认样式配置" : "iScreenshot"

        if let window {
            window.title = windowTitle
            window.subtitle = windowSubtitle
            if window.isMiniaturized {
                window.deminiaturize(nil)
            }
            window.level = .floating
            window.orderFrontRegardless()
            window.makeKeyAndOrderFront(nil)
        } else {
            let win = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 1060, height: 720),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered, defer: false
            )
            win.title = windowTitle
            win.subtitle = windowSubtitle
            win.titlebarAppearsTransparent = true
            win.toolbarStyle = .unified
            win.backgroundColor = .windowBackgroundColor
            win.minSize = NSSize(width: 840, height: 600)
            win.isReleasedWhenClosed = false
            win.level = .floating
            win.delegate = self
            win.contentView = NSHostingView(rootView: ScreenshotStudioView(
                model: model, presentation: presentation,
                onChange: { [weak self] in self?.updatePreview() },
                onSaveSettings: { [weak self] in self?.saveSettingsClicked() },
                onCopy: { [weak self] in self?.copyAndCloseClicked() },
                onSave: { [weak self] in self?.saveAsClicked() },
                onPin: { [weak self] in self?.pinClicked() },
                onClose: { [weak self] in self?.window?.close() }
            ))
            win.center()
            window = win
            win.orderFrontRegardless()
            win.makeKeyAndOrderFront(nil)
        }
        NSApp.activate(ignoringOtherApps: true)
        updatePreview()
    }

    public func updatePreview() {
        guard currentSourceImage != nil, window != nil else { return }
        let newConfig = model.toConfig()
        if currentMode == .settings {
            if UserPreferences.shared.studioConfig != newConfig {
                UserPreferences.shared.studioConfig = newConfig
                UserDefaults.standard.synchronize()
            }
        }
        renderRevision += 1
        let revision = renderRevision
        previewWork?.cancel()
        renderQueue.cancelAllOperations()
        presentation.isRendering = true
        presentation.message = ""
        let work = DispatchWorkItem { [weak self] in
            guard let self, let source = self.currentSourceImage, self.window != nil else { return }
            let snapshot = self.model.snapshot()
            let operation = BlockOperation()
            operation.addExecutionBlock { [weak self, weak operation] in
                guard operation?.isCancelled == false else { return }
                let rendered = autoreleasepool {
                    ScreenshotStudioRenderer.render(image: source, model: snapshot, targetScale: 2)
                }
                guard operation?.isCancelled == false else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self, self.window != nil, self.renderRevision == revision else { return }
                    self.renderedPreviewImage = rendered
                    self.presentation.isRendering = false
                    if let rendered {
                        self.presentation.preview = NSImage(cgImage: rendered, size: NSSize(width: rendered.width, height: rendered.height))
                        self.presentation.outputSize = "\(rendered.width) × \(rendered.height)"
                    } else {
                        self.presentation.message = "预览未能生成，请调整画幅或重试。"
                    }
                }
            }
            self.renderQueue.addOperation(operation)
        }
        previewWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: work)
    }

    private var exportImage: CGImage? {
        guard !presentation.isRendering, !presentation.isExporting else { return nil }
        return renderedPreviewImage
    }

    /// 设置模式下的明确保存设置并退出：绝对不污染剪贴板，不弹浮窗
    private func saveSettingsClicked() {
        let newConfig = model.toConfig()
        UserPreferences.shared.studioConfig = newConfig
        UserDefaults.standard.synchronize()
        playFeedbackSound()
        window?.close()
    }

    private func copyAndCloseClicked() {
        guard let image = exportImage else { return }
        if UserPreferences.shared.autoBeautifyScreenshot {
            UserPreferences.shared.studioConfig = model.toConfig()
            UserDefaults.standard.synchronize()
        }
        presentation.isExporting = true
        let revision = renderRevision
        let alsoAsFile = UserPreferences.shared.copyAsTempFileToClipboard
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let prepared = PasteboardHelper.prepareImage(image, alsoAsFile: alsoAsFile)
            DispatchQueue.main.async { [weak self] in
                guard let self, self.window != nil, self.renderRevision == revision else { return }
                self.presentation.isExporting = false
                guard let prepared, PasteboardHelper.publish(prepared) else {
                    self.showError("复制失败", detail: "无法写入剪贴板，请重试。")
                    return
                }
                self.playFeedbackSound()
                FloatingThumbnailWindow.shared.show(image: image, message: "已复制美化图片，可直接 ⌘V 粘贴")
                self.window?.close()
            }
        }
    }

    private func saveAsClicked() {
        guard let image = exportImage, let window, savePanel == nil else { return }
        let panel = NSSavePanel()
        savePanel = panel
        panel.title = "导出美化图片"
        panel.allowedContentTypes = [.png]
        panel.allowsOtherFileTypes = false
        panel.isExtensionHidden = false
        panel.prompt = "导出"
        panel.nameFieldStringValue = "cduyzhShot_\(DateFormatter.studioFileName.string(from: Date())).png"
        panel.directoryURL = UserPreferences.shared.saveDirectoryURL
        panel.canCreateDirectories = true
        panel.beginSheetModal(for: window) { [weak self, weak window] response in
            guard let self else { return }
            self.savePanel = nil
            guard response == .OK, let url = panel.url, self.window === window else { return }
            self.presentation.isExporting = true
            let revision = self.renderRevision
            DispatchQueue.global(qos: .userInitiated).async { [weak self, weak window] in
                let result: Result<Void, Error> = Result {
                    guard let data = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:]) else {
                        throw CocoaError(.fileWriteUnknown)
                    }
                    try data.write(to: url, options: .atomic)
                }
                DispatchQueue.main.async { [weak self, weak window] in
                    guard let self, self.window === window, self.renderRevision == revision else { return }
                    self.presentation.isExporting = false
                    switch result {
                    case .success:
                        self.presentation.message = "已保存：\(url.lastPathComponent)"
                        self.playFeedbackSound()
                        NotificationHelper.notifyScreenshotSaved(url: url)
                    case .failure(let error):
                        self.showError("无法保存图片", detail: error.localizedDescription)
                    }
                }
            }
        }
    }

    private func pinClicked() {
        guard let image = exportImage else { return }
        PinManager.shared.pin(image: image)
        playFeedbackSound()
        window?.close()
    }

    private func playFeedbackSound() {
        if UserPreferences.shared.playCaptureSound { SoundManager.shared.playCameraShutterSound() }
    }

    private func showError(_ title: String, detail: String) {
        guard let window else { return }
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = detail
        alert.alertStyle = .warning
        alert.beginSheetModal(for: window)
    }

    public func windowWillClose(_ notification: Notification) {
        renderRevision += 1
        previewWork?.cancel()
        previewWork = nil
        renderQueue.cancelAllOperations()
        savePanel?.cancel(nil)
        savePanel = nil
        window = nil
        currentSourceImage = nil
        renderedPreviewImage = nil
        presentation.preview = nil
        presentation.isRendering = false
        presentation.isExporting = false

        // 窗口关闭后刷新全局热键状态，确保退出编辑后快捷键立即 100% 可用
        DispatchQueue.main.async {
            AppState.shared.registerAllHotkeys()
        }
    }
}

private extension DateFormatter {
    static var studioFileName: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH.mm.ss"
        return formatter
    }
}
