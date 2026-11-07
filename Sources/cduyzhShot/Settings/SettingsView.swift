import SwiftUI
import AppKit

private enum SettingsPane: String, CaseIterable, Identifiable {
    case screenshot, recording, hotkeys, cache, permissions, about

    var id: Self { self }

    var title: String {
        switch self {
        case .screenshot: return "截屏与剪贴板"
        case .recording: return "录屏与声音"
        case .hotkeys: return "快捷键"
        case .cache: return "缓存与清理"
        case .permissions: return "系统权限"
        case .about: return "关于与更新"
        }
    }

    var subtitle: String {
        switch self {
        case .screenshot: return "让每次截图，都恰好符合你的习惯。"
        case .recording: return "调整画面流畅度与声音录制。"
        case .hotkeys: return "常用操作，随手可达。"
        case .cache: return "查看临时文件占用，保持存储空间整洁。"
        case .permissions: return "管理截图、录屏和长截图所需的系统访问权限。"
        case .about: return "查看当前安装版本，以及每次更新带来的变化。"
        }
    }

    var symbol: String {
        switch self {
        case .screenshot: return "viewfinder.circle.fill"
        case .recording: return "record.circle.fill"
        case .hotkeys: return "command.circle.fill"
        case .cache: return "internaldrive.fill"
        case .permissions: return "checkmark.shield.fill"
        case .about: return "info.circle.fill"
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .screenshot:
            return LinearGradient(
                colors: [Color(red: 0.04, green: 0.52, blue: 1.0), Color(red: 0.0, green: 0.82, blue: 0.95)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .recording:
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.22, blue: 0.38), Color(red: 1.0, green: 0.54, blue: 0.40)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .hotkeys:
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.58, blue: 0.0), Color(red: 1.0, green: 0.80, blue: 0.25)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .cache:
            return LinearGradient(
                colors: [Color(red: 0.0, green: 0.78, blue: 0.55), Color(red: 0.20, green: 0.88, blue: 0.75)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .permissions:
            return LinearGradient(
                colors: [Color(red: 0.58, green: 0.28, blue: 0.98), Color(red: 0.78, green: 0.35, blue: 0.95)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .about:
            return LinearGradient(
                colors: [Color(red: 0.18, green: 0.42, blue: 0.86), Color(red: 0.45, green: 0.68, blue: 0.98)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }

    var color: Color {
        switch self {
        case .screenshot: return Color(red: 0.04, green: 0.52, blue: 1.0)
        case .recording: return Color(red: 1.0, green: 0.22, blue: 0.38)
        case .hotkeys: return Color(red: 1.0, green: 0.58, blue: 0.0)
        case .cache: return Color(red: 0.0, green: 0.78, blue: 0.55)
        case .permissions: return Color(red: 0.58, green: 0.28, blue: 0.98)
        case .about: return Color(red: 0.18, green: 0.42, blue: 0.86)
        }
    }
}

public struct SettingsView: View {
    @ObservedObject var prefs = UserPreferences.shared
    @ObservedObject var updateManager = UpdateManager.shared
    @State private var selectedPane: SettingsPane? = .screenshot
    @State private var currentCacheSizeText = CacheManager.shared.formattedCacheSize()
    @State private var cleanCacheFeedback = ""
    @State private var hasScreenRecording = Permissions.hasScreenRecordingPermission
    @State private var hasAccessibility = Permissions.hasAccessibilityPermission
    @State private var refreshFeedback = ""

    public init() {}

    public var body: some View {
        HStack(spacing: 0) {
            sidebar
            Divider()
            detail
        }
        .frame(minWidth: 740, idealWidth: 800, minHeight: 520, idealHeight: 600)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            refreshCacheSize()
            refreshPermissions()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            refreshPermissions()
            refreshCacheSize()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("cduyzhShot.settings.showAbout"))) { _ in
            selectedPane = .about
        }
        .onChange(of: selectedPane) { _, pane in
            if pane == .cache { refreshCacheSize() }
        }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 11) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.04, green: 0.52, blue: 1.0), Color(red: 0.0, green: 0.82, blue: 0.95)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 30, height: 30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color.white.opacity(0.35), lineWidth: 0.6)
                        )
                        .shadow(color: Color(red: 0.0, green: 0.65, blue: 0.95).opacity(0.3), radius: 6, x: 0, y: 2)

                    Image(systemName: "viewfinder")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text("iScreenshot")
                        .font(.system(size: 13, weight: .bold))
                    Text("偏好设置 · 极速截屏")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 22)

            List(SettingsPane.allCases, selection: $selectedPane) { pane in
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(pane.gradient)
                            .frame(width: 26, height: 26)
                            .overlay(
                                RoundedRectangle(cornerRadius: 7)
                                    .strokeBorder(Color.white.opacity(0.4), lineWidth: 0.6)
                            )
                            .shadow(color: pane.color.opacity(0.28), radius: 4, x: 0, y: 1.5)

                        Image(systemName: pane.symbol)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .accessibilityHidden(true)

                    Text(pane.title)
                        .font(.system(size: 13, weight: selectedPane == pane ? .semibold : .regular))
                }
                .padding(.vertical, 4)
                .tag(pane)
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
            .accessibilityLabel("设置分类")

            VStack(alignment: .leading, spacing: 4) {
                Text("版本 \(AppVersion.current.displayString)")
                    .font(.system(size: 11, weight: .medium))
                    .monospacedDigit()
                Text("SnapScreen")
                    .font(.system(size: 10))
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
        }
        .frame(width: 184)
        .background(.regularMaterial)
    }

    private var detail: some View {
        let pane = selectedPane ?? .screenshot
        return ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(pane.title)
                        .font(.system(size: 25, weight: .bold))
                        .accessibilityAddTraits(.isHeader)
                    Text(pane.subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, 2)

                switch pane {
                case .screenshot: screenshotSettings
                case .recording: recordingSettings
                case .hotkeys: hotkeySettings
                case .cache: cacheSettings
                case .permissions: permissionSettings
                case .about: aboutSettings
                }
            }
            .frame(maxWidth: 660, alignment: .leading)
            .padding(28)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .id(pane)
    }

    private var screenshotSettings: some View {
        VStack(spacing: 24) {
            SettingsCard(title: "长截图设置") {
                SettingsToggle("长截图纯净保存", subtitle: "长截图保持纯净画面，不附加任何品牌水印或推广条带。", isOn: $prefs.removeScrollWatermark)
            }

            SettingsCard(title: "剪贴板") {
                SettingsToggle("自动复制截图", subtitle: "完成后即可用 ⌘V 粘贴。", isOn: $prefs.autoCopyToClipboard)
                SettingsDivider()
                SettingsToggle("同时复制文件引用", subtitle: "兼容微信等支持文件粘贴的应用。", isOn: $prefs.copyAsTempFileToClipboard)
            }

            SettingsCard(title: "截图体验") {
                SettingsToggle("显示浮动缩略图", subtitle: "在屏幕右下角快速美化、贴图或查看文件。", isOn: $prefs.showFloatingThumbnail)
                SettingsDivider()
                SettingsToggle("显示取色放大镜", subtitle: "选择区域时，更精确地查看像素与颜色。", isOn: $prefs.showMagnifier)
                SettingsDivider()
                SettingsToggle("播放提示音", subtitle: "用于截图完成及录屏开始、结束。", isOn: $prefs.playCaptureSound)
            }

            SettingsCard(title: "截图美化与预设样式") {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .top, spacing: 14) {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.cyan)
                                Text("默认美化预设样式")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            Text("截屏美化或自动套用时的全局默认视觉风格。支持微调样机外框、精选背景、留白边距、圆角与立体阴影。")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: 8)

                        Button {
                            ScreenshotStudioWindowController.shared.openStudio(image: UIPreviewDelegate.sampleImage(), mode: .settings)
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "slider.horizontal.2.square")
                                    .font(.system(size: 12))
                                Text("编辑美化预设…")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.0, green: 0.75, blue: 0.95),
                                        Color(red: 0.0, green: 0.45, blue: 0.90)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                            .shadow(color: Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("编辑默认美化预设样式")
                        .help("打开美化画板并配置默认预设（仅保存设置，不写入剪贴板）")
                    }

                    // 参数微光胶囊列表
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Text("当前预设参数：")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)

                            // 样机外框状态胶囊 (重点高亮无外框 / 浏览器外框)
                            if prefs.studioConfig.mockup == .none {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 10))
                                    Text("无外框 (纯净无浏览器头)")
                                        .font(.system(size: 10.5, weight: .semibold))
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.cyan.opacity(0.12))
                                .foregroundColor(.cyan)
                                .clipShape(Capsule())
                                .overlay {
                                    Capsule().strokeBorder(Color.cyan.opacity(0.3), lineWidth: 0.8)
                                }
                            } else if prefs.studioConfig.mockup == .browserLight || prefs.studioConfig.mockup == .browserDark {
                                HStack(spacing: 4) {
                                    Image(systemName: "globe")
                                        .font(.system(size: 10))
                                    Text("浏览器外壳 (\(prefs.studioConfig.mockup.rawValue))")
                                        .font(.system(size: 10.5, weight: .medium))
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.orange.opacity(0.1))
                                .foregroundColor(.orange)
                                .clipShape(Capsule())
                                .overlay {
                                    Capsule().strokeBorder(Color.orange.opacity(0.25), lineWidth: 0.8)
                                }
                            } else {
                                HStack(spacing: 4) {
                                    Image(systemName: "macwindow")
                                        .font(.system(size: 10))
                                    Text(prefs.studioConfig.mockup.rawValue)
                                        .font(.system(size: 10.5, weight: .medium))
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.primary.opacity(0.06))
                                .foregroundColor(.primary)
                                .clipShape(Capsule())
                                .overlay {
                                    Capsule().strokeBorder(Color.primary.opacity(0.12), lineWidth: 0.8)
                                }
                            }

                            // 背景胶囊
                            HStack(spacing: 4) {
                                Image(systemName: "photo.stack")
                                    .font(.system(size: 10))
                                Text(prefs.studioConfig.background.rawValue)
                                    .font(.system(size: 10.5, weight: .medium))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.primary.opacity(0.06))
                            .foregroundColor(.primary)
                            .clipShape(Capsule())
                            .overlay {
                                Capsule().strokeBorder(Color.primary.opacity(0.12), lineWidth: 0.8)
                            }
                        }

                        HStack(spacing: 6) {
                            // 留白、圆角、阴影等宽数字胶囊
                            Text("留白 \(Int(prefs.studioConfig.padding)) px")
                                .font(.system(size: 10.5, design: .monospaced))
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2.5)
                                .background(Color.primary.opacity(0.04))
                                .foregroundColor(.secondary)
                                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))

                            Text("圆角 \(Int(prefs.studioConfig.cornerRadius)) px")
                                .font(.system(size: 10.5, design: .monospaced))
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2.5)
                                .background(Color.primary.opacity(0.04))
                                .foregroundColor(.secondary)
                                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))

                            Text("阴影: \(prefs.studioConfig.shadow.rawValue)")
                                .font(.system(size: 10.5))
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2.5)
                                .background(Color.primary.opacity(0.04))
                                .foregroundColor(.secondary)
                                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                        }
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.primary.opacity(0.025))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.8)
                    }

                    // 提示文案条
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text("在设置模式下调整任意参数后，点击「保存预设设置」（⌘S / ↵）即可永久生效，绝不影响系统剪贴板。")
                            .font(.system(size: 10.5))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(16)

                SettingsDivider()

                SettingsToggle(
                    "截图完成后自动套用美化预设",
                    subtitle: "开启后，每次截屏将自动应用上述美化预设并复制到剪贴板，无需在截图后手动进入美化面板。",
                    isOn: $prefs.autoBeautifyScreenshot
                )
            }

            SettingsCard(title: "图片保存") {
                SettingsToggle("截图完成时自动保存到文件", subtitle: "关闭时仅复制到剪贴板，使用 ⌘S 或另存为才保存到磁盘。", isOn: $prefs.autoSaveScreenshotToFile)
                SettingsDivider()
                VStack(alignment: .leading, spacing: 12) {
                    Text("图片格式")
                        .font(.system(size: 13, weight: .medium))
                    Picker("图片格式", selection: $prefs.screenshotFormat) {
                        Text("PNG · 无损").tag("PNG")
                        Text("JPEG · 更小文件").tag("JPEG")
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }
                .padding(16)
                SettingsDivider()
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("默认保存位置")
                            .font(.system(size: 13, weight: .medium))
                        Text(prefs.saveDirectoryPath)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .help(prefs.saveDirectoryPath)
                            .textSelection(.enabled)
                    }
                    Spacer(minLength: 4)
                    Button("更改…", action: selectSaveDirectory)
                        .accessibilityLabel("更改默认保存位置")
                }
                .padding(16)
            }
        }
    }

    private var recordingSettings: some View {
        VStack(spacing: 24) {
            SettingsCard(title: "声音") {
                SettingsToggle("录制系统声音", subtitle: "直接录制 Mac 播放的声音，无需额外驱动。", isOn: $prefs.captureSystemAudio)
                SettingsDivider()
                SettingsToggle("播放提示音", subtitle: "用于录屏开始、结束及截图完成。", isOn: $prefs.playCaptureSound)
            }

            SettingsCard(title: "画面") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("录屏帧率")
                        .font(.system(size: 13, weight: .medium))
                    Picker("录屏帧率", selection: $prefs.recordFPS) {
                        Text("30 FPS · 节省空间").tag(30)
                        Text("60 FPS · 更流畅").tag(60)
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }
                .padding(16)
            }
        }
    }

    private var hotkeySettings: some View {
        VStack(alignment: .leading, spacing: 24) {
            SettingsCard(title: "全局快捷键", footer: "快捷键在应用后台运行时同样可用。") {
                hotkeyRow("区域截图", symbol: "viewfinder", shortcut: prefs.hotkeyScreenshot.displayString)
                SettingsDivider()
                hotkeyRow("屏幕录制", symbol: "record.circle", shortcut: prefs.hotkeyRecording.displayString)
                SettingsDivider()
                hotkeyRow("滚动长截图", symbol: "rectangle.portrait", shortcut: prefs.hotkeyScroll.displayString)
                SettingsDivider()
                hotkeyRow("贴图到屏幕", symbol: "pin", shortcut: prefs.hotkeyPin.displayString)
            }

            Label {
                Text("截图时按 Enter 完成并复制，按 Esc 取消。")
                    .fixedSize(horizontal: false, vertical: true)
            } icon: {
                Image(systemName: "keyboard")
            }
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 4)
        }
    }

    private func hotkeyRow(_ title: String, symbol: String, shortcut: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .foregroundStyle(.secondary)
                .frame(width: 18)
                .accessibilityHidden(true)
            Text(title)
                .font(.system(size: 13))
            Spacer()
            Text(shortcut)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .padding(.horizontal, 11)
                .padding(.vertical, 6)
                .background(Color(nsColor: .quaternaryLabelColor).opacity(0.35), in: RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(Color.primary.opacity(0.07)))
        }
        .padding(16)
        .accessibilityElement(children: .combine)
    }

    private var cacheSettings: some View {
        VStack(spacing: 24) {
            SettingsCard(title: "存储空间") {
                HStack(spacing: 16) {
                    Image(systemName: "internaldrive")
                        .font(.system(size: 28, weight: .light))
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentCacheSizeText)
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                        Text("临时截图与录屏文件")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 8)
                    Button("清理缓存", action: clearCache)
                }
                .padding(18)

                if !cleanCacheFeedback.isEmpty {
                    SettingsDivider()
                    Label(cleanCacheFeedback, systemImage: "info.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
            }

            SettingsCard(title: "自动清理", footer: "超期文件会在后台清理；超过容量上限时，优先移除较早的文件。") {
                SettingsToggle("自动清理缓存", subtitle: "按保留时间和容量上限管理临时文件。", isOn: $prefs.autoCleanCacheEnabled)
                SettingsDivider()
                VStack(spacing: 16) {
                    Picker("保留时间", selection: $prefs.cacheRetentionDays) {
                        Text("1 天").tag(1)
                        Text("3 天").tag(3)
                        Text("7 天").tag(7)
                        Text("30 天").tag(30)
                    }
                    Picker("容量上限", selection: $prefs.maxCacheSizeMB) {
                        Text("200 MB").tag(200)
                        Text("500 MB").tag(500)
                        Text("1 GB").tag(1000)
                        Text("2 GB").tag(2000)
                    }
                }
                .pickerStyle(.menu)
                .disabled(!prefs.autoCleanCacheEnabled)
                .padding(16)
            }

            Button {
                NSWorkspace.shared.open(CacheManager.shared.cacheDirectory)
            } label: {
                Label("在访达中打开缓存文件夹", systemImage: "folder")
            }
            .buttonStyle(.link)
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
        }
    }

    private var permissionSettings: some View {
        VStack(alignment: .leading, spacing: 20) {
            SettingsCard(title: "系统访问权限", footer: "iScreenshot 严格遵循本地优先与隐私安全原则，所有屏幕取色、截屏与辅助功能调度均在本地独立完成，绝不上传任何屏幕内容。") {
                permissionRow(
                    "屏幕录制",
                    subtitle: "区域截图、屏幕取色与窗口捕获所必需。",
                    symbol: "rectangle.inset.filled.and.cursorarrow",
                    granted: hasScreenRecording,
                    type: "screen"
                )
                SettingsDivider()
                permissionRow(
                    "辅助功能",
                    subtitle: "用于智能识别窗口层级与长截图自动平滑滚动；未开启仍可手动滚动。",
                    symbol: "accessibility",
                    granted: hasAccessibility,
                    type: "accessibility"
                )
                SettingsDivider()
                HStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(hasScreenRecording && hasAccessibility ? Color.green : Color.orange)
                            .frame(width: 7, height: 7)
                        Text(refreshFeedback.isEmpty
                             ? (hasScreenRecording && hasAccessibility ? "所有权限已正常授权" : "部分权限尚未授予，功能可能受限")
                             : refreshFeedback)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        refreshPermissions(showFeedback: true)
                    } label: {
                        Label("重新检测", systemImage: "arrow.clockwise")
                            .font(.system(size: 12))
                    }
                    .controlSize(.small)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }

            SettingsCard(title: "权限生效与重启") {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .padding(.top, 1)
                        Text("在 macOS「系统设置 → 隐私与安全性」中授予权限后，系统可能需要重启应用方可更新权限上下文。若状态未及时同步，可先点击上方「重新检测」，或直接重新启动应用。")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    HStack {
                        Button {
                            Permissions.relaunchApp()
                        } label: {
                            Label("重新启动 iScreenshot", systemImage: "arrow.counterclockwise")
                        }
                        .controlSize(.regular)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func permissionRow(_ title: String, subtitle: String, symbol: String, granted: Bool, type: String) -> some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill((granted ? Color.green : Color.orange).opacity(0.12))
                Image(systemName: symbol)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(granted ? Color.green : Color.orange)
            }
            .frame(width: 38, height: 38)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 13, weight: .medium))
                    Spacer(minLength: 4)

                    HStack(spacing: 4) {
                        Circle()
                            .fill(granted ? Color.green : Color.orange)
                            .frame(width: 6, height: 6)
                        Text(granted ? "已授权" : "未开启")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(granted ? Color.green : Color.orange)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background((granted ? Color.green : Color.orange).opacity(0.1), in: Capsule())
                }

                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !granted {
                Button("打开系统设置") {
                    Permissions.openSystemSettings(for: type)
                }
                .controlSize(.small)
                .accessibilityLabel("在系统设置中授权\(title)")
                .padding(.leading, 4)
            }
        }
        .padding(16)
    }

    private var aboutSettings: some View {
        VStack(alignment: .leading, spacing: 24) {
            SettingsCard(title: "当前安装") {
                HStack(spacing: 14) {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 27, weight: .medium))
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 52, height: 52)
                        .background(Color.accentColor.opacity(0.09), in: RoundedRectangle(cornerRadius: 13))
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("iScreenshot")
                            .font(.system(size: 18, weight: .semibold))
                        Text("极速截屏、取色、录屏与滚动长截图")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(18)
                SettingsDivider()
                versionInfoRow("版本", value: AppVersion.current.fullDisplayString)
                SettingsDivider()
                versionInfoRow("版本发布日期", value: AppVersion.current.releaseDateDisplayString ?? "此版本尚无对应记录")
            }

            SettingsCard(title: "软件更新") {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("在线检查新版本")
                            .font(.system(size: 13, weight: .medium))
                        Text(updateManager.statusMessage)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 4)
                    if updateManager.isChecking {
                        ProgressView()
                            .controlSize(.small)
                            .frame(width: 70)
                    } else {
                        Button("检查更新") {
                            updateManager.checkForUpdates(isUserInitiated: true)
                        }
                    }
                }
                .padding(16)

                SettingsDivider()

                SettingsToggle("启动时自动检查更新", subtitle: "每次启动应用时静默检查更新，发现新版本时弹窗提示", isOn: $prefs.autoCheckForUpdates)
            }

            SettingsCard(title: "更新记录") {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("每次改动，清楚可见")
                            .font(.system(size: 13, weight: .medium))
                        Text("查看当前版本及历史版本的功能与修复。")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 4)
                    Button("查看更新记录…") {
                        ReleaseNotesWindowController.shared.show()
                    }
                    .accessibilityLabel("查看 iScreenshot 更新记录")
                }
                .padding(16)
            }
        }
    }

    private func versionInfoRow(_ title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 20) {
            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            Spacer(minLength: 4)
            Text(value)
                .font(.system(size: 12, weight: .medium))
                .monospacedDigit()
                .textSelection(.enabled)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .accessibilityElement(children: .combine)
    }

    private func refreshPermissions(showFeedback: Bool = false) {
        hasScreenRecording = Permissions.hasScreenRecordingPermission
        hasAccessibility = Permissions.hasAccessibilityPermission
        if showFeedback {
            refreshFeedback = hasScreenRecording && hasAccessibility
                ? "所有权限均已授权。"
                : "已检查。更改权限后可重新启动应用。"
        }
    }

    private func refreshCacheSize() {
        currentCacheSizeText = CacheManager.shared.formattedCacheSize()
    }

    private func clearCache() {
        CacheManager.shared.clearAllCache()
        refreshCacheSize()
        cleanCacheFeedback = CacheManager.shared.getCacheSizeBytes() == 0
            ? "缓存已清理。"
            : "已完成清理，部分文件暂时无法移除。"
    }

    private func selectSaveDirectory() {
        let panel = NSOpenPanel()
        panel.title = "选择默认保存位置"
        panel.prompt = "选择"
        panel.directoryURL = prefs.saveDirectoryURL
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        let completion: (NSApplication.ModalResponse) -> Void = { response in
            if response == .OK, let url = panel.url {
                prefs.saveDirectoryPath = url.path
            }
        }
        if let window = SettingsWindowController.shared.window {
            panel.beginSheetModal(for: window, completionHandler: completion)
        } else {
            panel.begin(completionHandler: completion)
        }
    }
}

private struct SettingsCard<Content: View>: View {
    let title: String
    let footer: String?
    let content: Content

    init(title: String, footer: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.footer = footer
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 6)
                .accessibilityAddTraits(.isHeader)
            VStack(spacing: 0) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(0.72))
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.regularMaterial)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(0.22), Color.white.opacity(0.04)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
            if let footer {
                Text(footer)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 6)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SettingsToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    init(_ title: String, subtitle: String, isOn: Binding<Bool>) {
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Toggle(title, isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .tint(Color(red: 0.04, green: 0.52, blue: 1.0))
                .accessibilityLabel(title)
                .accessibilityHint(subtitle)
        }
        .padding(16)
    }
}

private struct SettingsDivider: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.clear, Color.primary.opacity(0.08), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
            .padding(.horizontal, 16)
    }
}

public final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    public static let shared = SettingsWindowController()

    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "iScreenshot 设置"
        window.contentMinSize = NSSize(width: 740, height: 520)
        window.contentView = NSHostingView(rootView: SettingsView())
        window.isReleasedWhenClosed = false
        if !window.setFrameUsingName("cduyzhShot.Settings") {
            window.center()
        }
        window.setFrameAutosaveName("cduyzhShot.Settings")
        super.init(window: window)
        window.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func show() {
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    public func showAbout() {
        show()
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("cduyzhShot.settings.showAbout"), object: nil)
        }
    }

    public func windowWillClose(_ notification: Notification) {
        DispatchQueue.main.async {
            AppState.shared.registerAllHotkeys()
        }
    }
}
