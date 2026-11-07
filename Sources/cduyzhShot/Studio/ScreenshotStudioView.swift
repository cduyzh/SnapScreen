import AppKit
import SwiftUI

final class StudioPresentation: ObservableObject {
    @Published var preview: NSImage?
    @Published var sourceSize = ""
    @Published var outputSize = ""
    @Published var isRendering = false
    @Published var isExporting = false
    @Published var message = ""
    @Published var mode: StudioMode = .capture
}

struct ScreenshotStudioView: View {
    @ObservedObject var model: ScreenshotStudioModel
    @ObservedObject var presentation: StudioPresentation
    @ObservedObject private var prefs = UserPreferences.shared
    let onChange: () -> Void
    let onSaveSettings: () -> Void
    let onCopy: () -> Void
    let onSave: () -> Void
    let onPin: () -> Void
    let onClose: () -> Void

    private var canExport: Bool {
        presentation.preview != nil && !presentation.isRendering && !presentation.isExporting
    }

    var body: some View {
        HStack(spacing: 0) {
            canvas
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Divider()
            inspector
                .frame(width: 330)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .onReceive(model.objectWillChange) { _ in onChange() }
        .background {
            if presentation.mode == .settings {
                Button("保存设置快捷键", action: onSaveSettings)
                    .keyboardShortcut("s", modifiers: .command)
                    .hidden()
            }
            Button("关闭", action: onClose)
                .keyboardShortcut(.cancelAction)
                .hidden()
        }
    }

    private var canvas: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Label("画板预览", systemImage: "photo")
                    .font(.system(size: 12, weight: .semibold))
                Spacer()
                if presentation.isRendering || presentation.isExporting {
                    ProgressView().controlSize(.small).scaleEffect(0.75)
                    Text(presentation.isExporting ? "正在保存…" : "正在实时渲染…")
                        .font(.system(size: 11))
                } else {
                    Text("原始尺寸 \(presentation.sourceSize)")
                        .font(.system(size: 11, design: .monospaced))
                }
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)

            GeometryReader { geometry in
                ZStack {
                    if let preview = presentation.preview {
                        Image(nsImage: preview)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .background {
                                if model.background == .transparent {
                                    TransparencyGrid()
                                }
                            }
                            .opacity(presentation.isRendering ? 0.75 : 1)
                            .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 8)
                            .accessibilityLabel("美化图片预览")
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 40, weight: .ultraLight))
                            Text(presentation.isRendering ? "正在准备流光画布…" : "暂无可预览内容")
                                .font(.system(size: 13))
                        }
                        .foregroundStyle(.tertiary)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 20)

            HStack(spacing: 6) {
                Image(systemName: presentation.mode == .settings ? "sparkles" : (presentation.message.isEmpty ? "sparkles" : "info.circle"))
                    .accessibilityHidden(true)
                if presentation.mode == .settings {
                    Text(presentation.message.isEmpty ? "\(presentation.outputSize) px · 效果预览（点击右下角「保存设置」即刻应用为全局默认预设）" : presentation.message)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .textSelection(.enabled)
                } else {
                    Text(presentation.message.isEmpty ? "\(presentation.outputSize) px · 高保真无损输出" : presentation.message)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .textSelection(.enabled)
                }
                Spacer()
                Text("按 Esc 退出")
            }
            .font(.system(size: 11))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .background(Color.primary.opacity(0.02))
    }

    private var inspector: some View {
        VStack(spacing: 0) {
            // 1. 顶部 Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(presentation.mode == .settings ? "配置默认美化预设" : "让截图更出彩")
                        .font(.system(size: 17, weight: .semibold))
                    Text(presentation.mode == .settings ? "调整并保存全局样式，后续截图与美化将默认套用此方案。" : "一点留白，恰到好处。")
                        .font(.system(size: 11.5))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: { model.reset() }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 12, weight: .medium))
                        .frame(width: 24, height: 24)
                        .background(Color.primary.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
                .buttonStyle(.plain)
                .help("恢复默认样式")
                .accessibilityLabel("恢复默认样式")
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 14)
            .disabled(presentation.isExporting)

            // 2. 自动套用卡片
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(presentation.mode == .settings ? "截图后默认自动套用美化" : "后续截图自动套用")
                            .font(.system(size: 12, weight: .medium))
                        Text(presentation.mode == .settings ? "开启后，后续每次截图将直接套用当前预设并自动复制" : "截图完成后直接应用当前美化方案")
                            .font(.system(size: 10.5))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: $prefs.autoBeautifyScreenshot)
                        .toggleStyle(.switch)
                        .controlSize(.small)
                        .labelsHidden()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.primary.opacity(0.035))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 14)

            // 3. 核心参数配置列表 (Plateau Card 流)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // A. 窗口外框
                    plateauCard(title: "窗口外框", symbol: "macwindow") {
                        VStack(alignment: .leading, spacing: 12) {
                            // 1. 样机外壳样式选择
                            VStack(alignment: .leading, spacing: 6) {
                                Text("样机样式")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)

                                CduyzhStudioMenu(
                                    selection: $model.mockup,
                                    options: StudioMockupStyle.allCases.map { ($0, $0.rawValue, $0.iconName) }
                                )
                            }

                            // 2. 样机顶栏内容 (按外壳类型自适应显示与解释)
                            if model.mockup == .browserLight || model.mockup == .browserDark {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text("浏览器地址栏网址")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        if !model.browserUrl.isEmpty {
                                            Button("清空") {
                                                model.browserUrl = ""
                                            }
                                            .buttonStyle(.plain)
                                            .font(.system(size: 10.5))
                                            .foregroundColor(.cyan)
                                        }
                                    }

                                    HStack(spacing: 6) {
                                            Image(systemName: "globe")
                                                .font(.system(size: 11))
                                                .foregroundColor(.secondary)
                                            TextField("输入网址或网页标题", text: $model.browserUrl)
                                                .textFieldStyle(.plain)
                                                .font(.system(size: 12))
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color(nsColor: .textBackgroundColor).opacity(0.8))
                                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                .strokeBorder(Color.primary.opacity(0.12), lineWidth: 0.8)
                                        }
                                        .accessibilityLabel("浏览器地址栏文案")


                                    Text("展示在模拟浏览器顶栏地址框内的网址或标题文案")
                                        .font(.system(size: 10.5))
                                        .foregroundColor(.secondary.opacity(0.8))
                                }
                            } else if model.mockup != .none {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text("窗口顶部标题")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        if !model.windowTitle.isEmpty {
                                            Button("清空") {
                                                model.windowTitle = ""
                                            }
                                            .buttonStyle(.plain)
                                            .font(.system(size: 10.5))
                                            .foregroundColor(.cyan)
                                        }
                                    }

                                    HStack(spacing: 6) {
                                        Image(systemName: "character.cursor.ibeam")
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                        TextField("留空则仅保留红黄绿控制按钮", text: $model.windowTitle)
                                            .textFieldStyle(.plain)
                                            .font(.system(size: 12))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color(nsColor: .textBackgroundColor).opacity(0.8))
                                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .strokeBorder(Color.primary.opacity(0.12), lineWidth: 0.8)
                                    }
                                    .accessibilityLabel("样机窗口标题")

                                    Text("显示在样机窗口顶部正中间的自定义标题文案（可留空）")
                                        .font(.system(size: 10.5))
                                        .foregroundColor(.secondary.opacity(0.8))
                                }
                            } else {
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 13))
                                        .foregroundColor(.cyan)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("已选用「无外框」纯净模式")
                                            .font(.system(size: 11.5, weight: .semibold))
                                            .foregroundColor(.primary)
                                        Text("不添加任何窗口头、红黄绿按钮或浏览器顶栏，仅保留纯净截图主体与精选背景。")
                                            .font(.system(size: 10.5))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(9)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.cyan.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .strokeBorder(Color.cyan.opacity(0.25), lineWidth: 0.8)
                                }
                            }
                        }
                    }

                    // B. 精选背景矩阵 (流光光晕选中态)
                    plateauCard(title: "精选背景", symbol: "square.stack.3d.up") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 10) {
                            ForEach(StudioBackgroundStyle.allCases) { style in
                                backgroundChoice(style)
                            }
                        }
                    }

                    // C. 构图参数 (等宽数值微调)
                    plateauCard(title: "构图参数", symbol: "slider.horizontal.3") {
                        VStack(spacing: 12) {
                            valueSlider("画布留白", value: $model.padding, range: 0...100)
                            valueSlider("圆角半径", value: $model.cornerRadius, range: 0...40)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("外层立体阴影")
                                    .font(.system(size: 11.5))
                                    .foregroundStyle(.secondary)
                                Picker("阴影", selection: $model.shadow) {
                                    ForEach(StudioShadowStyle.allCases) { Text($0.rawValue).tag($0) }
                                }
                                .pickerStyle(.segmented)
                                .labelsHidden()
                            }
                        }
                    }

                    // D. 画布比例
                    plateauCard(title: "画布比例", symbol: "aspectratio") {
                        VStack(alignment: .leading, spacing: 8) {
                            CduyzhStudioMenu(
                                selection: $model.aspectRatio,
                                options: [
                                    (.auto, "自适应 (保持原图画幅)", "viewfinder"),
                                    (.ratio16_9, "16:9 横屏宽屏", "rectangle"),
                                    (.ratio4_3, "4:3 经典画幅", "macwindow"),
                                    (.ratio1_1, "1:1 正方形社交", "square"),
                                    (.ratio9_16, "9:16 移动竖屏", "iphone"),
                                    (.ratio3_4, "3:4 手机图集", "newspaper")
                                ]
                            )

                            Text("自动适配信标比例，原图画幅无损完整呈现")
                                .font(.system(size: 10.5))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .disabled(presentation.isExporting)

            Divider()

            // 4. 底部动作区 (流光主按钮 + 次级按钮)
            VStack(spacing: 10) {
                if presentation.mode == .settings {
                    Button(action: onSaveSettings) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 13, weight: .semibold))
                            Text("保存预设设置")
                                .font(.system(size: 13, weight: .semibold))
                            Spacer()
                            Text("⌘S / ↵")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .opacity(0.85)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 28)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 4)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.0, green: 0.78, blue: 0.95), // 流光青
                                    Color(red: 0.0, green: 0.48, blue: 0.92)  // 深海蓝
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .shadow(color: Color(red: 0.0, green: 0.55, blue: 1.0).opacity(0.35), radius: 6, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.return, modifiers: [])
                    .disabled(!canExport)
                    .opacity(canExport ? 1.0 : 0.45)
                    .help("保存当前配置为全局默认截图美化预设（⌘S / ↵）")

                    HStack(spacing: 8) {
                        Button(action: {
                            model.apply(config: StudioConfig())
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("恢复默认预设")
                            }
                            .font(.system(size: 12))
                            .frame(maxWidth: .infinity, minHeight: 24)
                            .background(Color.primary.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .strokeBorder(Color.primary.opacity(0.12), lineWidth: 0.8)
                            }
                        }
                        .buttonStyle(.plain)
                        .help("将美化预设参数恢复为系统默认")

                        Button(action: onClose) {
                            Text("取消")
                                .font(.system(size: 12))
                                .frame(width: 60, height: 26)
                                .background(Color.primary.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                                        .strokeBorder(Color.primary.opacity(0.12), lineWidth: 0.8)
                                }
                        }
                        .buttonStyle(.plain)
                        .help("取消并关闭窗口（Esc）")
                    }
                } else {
                    Button(action: onCopy) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 13, weight: .semibold))
                            Text("完成并复制")
                                .font(.system(size: 13, weight: .semibold))
                            Spacer()
                            Text("↵")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .opacity(0.85)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 28)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 4)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.0, green: 0.78, blue: 0.95), // 流光青
                                    Color(red: 0.0, green: 0.48, blue: 0.92)  // 深海蓝
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .shadow(color: Color(red: 0.0, green: 0.55, blue: 1.0).opacity(0.35), radius: 6, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.return, modifiers: [])
                    .disabled(!canExport)
                    .opacity(canExport ? 1.0 : 0.45)

                    HStack(spacing: 8) {
                        Button(action: onSave) {
                            HStack(spacing: 5) {
                                Image(systemName: "square.and.arrow.down")
                                Text("另存为…")
                            }
                            .font(.system(size: 12))
                            .frame(maxWidth: .infinity, minHeight: 24)
                            .background(Color.primary.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .strokeBorder(Color.primary.opacity(0.12), lineWidth: 0.8)
                            }
                        }
                        .buttonStyle(.plain)
                        .keyboardShortcut("s", modifiers: .command)
                        .help("另存为 PNG 文件（⌘S）")

                        Button(action: onPin) {
                            Image(systemName: "pin")
                                .font(.system(size: 12))
                                .frame(width: 38, height: 26)
                                .background(Color.primary.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                                        .strokeBorder(Color.primary.opacity(0.12), lineWidth: 0.8)
                                }
                        }
                        .buttonStyle(.plain)
                        .keyboardShortcut("p", modifiers: .option)
                        .help("钉在屏幕上（⌥P）")
                        .accessibilityLabel("钉在屏幕上")
                    }
                    .disabled(!canExport)
                    .opacity(canExport ? 1.0 : 0.45)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.92))
    }

    private func plateauCard<Content: View>(title: String, symbol: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: symbol)
                .font(.system(size: 11.5, weight: .semibold))
                .foregroundStyle(.secondary)
            content()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.primary.opacity(0.025))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.8)
        }
    }

    private func valueSlider(_ title: String, value: Binding<CGFloat>, range: ClosedRange<CGFloat>) -> some View {
        VStack(spacing: 4) {
            HStack {
                Text(title)
                    .font(.system(size: 11.5))
                Spacer()
                Text("\(Int(value.wrappedValue)) px")
                    .font(.system(size: 11.5, design: .monospaced))
                    .foregroundColor(Color(red: 0.0, green: 0.65, blue: 0.95))
            }
            .foregroundStyle(.secondary)
            Slider(value: value, in: range)
                .accessibilityLabel(title)
                .accessibilityValue("\(Int(value.wrappedValue)) 像素")
        }
    }

    private func backgroundChoice(_ style: StudioBackgroundStyle) -> some View {
        let selected = model.background == style
        return Button { model.background = style } label: {
            VStack(spacing: 5) {
                ZStack {
                    backgroundSwatch(style)
                    if selected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.4), radius: 2)
                    }
                }
                .frame(height: 36)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(
                            selected ? Color(red: 0.0, green: 0.75, blue: 1.0) : Color.primary.opacity(0.12),
                            lineWidth: selected ? 2.0 : 0.8
                        )
                }
                .shadow(color: selected ? Color(red: 0.0, green: 0.75, blue: 1.0).opacity(0.45) : .clear, radius: 4)

                Text(shortName(style))
                    .font(.system(size: 10, weight: selected ? .semibold : .regular))
                    .foregroundStyle(selected ? Color(red: 0.0, green: 0.75, blue: 1.0) : Color.secondary)
                    .lineLimit(1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(style.rawValue)
        .accessibilityLabel(style.rawValue)
        .accessibilityValue(selected ? "已选择" : "未选择")
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }

    @ViewBuilder private func backgroundSwatch(_ style: StudioBackgroundStyle) -> some View {
        switch style {
        case .blur:
            LinearGradient(colors: [.gray.opacity(0.25), .blue.opacity(0.35), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .overlay { Image(systemName: "drop.halffull").foregroundStyle(.secondary) }
        case .gradientSonoma:
            LinearGradient(colors: [Color(red: 0.52, green: 0.24, blue: 0.78), Color(red: 0.95, green: 0.42, blue: 0.35), Color(red: 0.98, green: 0.72, blue: 0.38)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .gradientAurora:
            LinearGradient(colors: [Color(red: 0.06, green: 0.1, blue: 0.24), Color(red: 0.15, green: 0.72, blue: 0.55)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .gradientGraphite:
            LinearGradient(colors: [.gray.opacity(0.7), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .gradientOcean:
            LinearGradient(colors: [Color(red: 0.08, green: 0.22, blue: 0.62), Color(red: 0.12, green: 0.52, blue: 0.88)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .solidDark: Color(white: 0.08)
        case .solidWhite: Color(white: 0.98)
        case .transparent: TransparencyGrid()
        }
    }

    private func shortName(_ style: StudioBackgroundStyle) -> String {
        switch style {
        case .blur: return "随图"
        case .gradientSonoma: return "晨曦"
        case .gradientAurora: return "极光"
        case .gradientGraphite: return "钛金"
        case .gradientOcean: return "深蓝"
        case .solidDark: return "深空黑"
        case .solidWhite: return "纯净白"
        case .transparent: return "透明"
        }
    }
}

private struct TransparencyGrid: View {
    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(nsColor: .controlBackgroundColor)))
            let step: CGFloat = 10
            for row in 0..<Int(ceil(size.height / step)) {
                for column in 0..<Int(ceil(size.width / step)) where (row + column).isMultiple(of: 2) {
                    context.fill(Path(CGRect(x: CGFloat(column) * step, y: CGFloat(row) * step, width: step, height: step)), with: .color(.primary.opacity(0.06)))
                }
            }
        }
        .accessibilityHidden(true)
    }
}

private struct CduyzhStudioMenu<T: Hashable & Identifiable>: View {
    @Binding var selection: T
    let options: [(T, String, String)] // (tag, label, iconName)

    var body: some View {
        Menu {
            ForEach(options, id: \.0) { option in
                Button {
                    selection = option.0
                } label: {
                    HStack {
                        Label(option.1, systemImage: option.2)
                        if selection == option.0 {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                if let currentOption = options.first(where: { $0.0 == selection }) {
                    Image(systemName: currentOption.2)
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundColor(Color(red: 0.0, green: 0.68, blue: 0.95))
                        .frame(width: 14)
                    Text(currentOption.1)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                }
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.75))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.10), lineWidth: 0.8)
            }
        }
        .menuStyle(.borderlessButton)
    }
}
