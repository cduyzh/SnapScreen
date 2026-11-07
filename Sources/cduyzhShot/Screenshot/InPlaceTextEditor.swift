import AppKit

public protocol InPlaceTextEditorDelegate: AnyObject {
    func textEditorDidCommit(text: String, at point: CGPoint)
    func textEditorDidCommit(text: String, at point: CGPoint, fontSize: CGFloat, color: NSColor)
    func textEditorDidCancel()
}

public extension InPlaceTextEditorDelegate {
    func textEditorDidCommit(text: String, at point: CGPoint, fontSize: CGFloat, color: NSColor) {
        textEditorDidCommit(text: text, at: point)
    }
}

/// Canvas in-place live text editor with transparent backdrop and floating font-size capsule
public final class InPlaceTextEditor: NSTextField, NSTextFieldDelegate {
    public weak var editorDelegate: InPlaceTextEditorDelegate?
    private let originPoint: CGPoint
    private let maxCanvasBounds: CGRect
    private var isCommitting = false

    public private(set) var currentColor: NSColor = .systemRed
    public private(set) var currentFontSize: CGFloat = 16.0

    public static let availableFontSizes: [CGFloat] = [12, 14, 16, 20, 24, 32]
    private var fontSizeBar: NSView?

    public init(origin: CGPoint, color: NSColor, maxBounds: CGRect, initialFontSize: CGFloat = 16.0) {
        self.originPoint = origin
        self.maxCanvasBounds = maxBounds
        self.currentFontSize = initialFontSize
        self.currentColor = color
        super.init(frame: NSRect(x: origin.x, y: origin.y, width: 140, height: 32))

        self.delegate = self
        setupEditor(color: color)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupEditor(color: NSColor) {
        wantsLayer = true
        // 用户明确需求：打字时彻底去掉深色背景框与白边框，直接在画面上通透输入
        layer?.cornerRadius = 3
        layer?.backgroundColor = nil
        layer?.borderColor = nil
        layer?.borderWidth = 0
        layer?.shadowColor = nil
        layer?.shadowOpacity = 0

        isBordered = false
        drawsBackground = false
        focusRingType = .none
        isEditable = true
        isSelectable = true

        font = NSFont.systemFont(ofSize: currentFontSize, weight: .bold)
        applyTextColor(color)
        placeholderString = "输入文字..."

        updateFrameForContent()
    }

    public func updateColor(_ color: NSColor) {
        self.currentColor = color
        applyTextColor(color)
    }

    private func applyTextColor(_ color: NSColor) {
        // 用户明确需求：当选中白色标注颜色时，字体颜色为黑色；其它颜色保持原色
        let isWhite = AnnotationRenderer.isWhiteColor(color)
        self.textColor = isWhite ? NSColor.black : color
    }

    public func setFontSize(_ size: CGFloat) {
        currentFontSize = min(max(size, 10), 64)
        font = NSFont.systemFont(ofSize: currentFontSize, weight: .bold)
        updateFrameForContent()
        setupFontSizeBar()
    }

    public override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if window != nil {
            setupFontSizeBar()
            becomeFirstResponder()
        } else {
            fontSizeBar?.removeFromSuperview()
            fontSizeBar = nil
        }
    }

    public override func removeFromSuperview() {
        fontSizeBar?.removeFromSuperview()
        fontSizeBar = nil
        super.removeFromSuperview()
    }

    private func updateFrameForContent() {
        let text = stringValue.isEmpty ? (placeholderString ?? "输入文字...") : stringValue
        let font = self.font ?? NSFont.systemFont(ofSize: currentFontSize, weight: .bold)
        let attr: [NSAttributedString.Key: Any] = [.font: font]
        let size = (text as NSString).size(withAttributes: attr)

        let targetW = max(80, size.width + 16)
        let targetH = max(26, size.height + 6)

        // Clamp inside canvas bounds
        let maxX = maxCanvasBounds.maxX > 0 ? maxCanvasBounds.maxX : bounds.width
        let maxY = maxCanvasBounds.maxY > 0 ? maxCanvasBounds.maxY : bounds.height

        let clampedX = min(originPoint.x, maxX - targetW)
        let clampedY = min(originPoint.y, maxY - targetH)

        self.frame = NSRect(x: max(maxCanvasBounds.minX, clampedX), y: max(maxCanvasBounds.minY, clampedY), width: targetW, height: targetH)
        updateFontSizeBarPosition()
    }

    // MARK: - Floating Font Size Capsule
    private func setupFontSizeBar() {
        guard let parent = superview else { return }
        fontSizeBar?.removeFromSuperview()

        let bar = NSView()
        bar.wantsLayer = true
        bar.layer?.cornerRadius = 12
        bar.layer?.backgroundColor = NSColor(calibratedRed: 0.12, green: 0.15, blue: 0.22, alpha: 0.92).cgColor
        bar.layer?.borderColor = NSColor(white: 1.0, alpha: 0.20).cgColor
        bar.layer?.borderWidth = 0.5
        bar.layer?.shadowColor = NSColor.black.cgColor
        bar.layer?.shadowOpacity = 0.35
        bar.layer?.shadowRadius = 6
        bar.layer?.shadowOffset = CGSize(width: 0, height: 2)

        let stack = NSStackView()
        stack.orientation = .horizontal
        stack.spacing = 3
        stack.edgeInsets = NSEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        stack.alignment = .centerY
        stack.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: bar.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: bar.trailingAnchor),
            stack.topAnchor.constraint(equalTo: bar.topAnchor),
            stack.bottomAnchor.constraint(equalTo: bar.bottomAnchor)
        ])

        // 减小按钮
        let decBtn = makeSizeActionButton(title: "A-", tooltip: "缩小字号 (⌘-)") { [weak self] in
            guard let self = self else { return }
            let sizes = Self.availableFontSizes
            if let idx = sizes.lastIndex(where: { $0 < self.currentFontSize }) {
                self.setFontSize(sizes[idx])
            } else {
                self.setFontSize(max(10, self.currentFontSize - 2))
            }
        }
        stack.addArrangedSubview(decBtn)

        // 预设字号按钮组
        for s in Self.availableFontSizes {
            let isCurrent = (abs(s - currentFontSize) < 1.0)
            let sBtn = makeSizeNumberButton(size: s, isSelected: isCurrent) { [weak self] in
                self?.setFontSize(s)
            }
            stack.addArrangedSubview(sBtn)
        }

        // 增大按钮
        let incBtn = makeSizeActionButton(title: "A+", tooltip: "放大字号 (⌘+)") { [weak self] in
            guard let self = self else { return }
            let sizes = Self.availableFontSizes
            if let idx = sizes.firstIndex(where: { $0 > self.currentFontSize }) {
                self.setFontSize(sizes[idx])
            } else {
                self.setFontSize(min(64, self.currentFontSize + 2))
            }
        }
        stack.addArrangedSubview(incBtn)

        parent.addSubview(bar)
        self.fontSizeBar = bar
        updateFontSizeBarPosition()
    }

    private func updateFontSizeBarPosition() {
        guard let bar = fontSizeBar else { return }
        let barW: CGFloat = 210
        let barH: CGFloat = 24

        var barX = frame.minX
        var barY = frame.minY - barH - 8
        if barY < maxCanvasBounds.minY + 4 || barY < 10 {
            barY = frame.maxY + 8
        }
        barX = max(maxCanvasBounds.minX, min(barX, maxCanvasBounds.maxX - barW))
        bar.frame = CGRect(x: barX, y: barY, width: barW, height: barH)
    }

    private func makeSizeActionButton(title: String, tooltip: String, action: @escaping () -> Void) -> NSButton {
        let btn = ClosureButton(title: title, tooltip: tooltip, action: action)
        btn.wantsLayer = true
        btn.layer?.cornerRadius = 5
        btn.font = NSFont.systemFont(ofSize: 10, weight: .bold)
        btn.contentTintColor = NSColor(white: 0.92, alpha: 1.0)
        btn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            btn.widthAnchor.constraint(equalToConstant: 22),
            btn.heightAnchor.constraint(equalToConstant: 18)
        ])
        return btn
    }

    private func makeSizeNumberButton(size: CGFloat, isSelected: Bool, action: @escaping () -> Void) -> NSButton {
        let btn = ClosureButton(title: "\(Int(size))", tooltip: "\(Int(size)) pt", action: action)
        btn.wantsLayer = true
        btn.layer?.cornerRadius = 5
        btn.font = NSFont.monospacedDigitSystemFont(ofSize: 10, weight: isSelected ? .bold : .medium)
        if isSelected {
            btn.layer?.backgroundColor = NSColor(calibratedRed: 0.04, green: 0.52, blue: 1.0, alpha: 1.0).cgColor
            btn.contentTintColor = .white
        } else {
            btn.layer?.backgroundColor = nil
            btn.contentTintColor = NSColor(white: 0.75, alpha: 1.0)
        }
        btn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            btn.widthAnchor.constraint(equalToConstant: 22),
            btn.heightAnchor.constraint(equalToConstant: 18)
        ])
        return btn
    }

    public override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.modifierFlags.contains(.command) {
            if event.characters == "+" || event.characters == "=" {
                setFontSize(currentFontSize + 2)
                return true
            } else if event.characters == "-" {
                setFontSize(currentFontSize - 2)
                return true
            }
        }
        return super.performKeyEquivalent(with: event)
    }

    // MARK: - NSTextFieldDelegate
    public func controlTextDidChange(_ obj: Notification) {
        updateFrameForContent()
    }

    public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            // Return / Enter committed
            commitAndDismiss()
            return true
        } else if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
            // Escape pressed
            cancelAndDismiss()
            return true
        }
        return false
    }

    public func controlTextDidEndEditing(_ obj: Notification) {
        if !isCommitting {
            commitAndDismiss()
        }
    }

    public func commitAndDismiss() {
        guard !isCommitting else { return }
        isCommitting = true

        let text = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isEmpty {
            editorDelegate?.textEditorDidCommit(text: text, at: frame.origin, fontSize: currentFontSize, color: currentColor)
        } else {
            editorDelegate?.textEditorDidCancel()
        }
        fontSizeBar?.removeFromSuperview()
        fontSizeBar = nil
        removeFromSuperview()
    }

    public func cancelAndDismiss() {
        guard !isCommitting else { return }
        isCommitting = true
        editorDelegate?.textEditorDidCancel()
        fontSizeBar?.removeFromSuperview()
        fontSizeBar = nil
        removeFromSuperview()
    }
}

private final class ClosureButton: NSButton {
    private let actionClosure: () -> Void

    init(title: String, tooltip: String, action: @escaping () -> Void) {
        self.actionClosure = action
        super.init(frame: .zero)
        self.title = title
        self.toolTip = tooltip
        self.isBordered = false
        self.target = self
        self.action = #selector(clicked)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func clicked() {
        actionClosure()
    }

    public override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
}
