import AppKit
import CoreImage

/// 纯原生 macOS CoreImage 高清二维码生成器
public enum QRCodeGenerator {
    private static let context = CIContext()

    /// 生成指定文本的高清 NSImage 二维码
    public static func generate(from string: String, size: CGFloat = 200) -> NSImage? {
        guard let data = string.data(using: .utf8) else { return nil }
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }

        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel") // 中等纠错率

        guard let outputCI = filter.outputImage else { return nil }

        // 计算缩放比例
        let extent = outputCI.extent
        guard extent.width > 0, extent.height > 0 else { return nil }
        let scale = size / extent.width
        let transformed = outputCI.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard let cgImage = context.createCGImage(transformed, from: transformed.extent) else {
            return nil
        }

        return NSImage(cgImage: cgImage, size: NSSize(width: size, height: size))
    }
}
