import AppKit

public enum DesignIcons {
    public static func makeImage(size: CGFloat = 16, strokeWidth: CGFloat = 2.0, draw: @escaping (CGContext) -> Void) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            ctx.saveGState()
            // Map 0..24 viewBox to rect with SVG (top-left is (0,0))
            ctx.translateBy(x: 0, y: rect.height)
            ctx.scaleBy(x: 1.0, y: -1.0)
            let scale = rect.width / 24.0
            ctx.scaleBy(x: scale, y: scale)

            ctx.setLineWidth(strokeWidth)
            ctx.setLineCap(.round)
            ctx.setLineJoin(.round)
            ctx.setStrokeColor(NSColor.white.cgColor)
            ctx.setFillColor(NSColor.white.cgColor)

            draw(ctx)
            ctx.restoreGState()
            return true
        }
        image.isTemplate = true
        return image
    }

    /// 1. 选择光标: <path d="M3 3l7 18 3-7 7-3L3 3z"/>
    public static var select: NSImage {
        makeImage { ctx in
            ctx.beginPath()
            ctx.move(to: CGPoint(x: 3, y: 3))
            ctx.addLine(to: CGPoint(x: 10, y: 21))
            ctx.addLine(to: CGPoint(x: 13, y: 14))
            ctx.addLine(to: CGPoint(x: 20, y: 11))
            ctx.closePath()
            ctx.strokePath()
        }
    }

    /// 2. 矩形: <rect x="3" y="3" width="18" height="18" rx="2"/>
    public static var rect: NSImage {
        makeImage { ctx in
            let path = CGPath(roundedRect: CGRect(x: 3, y: 3, width: 18, height: 18), cornerWidth: 2, cornerHeight: 2, transform: nil)
            ctx.addPath(path)
            ctx.strokePath()
        }
    }

    /// 3. 圆形: <circle cx="12" cy="12" r="9"/>
    public static var circle: NSImage {
        makeImage { ctx in
            ctx.strokeEllipse(in: CGRect(x: 3, y: 3, width: 18, height: 18))
        }
    }

    /// 4. 直线: <line x1="5" y1="19" x2="19" y2="5"/>
    public static var line: NSImage {
        makeImage { ctx in
            ctx.beginPath()
            ctx.move(to: CGPoint(x: 5, y: 19))
            ctx.addLine(to: CGPoint(x: 19, y: 5))
            ctx.strokePath()
        }
    }

    /// 5. 箭头: <line x1="5" y1="19" x2="19" y2="5"/><polyline points="9 5 19 5 19 15"/>
    public static var arrow: NSImage {
        makeImage { ctx in
            ctx.beginPath()
            ctx.move(to: CGPoint(x: 5, y: 19))
            ctx.addLine(to: CGPoint(x: 19, y: 5))
            ctx.strokePath()

            ctx.beginPath()
            ctx.move(to: CGPoint(x: 9, y: 5))
            ctx.addLine(to: CGPoint(x: 19, y: 5))
            ctx.addLine(to: CGPoint(x: 19, y: 15))
            ctx.strokePath()
        }
    }

    /// 6. 马赛克: 网格小方块
    public static var mosaic: NSImage {
        makeImage(strokeWidth: 1.5) { ctx in
            let boxes: [CGRect] = [
                CGRect(x: 3, y: 3, width: 4.5, height: 4.5),
                CGRect(x: 10, y: 3, width: 4.5, height: 4.5),
                CGRect(x: 16.5, y: 3, width: 4.5, height: 4.5),
                CGRect(x: 6.5, y: 9.75, width: 4.5, height: 4.5),
                CGRect(x: 13.5, y: 9.75, width: 4.5, height: 4.5),
                CGRect(x: 3, y: 16.5, width: 4.5, height: 4.5),
                CGRect(x: 10, y: 16.5, width: 4.5, height: 4.5),
                CGRect(x: 16.5, y: 16.5, width: 4.5, height: 4.5)
            ]
            for b in boxes {
                ctx.fill(b)
            }
        }
    }

    /// 7. 步骤序号: <circle cx="12" cy="12" r="9"/><path d="M12 8v8M10 10l2-2"/>
    public static var stepBadge: NSImage {
        makeImage { ctx in
            ctx.strokeEllipse(in: CGRect(x: 3, y: 3, width: 18, height: 18))
            ctx.beginPath()
            ctx.move(to: CGPoint(x: 10, y: 10))
            ctx.addLine(to: CGPoint(x: 12, y: 8))
            ctx.addLine(to: CGPoint(x: 12, y: 16))
            ctx.strokePath()
        }
    }

    /// 8. 文字: <polyline points="4 7 4 4 20 4 20 7"/><line x1="12" y1="4" x2="12" y2="20"/><line x1="9" y1="20" x2="15" y2="20"/>
    public static var text: NSImage {
        makeImage { ctx in
            // 顶横与两端下垂折角
            ctx.beginPath()
            ctx.move(to: CGPoint(x: 4, y: 7))
            ctx.addLine(to: CGPoint(x: 4, y: 4))
            ctx.addLine(to: CGPoint(x: 20, y: 4))
            ctx.addLine(to: CGPoint(x: 20, y: 7))
            ctx.strokePath()

            // 竖干
            ctx.beginPath()
            ctx.move(to: CGPoint(x: 12, y: 4))
            ctx.addLine(to: CGPoint(x: 12, y: 20))
            ctx.strokePath()

            // 底座横衬线
            ctx.beginPath()
            ctx.move(to: CGPoint(x: 9, y: 20))
            ctx.addLine(to: CGPoint(x: 15, y: 20))
            ctx.strokePath()
        }
    }

    /// 9. 贴图: <path d="M16 4l4 4-8 8H8v-4l8-8z"/><path d="M18 2l4 4"/>
    public static var pin: NSImage {
        makeImage { ctx in
            ctx.beginPath()
            ctx.move(to: CGPoint(x: 16, y: 4))
            ctx.addLine(to: CGPoint(x: 20, y: 8))
            ctx.addLine(to: CGPoint(x: 12, y: 16))
            ctx.addLine(to: CGPoint(x: 8, y: 16))
            ctx.addLine(to: CGPoint(x: 8, y: 12))
            ctx.closePath()
            ctx.strokePath()

            ctx.beginPath()
            ctx.move(to: CGPoint(x: 18, y: 2))
            ctx.addLine(to: CGPoint(x: 22, y: 6))
            ctx.strokePath()

            // 钉针
            ctx.beginPath()
            ctx.move(to: CGPoint(x: 8, y: 16))
            ctx.addLine(to: CGPoint(x: 4, y: 20))
            ctx.strokePath()
        }
    }

    /// 10. 图片美化 (五角星): points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"
    public static var studioStar: NSImage {
        makeImage { ctx in
            let pts: [CGPoint] = [
                CGPoint(x: 12, y: 2),
                CGPoint(x: 15.09, y: 8.26),
                CGPoint(x: 22, y: 9.27),
                CGPoint(x: 17, y: 14.14),
                CGPoint(x: 18.18, y: 21.02),
                CGPoint(x: 12, y: 17.77),
                CGPoint(x: 5.82, y: 21.02),
                CGPoint(x: 7, y: 14.14),
                CGPoint(x: 2, y: 9.27),
                CGPoint(x: 8.91, y: 8.26)
            ]
            ctx.beginPath()
            ctx.move(to: pts[0])
            for pt in pts.dropFirst() {
                ctx.addLine(to: pt)
            }
            ctx.closePath()
            ctx.strokePath()
        }
    }

    /// 11. 滚动长截图: <rect x="6" y="2" width="12" height="20" rx="3"/><path d="M12 8v8M9 13l3 3 3-3"/>
    public static var scroll: NSImage {
        makeImage { ctx in
            let frameRect = CGRect(x: 6, y: 2, width: 12, height: 20)
            let p = CGPath(roundedRect: frameRect, cornerWidth: 3, cornerHeight: 3, transform: nil)
            ctx.addPath(p)
            ctx.strokePath()

            ctx.beginPath()
            ctx.move(to: CGPoint(x: 12, y: 8))
            ctx.addLine(to: CGPoint(x: 12, y: 16))
            ctx.strokePath()

            ctx.beginPath()
            ctx.move(to: CGPoint(x: 9, y: 13))
            ctx.addLine(to: CGPoint(x: 12, y: 16))
            ctx.addLine(to: CGPoint(x: 15, y: 13))
            ctx.strokePath()
        }
    }

    /// 12. 录屏 (双同心圆): <circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="4" fill="currentColor"/>
    public static var record: NSImage {
        makeImage { ctx in
            ctx.strokeEllipse(in: CGRect(x: 3, y: 3, width: 18, height: 18))
            ctx.fillEllipse(in: CGRect(x: 8, y: 8, width: 8, height: 8))
        }
    }

    /// 13. 撤销: <path d="M3 7v6h6"/><path d="M21 17a9 9 0 00-9-9 9 9 0 00-6 2.3L3 13"/>
    public static var undo: NSImage {
        makeImage { ctx in
            ctx.beginPath()
            ctx.move(to: CGPoint(x: 3, y: 7))
            ctx.addLine(to: CGPoint(x: 3, y: 13))
            ctx.addLine(to: CGPoint(x: 9, y: 13))
            ctx.strokePath()

            ctx.beginPath()
            ctx.move(to: CGPoint(x: 3, y: 13))
            ctx.addCurve(to: CGPoint(x: 21, y: 17), control1: CGPoint(x: 6, y: 8), control2: CGPoint(x: 14, y: 8))
            ctx.strokePath()
        }
    }

    /// 14. 另存为 (软盘): <path d="M19 21H5a2 2 0 01-2-2V5a2 2 0 012-2h11l5 5v11a2 2 0 01-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/>
    public static var saveDisk: NSImage {
        makeImage { ctx in
            // 外轮廓
            ctx.beginPath()
            ctx.move(to: CGPoint(x: 5, y: 21))
            ctx.addLine(to: CGPoint(x: 19, y: 21))
            ctx.addLine(to: CGPoint(x: 19, y: 7))
            ctx.addLine(to: CGPoint(x: 16, y: 3))
            ctx.addLine(to: CGPoint(x: 5, y: 3))
            ctx.closePath()
            ctx.strokePath()

            // 下方插签区
            ctx.beginPath()
            ctx.move(to: CGPoint(x: 7, y: 21))
            ctx.addLine(to: CGPoint(x: 7, y: 13))
            ctx.addLine(to: CGPoint(x: 17, y: 13))
            ctx.addLine(to: CGPoint(x: 17, y: 21))
            ctx.strokePath()

            // 上方保护滑片
            ctx.beginPath()
            ctx.move(to: CGPoint(x: 7, y: 3))
            ctx.addLine(to: CGPoint(x: 7, y: 8))
            ctx.addLine(to: CGPoint(x: 15, y: 8))
            ctx.addLine(to: CGPoint(x: 15, y: 3))
            ctx.strokePath()
        }
    }

    /// 15. 完成对勾: <polyline points="20 6 9 17 4 12"/>
    public static var checkmark: NSImage {
        makeImage(strokeWidth: 2.6) { ctx in
            ctx.beginPath()
            ctx.move(to: CGPoint(x: 4, y: 12))
            ctx.addLine(to: CGPoint(x: 9, y: 17))
            ctx.addLine(to: CGPoint(x: 20, y: 6))
            ctx.strokePath()
        }
    }

    /// 映射符号名到设计图高保真矢量图标
    public static func icon(for name: String) -> NSImage? {
        switch name {
        case "arrow.up.left", "select", "cursor":
            return select
        case "square", "rect":
            return rect
        case "circle", "ellipse":
            return circle
        case "line.diagonal", "line":
            return line
        case "arrow.right", "arrow":
            return arrow
        case "checkerboard.rectangle", "mosaic":
            return mosaic
        case "number.circle", "stepBadge":
            return stepBadge
        case "textformat", "text":
            return text
        case "pin.fill", "pin":
            return pin
        case "wand.and.stars", "studio", "star":
            return studioStar
        case "arrow.up.and.down.text.horizontal", "scroll":
            return scroll
        case "record.circle", "record":
            return record
        case "arrow.uturn.backward", "undo":
            return undo
        case "arrow.down.to.line", "save", "floppy":
            return saveDisk
        case "checkmark", "done":
            return checkmark
        default:
            return nil
        }
    }
}
