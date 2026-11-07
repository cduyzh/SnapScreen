import AppKit
import CoreGraphics

public final class PasteboardHelper {
    /// Copies an image to clipboard in all standard macOS formats:
    /// 1. PNG data (.png)
    /// 2. TIFF data (.tiff)
    /// 3. File URL (.fileURL / NSFilenamesPboardType) via CacheManager
    /// This ensures seamless Cmd+V pasting in ALL apps (WeChat, Slack, Telegram, Figma, Browsers, Finder).
    @discardableResult
    public static func copyImage(_ image: CGImage, alsoAsFile: Bool = true) -> URL? {
        guard let prepared = prepareImage(image, alsoAsFile: alsoAsFile) else { return nil }
        publish(prepared)
        return prepared.fileURL
    }

    struct PreparedImage {
        let png: Data
        let tiff: Data?
        let fileURL: URL?
    }

    /// 编码可在后台执行，剪贴板发布留在主线程。
    static func prepareImage(_ image: CGImage, alsoAsFile: Bool) -> PreparedImage? {
        let bitmap = NSBitmapImageRep(cgImage: image)
        guard let png = bitmap.representation(using: .png, properties: [:]) else { return nil }
        return PreparedImage(
            png: png,
            tiff: bitmap.representation(using: .tiff, properties: [:]),
            fileURL: alsoAsFile ? CacheManager.shared.saveTemporaryImage(image, prefix: "clip") : nil
        )
    }

    @discardableResult
    static func publish(_ image: PreparedImage, to pasteboard: NSPasteboard = .general) -> Bool {
        pasteboard.clearContents()
        var objects: [NSPasteboardWriting] = []
        if let fileURL = image.fileURL {
            objects.append(fileURL as NSURL)
        }
        if let nsImage = NSImage(data: image.png) {
            objects.append(nsImage)
        }
        if !objects.isEmpty {
            pasteboard.writeObjects(objects)
        }
        if pasteboard.data(forType: .png) == nil {
            pasteboard.setData(image.png, forType: .png)
        }
        if let tiff = image.tiff, pasteboard.data(forType: .tiff) == nil {
            pasteboard.setData(tiff, forType: .tiff)
        }
        return true
    }

    /// Copies a local file URL to clipboard.
    public static func copyFile(at url: URL) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.writeObjects([url as NSURL])
    }

    /// Copies a plain text string (e.g. hex color) to clipboard.
    public static func copyString(_ string: String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(string, forType: .string)
    }
}
