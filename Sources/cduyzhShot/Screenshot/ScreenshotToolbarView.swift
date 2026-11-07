import AppKit

public protocol ScreenshotToolbarDelegate: AnyObject {
    func toolbarDidSelectTool(_ tool: AnnotationTool)
    func toolbarDidSelectColor(_ color: NSColor)
    func toolbarDidClickPin()
    func toolbarDidClickStudio()
    func toolbarDidClickScrollCapture()
    func toolbarDidClickRecord()
    func toolbarDidClickUndo()
    func toolbarDidClickSave()
    func toolbarDidClickCopy()
    func toolbarDidClickCancel()
}

// MARK: - Dark Toolbar Icon Button
public final class DarkToolbarIconButton: NSButton {
    private var trackingAreaRef: NSTrackingArea?
    public var tooltipItem: ToolbarTooltipItem?
    public var onHoverChanged: ((_ isHovered: Bool, _ button: NSView) -> Void)?

    public var isToolActive: Bool = false {
        didSet {
            state = isToolActive ? .on : .off
            updateVisualState()
        }
    }
    public var normalTintColor: NSColor = NSColor(white: 0.94, alpha: 1.0) {
        didSet { updateVisualState() }
    }
    public var customBackgroundColor: NSColor? {
        didSet { updateVisualState() }
    }
    public var customBorderColor: NSColor? {
        didSet { updateVisualState() }
    }

    private var isHovered: Bool = false
    private var isPressed: Bool = false

    public override var isEnabled: Bool {
        didSet {
            if !isEnabled { onHoverChanged?(false, self) }
            updateVisualState()
            window?.invalidateCursorRects(for: self)
        }
    }

    public init(symbol: String, tooltip: String = "", width: CGFloat = 28, height: CGFloat = 28, pointSize: CGFloat = 14, weight: NSFont.Weight = .medium) {
        super.init(frame: .zero)
        setup(symbol: symbol, tooltip: tooltip, width: width, height: height, pointSize: pointSize, weight: weight)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup(symbol: String, tooltip: String, width: CGFloat, height: CGFloat, pointSize: CGFloat, weight: NSFont.Weight) {
        isBordered = false
        wantsLayer = true
        layer?.cornerRadius = 8
        layer?.masksToBounds = false
        toolTip = nil
        setAccessibilityLabel(tooltip.isEmpty ? symbol : tooltip)

        if let custom = DesignIcons.icon(for: symbol) {
            image = custom
            imagePosition = .imageOnly
            title = ""
        } else {
            let config = NSImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
            if let img = NSImage(systemSymbolName: symbol, accessibilityDescription: tooltip)?.withSymbolConfiguration(config) {
                image = img
                imagePosition = .imageOnly
                title = ""
            } else {
                title = symbol
            }
        }
        imageScaling = .scaleProportionallyDown

        updateVisualState()

        translatesAutoresizingMaskIntoConstraints = false
        let wc = widthAnchor.constraint(equalToConstant: width)
        wc.priority = .required
        let hc = heightAnchor.constraint(equalToConstant: height)
        hc.priority = .required
        NSLayoutConstraint.activate([wc, hc])
    }

    public override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let existing = trackingAreaRef {
            removeTrackingArea(existing)
        }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        trackingAreaRef = area
    }

    public override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        isHovered = true
        updateVisualState()
        if isEnabled { onHoverChanged?(true, self) }
    }

    public override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        isHovered = false
        updateVisualState()
        onHoverChanged?(false, self)
    }

    public override func resetCursorRects() {
        super.resetCursorRects()
        if isEnabled { addCursorRect(bounds, cursor: .pointingHand) }
    }

    public override func highlight(_ flag: Bool) {
        super.highlight(flag)
        isPressed = flag
        updateVisualState()
    }

    public static let aquaBlue = NSColor(calibratedRed: 0.04, green: 0.52, blue: 1.0, alpha: 1.0)
    public static let aquaCyan = NSColor(calibratedRed: 0.0, green: 0.82, blue: 0.95, alpha: 1.0)
    public static let aquaGreen = NSColor(calibratedRed: 0.19, green: 0.82, blue: 0.35, alpha: 1.0)
    public static let obsidianDark = NSColor(calibratedRed: 0.06, green: 0.08, blue: 0.10, alpha: 1.0)
    public static let normalMuted = NSColor(calibratedRed: 0.627, green: 0.698, blue: 0.776, alpha: 1.0)
    // 兼容向后兼容
    public static var nordicTeal: NSColor { aquaBlue }

    private func updateVisualState() {
        layer?.borderColor = nil
        layer?.borderWidth = 0
        layer?.shadowOpacity = 0
        alphaValue = isEnabled ? 1 : 0.35
        if isToolActive {
            layer?.backgroundColor = Self.aquaBlue.withAlphaComponent(isPressed ? 0.85 : 1.0).cgColor
            layer?.borderColor = NSColor.white.withAlphaComponent(0.35).cgColor
            layer?.borderWidth = 0.5
            layer?.shadowColor = Self.aquaBlue.cgColor
            layer?.shadowRadius = 8
            layer?.shadowOpacity = 0.45
            layer?.shadowOffset = CGSize(width: 0, height: 2)
            contentTintColor = .white
        } else if let customBg = customBackgroundColor {
            let bgAlpha = isEnabled && (isHovered || isPressed) ? min(1.0, customBg.alphaComponent + 0.08) : customBg.alphaComponent
            layer?.backgroundColor = customBg.withAlphaComponent(bgAlpha).cgColor
            layer?.borderColor = (customBorderColor ?? NSColor.white.withAlphaComponent(0.35)).cgColor
            layer?.borderWidth = 0.5
            if customBg == Self.aquaGreen || customBg == Self.aquaBlue {
                contentTintColor = .white
                layer?.shadowColor = customBg.cgColor
                layer?.shadowRadius = 8
                layer?.shadowOpacity = isHovered ? 0.50 : 0.35
                layer?.shadowOffset = CGSize(width: 0, height: 2)
            } else {
                contentTintColor = normalTintColor
            }
        } else if isEnabled && (isHovered || isPressed) {
            layer?.backgroundColor = NSColor(white: 1.0, alpha: isPressed ? 0.20 : 0.10).cgColor
            layer?.borderColor = NSColor(white: 1.0, alpha: 0.16).cgColor
            layer?.borderWidth = 0.5
            contentTintColor = .white
        } else {
            layer?.backgroundColor = nil
            contentTintColor = Self.normalMuted
        }
    }
}

// MARK: - Color Swatch & Palette Strip (6 Colors Inline)
public final class ColorIndicatorButton: NSButton {
    private var trackingAreaRef: NSTrackingArea?
    public var tooltipItem: ToolbarTooltipItem?
    public var onHoverChanged: ((_ isHovered: Bool, _ button: NSView) -> Void)?
    public var onColorChanged: ((NSColor) -> Void)?

    public static let paletteColors: [NSColor] = [
        NSColor(calibratedRed: 1.0, green: 0.231, blue: 0.188, alpha: 1.0), // 红 #FF3B30
        NSColor(calibratedRed: 1.0, green: 0.584, blue: 0.0, alpha: 1.0),   // 橙 #FF9500
        NSColor(calibratedRed: 0.204, green: 0.780, blue: 0.349, alpha: 1.0), // 绿 #34C759
        NSColor(calibratedRed: 0.0, green: 0.478, blue: 1.0, alpha: 1.0),   // 蓝 #007AFF
        NSColor(calibratedRed: 0.686, green: 0.322, blue: 0.871, alpha: 1.0), // 紫 #AF52DE
        NSColor.white                                                        // 白 #FFFFFF
    ]

    public var selectedColor: NSColor = NSColor(calibratedRed: 1.0, green: 0.231, blue: 0.188, alpha: 1.0) {
        didSet {
            setAccessibilityValue(colorName(for: selectedColor))
            needsDisplay = true
        }
    }

    public override var isEnabled: Bool {
        didSet {
            alphaValue = isEnabled ? 1 : 0.35
            if !isEnabled { onHoverChanged?(false, self) }
            window?.invalidateCursorRects(for: self)
        }
    }

    public init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        title = ""
        isBordered = false
        wantsLayer = true
        toolTip = nil
        setAccessibilityLabel("标注颜色")

        translatesAutoresizingMaskIntoConstraints = false
        // 6 个圆点 (13px) + 5 个间距 (5.5px) + 左右外边距 (6px*2) ≈ 118
        let wc = widthAnchor.constraint(equalToConstant: 118)
        wc.priority = .required
        let hc = heightAnchor.constraint(equalToConstant: 28)
        hc.priority = .required
        NSLayoutConstraint.activate([wc, hc])
    }

    private func isSameColor(_ c1: NSColor, _ c2: NSColor) -> Bool {
        guard let rgb1 = c1.usingColorSpace(.deviceRGB),
              let rgb2 = c2.usingColorSpace(.deviceRGB) else { return false }
        return abs(rgb1.redComponent - rgb2.redComponent) < 0.10 &&
               abs(rgb1.greenComponent - rgb2.greenComponent) < 0.10 &&
               abs(rgb1.blueComponent - rgb2.blueComponent) < 0.10
    }

    private func colorName(for color: NSColor) -> String {
        return PresetColor.all.first(where: { isSameColor($0.color, color) })?.name ?? "标注颜色"
    }

    public override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }

        let dotDiameter: CGFloat = 13.0
        let spacing: CGFloat = 5.5
        let startX: CGFloat = 6.0
        let centerY = bounds.midY

        for (idx, color) in Self.paletteColors.enumerated() {
            let cx = startX + CGFloat(idx) * (dotDiameter + spacing) + dotDiameter / 2.0
            let isSelected = isSameColor(color, selectedColor)

            if isSelected {
                // 白色高光双环与自发光
                ctx.saveGState()
                ctx.setShadow(offset: .zero, blur: 5, color: color.withAlphaComponent(0.65).cgColor)
                ctx.setStrokeColor(NSColor.white.cgColor)
                ctx.setLineWidth(1.8)
                let ringRect = CGRect(x: cx - 8.5, y: centerY - 8.5, width: 17, height: 17)
                ctx.strokeEllipse(in: ringRect)
                ctx.restoreGState()

                // 实体色块
                ctx.setFillColor(color.cgColor)
                let fillRect = CGRect(x: cx - dotDiameter / 2.0, y: centerY - dotDiameter / 2.0, width: dotDiameter, height: dotDiameter)
                ctx.fillEllipse(in: fillRect)
            } else {
                let fillRect = CGRect(x: cx - dotDiameter / 2.0, y: centerY - dotDiameter / 2.0, width: dotDiameter, height: dotDiameter)
                ctx.setFillColor(color.cgColor)
                ctx.fillEllipse(in: fillRect)

                if color == .white {
                    ctx.setStrokeColor(NSColor(white: 0.5, alpha: 0.6).cgColor)
                    ctx.setLineWidth(0.6)
                    ctx.strokeEllipse(in: fillRect)
                }
            }
        }
    }

    public override func mouseDown(with event: NSEvent) {
        guard isEnabled else { return }
        let location = convert(event.locationInWindow, from: nil)
        let dotDiameter: CGFloat = 13.0
        let spacing: CGFloat = 5.5
        let startX: CGFloat = 6.0

        for (idx, color) in Self.paletteColors.enumerated() {
            let cx = startX + CGFloat(idx) * (dotDiameter + spacing) + dotDiameter / 2.0
            if abs(location.x - cx) <= (dotDiameter / 2.0 + 3.0) {
                selectedColor = color
                onColorChanged?(color)
                return
            }
        }
    }

    public override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let existing = trackingAreaRef {
            removeTrackingArea(existing)
        }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        trackingAreaRef = area
    }

    public override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        guard isEnabled else { return }
        onHoverChanged?(true, self)
    }

    public override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        onHoverChanged?(false, self)
    }

    public override func resetCursorRects() {
        super.resetCursorRects()
        if isEnabled { addCursorRect(bounds, cursor: .pointingHand) }
    }
}

// MARK: - Recording Action
public final class RecordingToolbarButton: NSButton {
    private var trackingAreaRef: NSTrackingArea?
    public var tooltipItem: ToolbarTooltipItem?
    public var onHoverChanged: ((_ isHovered: Bool, _ button: NSView) -> Void)?
    private var isHovered = false
    private var isPressed = false

    public override var isEnabled: Bool {
        didSet {
            if !isEnabled { onHoverChanged?(false, self) }
            updateVisualState()
            window?.invalidateCursorRects(for: self)
        }
    }

    public init() {
        super.init(frame: .zero)
        title = ""
        isBordered = false
        wantsLayer = true
        layer?.cornerRadius = 8
        layer?.shadowColor = NSColor.systemRed.cgColor
        layer?.shadowOffset = .zero
        layer?.shadowOpacity = 0.04
        layer?.shadowRadius = 1.5
        image = DesignIcons.record
        imageScaling = .scaleProportionallyDown
        imagePosition = .imageOnly
        toolTip = nil
        setAccessibilityLabel("选区录屏")
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 34),
            heightAnchor.constraint(equalToConstant: 28)
        ])
        updateVisualState()
        startDynamicAnimations()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func startDynamicAnimations() {
        layer?.removeAnimation(forKey: "breathingShadowOpacity")
        layer?.removeAnimation(forKey: "breathingShadowRadius")
        guard !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion else { return }

        let opacity = CABasicAnimation(keyPath: "shadowOpacity")
        opacity.fromValue = 0.04
        opacity.toValue = 0.10
        let radius = CABasicAnimation(keyPath: "shadowRadius")
        radius.fromValue = 1.5
        radius.toValue = 2.5
        for animation in [opacity, radius] {
            animation.duration = 2.4
            animation.autoreverses = true
            animation.repeatCount = .infinity
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        }
        layer?.add(opacity, forKey: "breathingShadowOpacity")
        layer?.add(radius, forKey: "breathingShadowRadius")
    }

    public override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let area = trackingAreaRef { removeTrackingArea(area) }
        let area = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self, userInfo: nil)
        addTrackingArea(area)
        trackingAreaRef = area
    }

    public override func resetCursorRects() {
        super.resetCursorRects()
        if isEnabled { addCursorRect(bounds, cursor: .pointingHand) }
    }

    public override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        isHovered = true
        updateVisualState()
        if isEnabled { onHoverChanged?(true, self) }
    }

    public override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        isHovered = false
        updateVisualState()
        onHoverChanged?(false, self)
    }

    public override func highlight(_ flag: Bool) {
        super.highlight(flag)
        isPressed = flag
        updateVisualState()
    }

    private func updateVisualState() {
        alphaValue = isEnabled ? 1 : 0.35
        layer?.backgroundColor = isEnabled && (isHovered || isPressed)
            ? NSColor.systemRed.withAlphaComponent(isPressed ? 0.24 : 0.14).cgColor : nil
        contentTintColor = NSColor.systemRed.blended(withFraction: 0.18, of: .white)
    }
}

// MARK: - Screenshot Toolbar View
public final class ScreenshotToolbarView: NSView {
    public weak var delegate: ScreenshotToolbarDelegate?

    public private(set) var currentTool: AnnotationTool = .select
    public private(set) var currentColor: NSColor = PresetColor.red.color

    private var toolButtons: [AnnotationTool: DarkToolbarIconButton] = [:]
    private var colorIndicatorButton: ColorIndicatorButton?
    private var recordingButton: RecordingToolbarButton?

    private var tooltipShowWorkItem: DispatchWorkItem?
    private weak var hoveredTooltipButton: NSView?

    // 自定义快捷键提示与按钮共享辅助功能描述。
    public let tooltipBubble = ToolbarTooltipBubbleView()

    public override init(frame frameRect: NSRect) {
        super.init(frame: NSRect(x: 0, y: 0, width: 660, height: 38))
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        if let parent = superview {
            if tooltipBubble.superview != parent {
                tooltipBubble.removeFromSuperview()
                parent.addSubview(tooltipBubble)
            }
        } else {
            hideTooltip()
            tooltipBubble.removeFromSuperview()
        }
    }

    public func hideTooltip(animated: Bool = false) {
        tooltipShowWorkItem?.cancel()
        tooltipShowWorkItem = nil
        hoveredTooltipButton = nil
        tooltipBubble.hide(animated: animated)
    }

    private func handleButtonHover(isHovered: Bool, button: NSView, item: ToolbarTooltipItem) {
        if !isHovered {
            guard hoveredTooltipButton === button else { return }
            hideTooltip(animated: true)
            return
        }
        guard let container = superview ?? window?.contentView else { return }
        tooltipShowWorkItem?.cancel()
        hoveredTooltipButton = button
        if !tooltipBubble.isHidden {
            tooltipBubble.show(item: item, for: button, in: container)
            return
        }
        let work = DispatchWorkItem { [weak self, weak button, weak container] in
            guard let self, let button, let container,
                  self.hoveredTooltipButton === button else { return }
            self.tooltipBubble.show(item: item, for: button, in: container)
            self.tooltipShowWorkItem = nil
        }
        tooltipShowWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28, execute: work)
    }

    private func bindTooltip(button: NSView, item: ToolbarTooltipItem) {
        button.setAccessibilityLabel(item.title)
        let help = [item.shortcut, item.detail].compactMap { $0 }.joined(separator: "，")
        button.setAccessibilityHelp(help.isEmpty ? nil : help)
        if let btn = button as? DarkToolbarIconButton {
            btn.tooltipItem = item
            btn.onHoverChanged = { [weak self] isHovered, b in
                self?.handleButtonHover(isHovered: isHovered, button: b, item: item)
            }
        } else if let btn = button as? ColorIndicatorButton {
            btn.tooltipItem = item
            btn.onHoverChanged = { [weak self] isHovered, b in
                self?.handleButtonHover(isHovered: isHovered, button: b, item: item)
            }
        } else if let btn = button as? RecordingToolbarButton {
            btn.tooltipItem = item
            btn.onHoverChanged = { [weak self] isHovered, b in
                self?.handleButtonHover(isHovered: isHovered, button: b, item: item)
            }
        }
    }

    private func setupUI() {
        wantsLayer = true
        layer?.cornerRadius = 11
        layer?.masksToBounds = false
        layer?.shadowColor = NSColor.black.cgColor
        layer?.shadowOpacity = 0.24
        layer?.shadowRadius = 12
        layer?.shadowOffset = CGSize(width: 0, height: -3)
        appearance = NSAppearance(named: .darkAqua)

        // Frosted glass background
        let visualEffect = NSVisualEffectView(frame: bounds)
        visualEffect.material = .hudWindow
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.wantsLayer = true
        visualEffect.layer?.cornerRadius = 11
        visualEffect.layer?.masksToBounds = true
        visualEffect.layer?.borderColor = NSColor(white: 1.0, alpha: 0.14).cgColor
        visualEffect.layer?.borderWidth = 0.5
        visualEffect.autoresizingMask = [.width, .height]
        addSubview(visualEffect)

        let stack = NSStackView()
        stack.orientation = .horizontal
        stack.alignment = .centerY
        stack.spacing = 4
        stack.edgeInsets = NSEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Cluster 1: Core Annotation Tools (从左到右完全对齐设计图：选择、矩形、圆形、直线、箭头、马赛克、序号、文字)
        let tools: [(AnnotationTool, String, ToolbarTooltipItem)] = [
            (.select, "arrow.up.left", ToolbarTooltipItem(title: "选择与调整", shortcut: "0")),
            (.rect, "square", ToolbarTooltipItem(title: "矩形", shortcut: "1")),
            (.ellipse, "circle", ToolbarTooltipItem(title: "圆形", shortcut: "2")),
            (.line, "line.diagonal", ToolbarTooltipItem(title: "直线")),
            (.arrow, "arrow.right", ToolbarTooltipItem(title: "箭头", shortcut: "3")),
            (.mosaic, "checkerboard.rectangle", ToolbarTooltipItem(title: "马赛克", shortcut: "6")),
            (.stepBadge, "number.circle", ToolbarTooltipItem(title: "序号", shortcut: "8")),
            (.text, "textformat", ToolbarTooltipItem(title: "文字", shortcut: "7"))
        ]

        for (tool, symbol, tipItem) in tools {
            let btn = DarkToolbarIconButton(symbol: symbol)
            btn.target = self
            btn.action = #selector(toolButtonClicked(_:))
            bindTooltip(button: btn, item: tipItem)
            toolButtons[tool] = btn
            stack.addArrangedSubview(btn)
        }
        // 初始激活选择工具
        toolButtons[.select]?.isToolActive = true

        stack.addArrangedSubview(createDivider())

        // Cluster 2: 调色板 (6 色平铺微圆点，完全对齐设计图)
        let colorIndicator = ColorIndicatorButton()
        colorIndicator.selectedColor = currentColor
        colorIndicator.target = self
        colorIndicator.action = #selector(colorIndicatorClicked)
        colorIndicator.onColorChanged = { [weak self] newColor in
            self?.currentColor = newColor
            self?.delegate?.toolbarDidSelectColor(newColor)
        }
        bindTooltip(button: colorIndicator, item: ToolbarTooltipItem(title: "标注颜色", shortcut: "点击切换"))
        self.colorIndicatorButton = colorIndicator
        stack.addArrangedSubview(colorIndicator)

        stack.addArrangedSubview(createDivider())

        // Cluster 3: Special Capture Actions (Pin, Studio, Scroll Capture, and Dynamic Recording)
        let pinBtn = DarkToolbarIconButton(symbol: "pin.fill")
        pinBtn.target = self
        pinBtn.action = #selector(pinClicked)
        bindTooltip(button: pinBtn, item: ToolbarTooltipItem(title: "钉在屏幕上", shortcut: "⌥P"))
        stack.addArrangedSubview(pinBtn)

        let studioBtn = DarkToolbarIconButton(symbol: "wand.and.stars")
        studioBtn.target = self
        studioBtn.action = #selector(studioClicked)
        bindTooltip(button: studioBtn, item: ToolbarTooltipItem(title: "图片美化", shortcut: "E"))
        stack.addArrangedSubview(studioBtn)

        let scrollBtn = DarkToolbarIconButton(symbol: "arrow.up.and.down.text.horizontal")
        scrollBtn.target = self
        scrollBtn.action = #selector(scrollClicked)
        bindTooltip(button: scrollBtn, item: ToolbarTooltipItem(title: "滚动长截图", shortcut: "⌥S"))
        stack.addArrangedSubview(scrollBtn)

        // DYNAMIC RECORDING BUTTON
        let recBtn = RecordingToolbarButton()
        recBtn.target = self
        recBtn.action = #selector(recordClicked)
        bindTooltip(button: recBtn, item: ToolbarTooltipItem(title: "选区录屏", shortcut: "R"))
        self.recordingButton = recBtn
        stack.addArrangedSubview(recBtn)

        stack.addArrangedSubview(createDivider())

        // Cluster 4: History & Output Tools (Undo, Save As, and Done —— 严格还原设计图结构)
        let undoBtn = DarkToolbarIconButton(symbol: "arrow.uturn.backward")
        undoBtn.target = self
        undoBtn.action = #selector(undoClicked)
        bindTooltip(button: undoBtn, item: ToolbarTooltipItem(title: "撤销", shortcut: "⌘Z"))
        stack.addArrangedSubview(undoBtn)

        let saveBtn = DarkToolbarIconButton(symbol: "arrow.down.to.line")
        saveBtn.normalTintColor = DarkToolbarIconButton.normalMuted
        saveBtn.target = self
        saveBtn.action = #selector(saveClicked)
        bindTooltip(button: saveBtn, item: ToolbarTooltipItem(title: "另存为...", shortcut: "⌘S"))
        stack.addArrangedSubview(saveBtn)

        // 完成操作使用 Neo-Aqua Glass 流光翠绿（#30D158），提供高辨识度的视觉收敛重心与通透清脆质感。
        let doneBtn = DarkToolbarIconButton(symbol: "checkmark", width: 34, height: 28, pointSize: 14, weight: .bold)
        doneBtn.normalTintColor = .white
        doneBtn.customBackgroundColor = DarkToolbarIconButton.aquaGreen
        doneBtn.identifier = NSUserInterfaceItemIdentifier("doneAndCopyButton")
        doneBtn.target = self
        doneBtn.action = #selector(copyClicked)
        bindTooltip(button: doneBtn, item: ToolbarTooltipItem(title: "完成并复制", shortcut: "Enter"))
        stack.addArrangedSubview(doneBtn)
    }

    private func createDivider() -> NSView {
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 8),
            container.heightAnchor.constraint(equalToConstant: 26)
        ])

        let line = NSView()
        line.wantsLayer = true
        line.layer?.backgroundColor = NSColor(white: 1.0, alpha: 0.13).cgColor
        line.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(line)

        NSLayoutConstraint.activate([
            line.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            line.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            line.widthAnchor.constraint(equalToConstant: 0.5),
            line.heightAnchor.constraint(equalToConstant: 18)
        ])
        return container
    }

    @objc private func toolButtonClicked(_ sender: DarkToolbarIconButton) {
        hideTooltip(animated: false)
        var selectedItem: AnnotationTool = .select
        for (tool, btn) in toolButtons {
            if btn == sender {
                if currentTool == tool && tool != .select {
                    selectedItem = .select
                } else {
                    selectedItem = tool
                }
            }
        }
        currentTool = selectedItem
        for (tool, btn) in toolButtons {
            btn.isToolActive = (tool == currentTool)
        }
        delegate?.toolbarDidSelectTool(currentTool)
    }

    @objc private func colorIndicatorClicked() {
        hideTooltip(animated: false)
        // 用户明确需求：平铺调色板直接点击切换颜色，下方无需再弹出颜色列表
    }

    private func showColorPalettePopover(relativeTo button: NSButton) {
        let popover = NSPopover()
        popover.behavior = .transient
        popover.appearance = NSAppearance(named: .darkAqua)

        let vc = NSViewController()
        let container = NSView(frame: NSRect(x: 0, y: 0, width: 226, height: 40))
        container.wantsLayer = true
        container.layer?.cornerRadius = 8
        container.layer?.backgroundColor = NSColor(calibratedWhite: 0.14, alpha: 0.98).cgColor

        let stack = NSStackView(frame: container.bounds.insetBy(dx: 8, dy: 6))
        stack.orientation = .horizontal
        stack.spacing = 7
        stack.alignment = .centerY

        for preset in PresetColor.all {
            let colorBtn = NSButton(frame: NSRect(x: 0, y: 0, width: 17, height: 17))
            colorBtn.isBordered = false
            colorBtn.wantsLayer = true
            colorBtn.layer?.cornerRadius = 8.5
            colorBtn.layer?.backgroundColor = preset.color.cgColor
            colorBtn.layer?.borderColor = (preset.color == currentColor) ? NSColor.white.cgColor : NSColor(white: 1.0, alpha: 0.35).cgColor
            colorBtn.layer?.borderWidth = (preset.color == currentColor) ? 2.5 : 0.8
            colorBtn.toolTip = preset.name
            colorBtn.setAccessibilityLabel(preset.name)
            colorBtn.state = preset.color == currentColor ? .on : .off
            colorBtn.target = self
            colorBtn.action = #selector(paletteColorSelected(_:))
            colorBtn.identifier = NSUserInterfaceItemIdentifier(preset.name)
            colorBtn.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                colorBtn.widthAnchor.constraint(equalToConstant: 17),
                colorBtn.heightAnchor.constraint(equalToConstant: 17)
            ])
            stack.addArrangedSubview(colorBtn)
        }

        container.addSubview(stack)
        vc.view = container
        popover.contentViewController = vc
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
    }

    @objc private func paletteColorSelected(_ sender: NSButton) {
        if let name = sender.identifier?.rawValue,
           let preset = PresetColor.all.first(where: { $0.name == name }) {
            currentColor = preset.color
            colorIndicatorButton?.selectedColor = currentColor
            delegate?.toolbarDidSelectColor(currentColor)
        }
    }

    @objc private func pinClicked() {
        hideTooltip(animated: false)
        delegate?.toolbarDidClickPin()
    }

    @objc private func studioClicked() {
        hideTooltip(animated: false)
        delegate?.toolbarDidClickStudio()
    }

    @objc private func scrollClicked() {
        hideTooltip(animated: false)
        delegate?.toolbarDidClickScrollCapture()
    }

    @objc private func recordClicked() {
        hideTooltip(animated: false)
        delegate?.toolbarDidClickRecord()
    }

    @objc private func undoClicked() {
        hideTooltip(animated: false)
        delegate?.toolbarDidClickUndo()
    }

    @objc private func saveClicked() {
        hideTooltip(animated: false)
        delegate?.toolbarDidClickSave()
    }

    @objc private func copyClicked() {
        hideTooltip(animated: false)
        delegate?.toolbarDidClickCopy()
    }

    @objc private func cancelClicked() {
        hideTooltip(animated: false)
        delegate?.toolbarDidClickCancel()
    }

    public func selectTool(_ tool: AnnotationTool) {
        if let btn = toolButtons[tool] {
            toolButtonClicked(btn)
        }
    }
}
