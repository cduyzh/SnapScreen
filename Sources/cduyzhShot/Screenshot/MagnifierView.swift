import AppKit
import CoreGraphics

public final class MagnifierView: NSView {
    public var currentPoint: CGPoint = .zero {
        didSet { needsDisplay = true }
    }
    public var selectionSize: CGSize = .zero {
        didSet { needsDisplay = true }
    }
    public var sourceImage: CGImage? {
        didSet { needsDisplay = true }
    }
    public var screenScale: CGFloat = 2.0
    public private(set) var currentHexColor: String = "#FFFFFF"

    public private(set) var isShowingCopyFeedback: Bool = false
    private var copyFeedbackTimer: Timer?
    private var copiedColorHex: String = ""

    private let sampleRadius: Int = 4 // 9x9 crystal grid
    private let aquaColor = NSColor(calibratedRed: 0.0, green: 0.898, blue: 0.639, alpha: 1.0) // #00E5A3

    public override var isFlipped: Bool { true }

    public override init(frame frameRect: NSRect) {
        super.init(frame: NSRect(x: 0, y: 0, width: 156, height: 194))
        wantsLayer = true
        layer?.cornerRadius = 12
        layer?.masksToBounds = false
        layer?.shadowColor = NSColor.black.cgColor
        layer?.shadowOpacity = 0.45
        layer?.shadowRadius = 16
        layer?.shadowOffset = CGSize(width: 0, height: -4)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func triggerCopyFeedback() {
        copiedColorHex = currentHexColor
        isShowingCopyFeedback = true
        needsDisplay = true

        copyFeedbackTimer?.invalidate()
        copyFeedbackTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.isShowingCopyFeedback = false
            self.needsDisplay = true
        }
    }

    public override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }

        // 1. Background Card (Neo-Aqua Card from design specification)
        let cardPath = CGPath(roundedRect: bounds, cornerWidth: 12, cornerHeight: 12, transform: nil)
        context.addPath(cardPath)
        context.setFillColor(NSColor(calibratedRed: 0.05, green: 0.07, blue: 0.12, alpha: 0.94).cgColor)
        context.fillPath()

        // 2. Glowing Aqua Outer Border (#00E5A3 with soft outer glow)
        context.saveGState()
        context.setStrokeColor(aquaColor.cgColor)
        context.setLineWidth(2.0)
        context.setShadow(offset: .zero, blur: 6.0, color: aquaColor.withAlphaComponent(0.65).cgColor)
        context.addPath(cardPath)
        context.strokePath()
        context.restoreGState()

        // 3. 9x9 Pixel Grid Area (132 x 132 rounded-corner rectangular grid)
        let gridRect = CGRect(x: 12, y: 12, width: bounds.width - 24, height: 132)
        let gridClipPath = CGPath(roundedRect: gridRect, cornerWidth: 6, cornerHeight: 6, transform: nil)

        var centerColor = NSColor.white

        if let image = sourceImage {
            context.saveGState()
            context.addPath(gridClipPath)
            context.clip()

            // Calculate pixel crop
            let pixelX = currentPoint.x * screenScale
            let pixelY = currentPoint.y * screenScale
            let cropW = CGFloat(sampleRadius * 2 + 1)
            let cropH = CGFloat(sampleRadius * 2 + 1)
            let cropRect = CGRect(
                x: pixelX - CGFloat(sampleRadius),
                y: pixelY - CGFloat(sampleRadius),
                width: cropW,
                height: cropH
            )

            if let cropped = image.cropping(to: cropRect) {
                NSImage(cgImage: cropped, size: gridRect.size).draw(in: gridRect)
            }

            // Sample center pixel color
            centerColor = samplePixelColor(from: image, at: CGPoint(x: pixelX, y: pixelY))

            // Draw pixel grid lines
            context.setStrokeColor(NSColor(white: 1.0, alpha: 0.12).cgColor)
            context.setLineWidth(0.5)
            let cellW = gridRect.width / cropW
            let cellH = gridRect.height / cropH
            for i in 0...Int(cropW) {
                let x = gridRect.minX + CGFloat(i) * cellW
                context.move(to: CGPoint(x: x, y: gridRect.minY))
                context.addLine(to: CGPoint(x: x, y: gridRect.maxY))
            }
            for j in 0...Int(cropH) {
                let y = gridRect.minY + CGFloat(j) * cellH
                context.move(to: CGPoint(x: gridRect.minX, y: y))
                context.addLine(to: CGPoint(x: gridRect.maxX, y: y))
            }
            context.strokePath()

            // Center Target Crosshair Box (#00E5A3 bounding the center pixel)
            let centerX = gridRect.midX
            let centerY = gridRect.midY
            let targetRect = CGRect(x: centerX - cellW / 2, y: centerY - cellH / 2, width: cellW, height: cellH)

            context.saveGState()
            context.setStrokeColor(aquaColor.cgColor)
            context.setLineWidth(1.6)
            context.setShadow(offset: .zero, blur: 5.0, color: aquaColor.withAlphaComponent(0.8).cgColor)
            context.stroke(targetRect)
            context.restoreGState()

            context.restoreGState()
        }

        // Inner border around grid area
        context.addPath(gridClipPath)
        context.setStrokeColor(NSColor(white: 1.0, alpha: 0.18).cgColor)
        context.setLineWidth(0.8)
        context.strokePath()

        // 4. Subtle Divider Line
        let dividerY = gridRect.maxY + 4
        context.setStrokeColor(NSColor(white: 1.0, alpha: 0.10).cgColor)
        context.setLineWidth(0.6)
        context.move(to: CGPoint(x: 12, y: dividerY))
        context.addLine(to: CGPoint(x: bounds.width - 12, y: dividerY))
        context.strokePath()

        // Format Hex
        let hexString = String(
            format: "#%02X%02X%02X",
            Int(centerColor.redComponent * 255),
            Int(centerColor.greenComponent * 255),
            Int(centerColor.blueComponent * 255)
        )
        self.currentHexColor = hexString

        // 5. Readout Bar (Interactive Feedback vs Normal Display)
        if isShowingCopyFeedback {
            // High-visibility green feedback capsule
            let feedbackRect = CGRect(x: 12, y: dividerY + 5, width: bounds.width - 24, height: 32)
            let capPath = CGPath(roundedRect: feedbackRect, cornerWidth: 6, cornerHeight: 6, transform: nil)

            context.saveGState()
            context.addPath(capPath)
            context.setFillColor(NSColor(calibratedRed: 0.0, green: 0.898, blue: 0.639, alpha: 0.22).cgColor)
            context.fillPath()

            context.addPath(capPath)
            context.setStrokeColor(aquaColor.cgColor)
            context.setLineWidth(1.2)
            context.setShadow(offset: .zero, blur: 4.0, color: aquaColor.withAlphaComponent(0.7).cgColor)
            context.strokePath()
            context.restoreGState()

            let feedbackText = "✓ 已复制 \(copiedColorHex.isEmpty ? hexString : copiedColorHex)"
            let feedbackAttrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .bold),
                .foregroundColor: NSColor.white
            ]
            let textSize = (feedbackText as NSString).size(withAttributes: feedbackAttrs)
            let textOrigin = CGPoint(
                x: feedbackRect.midX - textSize.width / 2,
                y: feedbackRect.midY - textSize.height / 2
            )
            (feedbackText as NSString).draw(at: textOrigin, withAttributes: feedbackAttrs)
        } else {
            // Line 1: Color Swatch + Hex Code (left) & RGB Value (right)
            let swatchRect = CGRect(x: 12, y: dividerY + 7, width: 10, height: 10)
            let swatchPath = CGPath(roundedRect: swatchRect, cornerWidth: 2.5, cornerHeight: 2.5, transform: nil)
            context.addPath(swatchPath)
            context.setFillColor(centerColor.cgColor)
            context.fillPath()
            context.addPath(swatchPath)
            context.setStrokeColor(NSColor(white: 1.0, alpha: 0.8).cgColor)
            context.setLineWidth(0.8)
            context.strokePath()

            let hexAttrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .bold),
                .foregroundColor: aquaColor
            ]
            (hexString as NSString).draw(at: CGPoint(x: swatchRect.maxX + 5, y: dividerY + 5), withAttributes: hexAttrs)

            let rgbText = String(
                format: "RGB %d, %d, %d",
                Int(centerColor.redComponent * 255),
                Int(centerColor.greenComponent * 255),
                Int(centerColor.blueComponent * 255)
            )
            let rgbAttrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedSystemFont(ofSize: 9.0, weight: .medium),
                .foregroundColor: NSColor(white: 0.85, alpha: 0.88)
            ]
            let rgbSize = (rgbText as NSString).size(withAttributes: rgbAttrs)
            (rgbText as NSString).draw(
                at: CGPoint(x: bounds.width - 12 - rgbSize.width, y: dividerY + 6.5),
                withAttributes: rgbAttrs
            )

            // Line 2: Coordinates or Selection Size (left) & "按 C 复制" Tip (right)
            let infoText: String
            if selectionSize.width > 0 && selectionSize.height > 0 {
                infoText = "\(Int(selectionSize.width)) × \(Int(selectionSize.height))"
            } else {
                infoText = "X:\(Int(currentPoint.x)) Y:\(Int(currentPoint.y))"
            }

            let coordAttrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedSystemFont(ofSize: 9.0, weight: .medium),
                .foregroundColor: NSColor(calibratedRed: 0.0, green: 0.82, blue: 0.95, alpha: 0.90)
            ]
            (infoText as NSString).draw(at: CGPoint(x: 12, y: dividerY + 23), withAttributes: coordAttrs)

            let tipText = "按 C 复制"
            let tipAttrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 9.0, weight: .regular),
                .foregroundColor: NSColor(white: 1.0, alpha: 0.45)
            ]
            let tipSize = (tipText as NSString).size(withAttributes: tipAttrs)
            (tipText as NSString).draw(
                at: CGPoint(x: bounds.width - 12 - tipSize.width, y: dividerY + 23),
                withAttributes: tipAttrs
            )
        }
    }

    private func samplePixelColor(from image: CGImage, at point: CGPoint) -> NSColor {
        guard let dataProvider = image.dataProvider,
              let data = dataProvider.data,
              let ptr = CFDataGetBytePtr(data) else {
            return .white
        }

        let x = max(0, min(Int(point.x), image.width - 1))
        let y = max(0, min(Int(point.y), image.height - 1))
        let bytesPerRow = image.bytesPerRow
        let offset = y * bytesPerRow + x * 4

        let b = CGFloat(ptr[offset]) / 255.0
        let g = CGFloat(ptr[offset + 1]) / 255.0
        let r = CGFloat(ptr[offset + 2]) / 255.0
        let a = CGFloat(ptr[offset + 3]) / 255.0

        return NSColor(red: r, green: g, blue: b, alpha: a)
    }
}
