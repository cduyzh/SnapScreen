import AppKit
import CoreGraphics

/// 水印渲染器：为长截图自动生成高质感、品牌化水印条带或右下角微标。
public enum WatermarkRenderer {
    /// 给目标图片底部无缝拼接官方水印条带
    public static func appendWatermark(to image: CGImage) -> CGImage {
        let imgWidth = CGFloat(image.width)
        let imgHeight = CGFloat(image.height)
        guard imgWidth > 0, imgHeight > 0 else { return image }

        // 水印底栏高度：基准 52pt，随宽度在 44~72 之间弹性缩放
        let stripHeight = max(44.0, min(imgWidth * 0.06, 72.0))
        let targetWidth = imgWidth
        let targetHeight = imgHeight + stripHeight

        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else { return image }
        guard let ctx = CGContext(
            data: nil,
            width: Int(targetWidth),
            height: Int(targetHeight),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return image }

        // 1. 绘制原长截图内容（位于顶部）
        let imageRect = CGRect(x: 0, y: stripHeight, width: imgWidth, height: imgHeight)
        ctx.draw(image, in: imageRect)

        // 2. 绘制水印底栏背景（墨夜底色搭配 1px 微光上分割线）
        ctx.saveGState()

        // 底色渐变 (#0E1116 -> #141820)
        let colors = [
            NSColor(calibratedRed: 0.05, green: 0.07, blue: 0.09, alpha: 1.0).cgColor,
            NSColor(calibratedRed: 0.09, green: 0.11, blue: 0.14, alpha: 1.0).cgColor
        ] as CFArray
        if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: nil) {
            ctx.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: stripHeight),
                end: CGPoint(x: 0, y: 0),
                options: []
            )
        }

        // 1px 上边框分割线
        ctx.setFillColor(NSColor(white: 1.0, alpha: 0.08).cgColor)
        ctx.fill(CGRect(x: 0, y: stripHeight - 1.0, width: targetWidth, height: 1.0))

        // 3. 绘制文字与品牌信息 (使用 NSGraphicsContext 绘制文字)
        NSGraphicsContext.saveGraphicsState()
        let nsCtx = NSGraphicsContext(cgContext: ctx, flipped: false)
        NSGraphicsContext.current = nsCtx

        let brandTitle = "iScreenshot 极速截屏" as NSString
        let brandSub = "·  长图无缝拼接  ·  cduyzh.top" as NSString

        let titleFont = NSFont.systemFont(ofSize: max(12.0, stripHeight * 0.28), weight: .semibold)
        let subFont = NSFont.monospacedDigitSystemFont(ofSize: max(10.0, stripHeight * 0.22), weight: .regular)

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: NSColor(white: 0.94, alpha: 1.0)
        ]
        let subAttrs: [NSAttributedString.Key: Any] = [
            .font: subFont,
            .foregroundColor: NSColor(white: 0.55, alpha: 1.0)
        ]

        let titleSize = brandTitle.size(withAttributes: titleAttrs)
        let subSize = brandSub.size(withAttributes: subAttrs)
        let totalTextWidth = titleSize.width + 8 + subSize.width

        let startX = max(16.0, (targetWidth - totalTextWidth) / 2)
        let titleY = (stripHeight - titleSize.height) / 2
        let subY = (stripHeight - subSize.height) / 2

        brandTitle.draw(at: CGPoint(x: startX, y: titleY), withAttributes: titleAttrs)
        brandSub.draw(at: CGPoint(x: startX + titleSize.width + 8, y: subY), withAttributes: subAttrs)

        NSGraphicsContext.restoreGraphicsState()
        ctx.restoreGState()

        return ctx.makeImage() ?? image
    }
}
