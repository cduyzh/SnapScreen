import SwiftUI
import AppKit

public struct PaywallView: View {
    @ObservedObject private var licenseManager = LicenseManager.shared
    @ObservedObject private var authManager = AuthSessionManager.shared

    @State private var selectedTier: LicenseTier = .yearly
    @State private var selectedChannel: PaymentChannel = .wechat
    @State private var checkoutState: PaywallCheckoutState = .idle
    @State private var showManualTokenInput: Bool = false
    @State private var manualToken: String = ""
    @State private var manualTokenError: String? = nil

    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isCodeFocused: Bool
    @State private var showEmailAuthSheet: Bool = false
    @State private var inputEmail: String = ""
    @State private var inputCode: String = ""
    @State private var isSendingCode: Bool = false
    @State private var authErrorMessage: String? = nil
    @State private var codeSentSuccess: Bool = false
    @State private var countdownSeconds: Int = 0
    @State private var countdownTimer: Timer? = nil

    @State private var activeOrderNo: String? = nil
    @State private var activeQrImage: NSImage? = nil
    @State private var activeQrRawText: String? = nil
    @State private var pollingTimer: Timer? = nil

    var onDismiss: (() -> Void)?

    public init(onDismiss: (() -> Void)? = nil) {
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            // 背景渐变：Quiet Native / Ink Signal
            Color(NSColor.windowBackgroundColor)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 顶部导航栏 / 关闭按钮
                headerBar

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // 1. Pro 品牌标题与当前试用状态
                        heroSection

                        // 2. 三套定价方案选择卡片
                        plansSection

                        // 3. 核心功能权益清单 (为什么升级 Pro)
                        featuresGrid

                        // 4. 国内支付结账区域 (微信/支付宝 + 动态二维码)
                        checkoutSection

                        // 5. 底部保障与手动兑换
                        footerSection
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 24)
                }
            }

            // 手动激活弹窗
            if showManualTokenInput {
                manualTokenOverlay
            }

            // 邮箱登录验证弹窗
            if showEmailAuthSheet {
                emailAuthOverlay
            }
        }
        .frame(width: 660, height: 720)
        .onAppear {
            if let email = authManager.currentEmail {
                inputEmail = email
            }
            startCheckoutFlow()
        }
        .onDisappear {
            stopPolling()
            countdownTimer?.invalidate()
            countdownTimer = nil
        }
    }

    // MARK: - 1. 顶部栏
    private var headerBar: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundColor(.accentColor)
                Text("SnapScreen Pro")
                    .font(.system(size: 13, weight: .bold))
            }

            Spacer()

            // 登录状态或邮箱账号
            Button {
                showEmailAuthSheet = true
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: authManager.isLoggedIn ? "person.crop.circle.fill" : "person.crop.circle")
                    Text(authManager.currentEmail ?? "邮箱登录 / 关联设备")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.primary.opacity(0.04))
                .cornerRadius(6)
            }
            .buttonStyle(.plain)

            // 关闭按钮
            Button {
                onDismiss?()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color.secondary.opacity(0.7))
            }
            .buttonStyle(.plain)
            .padding(.leading, 8)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 10)
    }

    // MARK: - 2. Hero 区域
    private var heroSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.cyan.opacity(0.2), Color.blue.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                Image(systemName: "crown.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.78, blue: 0.28), Color(red: 1.0, green: 0.52, blue: 0.12)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            Text("解锁 SnapScreen 全部专业创作特权")
                .font(.system(size: 18, weight: .bold))

            // 试用状态提示胶囊
            if licenseManager.currentTier == .trial {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("当前处于 7 天免费试用期 · 剩余 \(licenseManager.trialDaysRemaining) 天")
                        .font(.system(size: 11, weight: .medium).monospacedDigit())
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.12))
                .cornerRadius(12)
            } else if licenseManager.isPro {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.cyan)
                    Text("您已是 SnapScreen Pro 尊贵用户 (\(licenseManager.currentTier.title))")
                        .font(.system(size: 11, weight: .medium))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.cyan.opacity(0.12))
                .cornerRadius(12)
            } else {
                Text("专为高效工作者打造：去官方水印、外壳自定义、极速无损导出")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - 3. 定价方案
    private var plansSection: some View {
        HStack(spacing: 12) {
            ForEach(PaywallPlanItem.standardPlans) { plan in
                planCard(plan: plan)
            }
        }
    }

    private func planCard(plan: PaywallPlanItem) -> some View {
        let isSelected = selectedTier == plan.id
        return Button {
            selectedTier = plan.id
            startCheckoutFlow()
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                // 顶部标签 (如：立省 52%)
                HStack {
                    Text(plan.title)
                        .font(.system(size: 13, weight: .bold))
                    Spacer()
                    if let badge = plan.badge {
                        Text(badge)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(plan.isPopular ? Color.cyan : Color.orange)
                            .cornerRadius(4)
                    }
                }

                // 价格展示
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(plan.priceDisplay)
                        .font(.system(size: 22, weight: .bold).monospacedDigit())
                        .foregroundColor(isSelected ? .cyan : .primary)
                    Text(plan.periodNote)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }

                Divider().opacity(0.4)

                // 核心权益点
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(plan.features.prefix(3), id: \.self) { feat in
                        HStack(alignment: .top, spacing: 4) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(isSelected ? .cyan : .secondary)
                                .padding(.top, 2)
                            Text(feat)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.cyan.opacity(0.06) : Color(NSColor.controlBackgroundColor).opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.cyan : Color.primary.opacity(0.08), lineWidth: isSelected ? 1.6 : 0.8)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 4. 权益对比与特色展示
    private var featuresGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Pro 会员专享核心价值")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                featureTile(
                    icon: "scroll.fill",
                    title: "长截图无水印",
                    desc: "强制官方 Logo 与网址水印瞬间解除，拼接导出纯净长图"
                )

                featureTile(
                    icon: "globe",
                    title: "浏览器外壳文案定制",
                    desc: "自由改写美化外壳 URL 与标题，彻底去除官方预设文案"
                )

                featureTile(
                    icon: "desktopcomputer.and.arrow.down",
                    title: "多设备授权绑机",
                    desc: "支持个人 2-3 台 Mac 绑定，换机自由管理解绑"
                )
            }
        }
        .padding(.vertical, 4)
    }

    private func featureTile(icon: String, title: String, desc: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(.accentColor)
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
            }
            Text(desc)
                .font(.system(size: 10.5))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.4))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
        )
    }

    // MARK: - 5. 结账区 (国内支付渠道 + 二维码)
    private var checkoutSection: some View {
        VStack(spacing: 14) {
            // 支付渠道切换标签
            HStack(spacing: 16) {
                ForEach(PaymentChannel.allCases) { channel in
                    Button {
                        selectedChannel = channel
                        startCheckoutFlow()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: channel.iconName)
                            Text(channel.title)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .foregroundColor(selectedChannel == channel ? .white : .primary)
                        .background(
                            selectedChannel == channel ? Color(channel.brandColor) : Color.primary.opacity(0.05)
                        )
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }

            // 二维码展示卡片
            VStack(spacing: 10) {
                switch checkoutState {
                case .requestingOrder:
                    VStack(spacing: 10) {
                        ProgressView()
                            .scaleEffect(0.9)
                        Text("正在生成安全支付二维码…")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 170, height: 170)

                case .awaitingPayment(_, _, _):
                    if let qr = activeQrImage {
                        VStack(spacing: 8) {
                            Image(nsImage: qr)
                                .resizable()
                                .interpolation(.none)
                                .frame(width: 150, height: 150)
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                                )

                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 6, height: 6)
                                Text("打开\(selectedChannel.title) 扫一扫完成支付")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                case .success(let tier):
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                        Text("支付成功！已自动激活 \(tier.title)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.green)
                        Text("长截图去水印与美化文案定制已全部解锁。")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 170)

                case .failure(let err):
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.orange)
                        Text(err)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        Button("重试生成") {
                            startCheckoutFlow()
                        }
                        .font(.system(size: 11))
                    }
                    .frame(height: 170)

                case .idle:
                    EmptyView()
                }
            }
            .padding(14)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 0.8)
            )
        }
    }

    // MARK: - 6. 底部保障与手动兑换
    private var footerSection: some View {
        HStack {
            HStack(spacing: 12) {
                Label("安全合规收款", systemImage: "shield.checkerboard")
                Label("自动激活", systemImage: "bolt.fill")
                Label("支持开票与解绑", systemImage: "doc.text")
            }
            .font(.system(size: 10))
            .foregroundColor(.secondary)

            Spacer()

            Button("我有激活码 / License") {
                showManualTokenInput = true
            }
            .buttonStyle(.plain)
            .font(.system(size: 11))
            .foregroundColor(.accentColor)
        }
        .padding(.top, 4)
    }

    // MARK: - 手动输入 License 覆盖层
    private var manualTokenOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { showManualTokenInput = false }

            VStack(spacing: 16) {
                HStack {
                    Text("输入官方 License 激活码")
                        .font(.system(size: 14, weight: .bold))
                    Spacer()
                    Button {
                        showManualTokenInput = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                Text("粘贴由官网、淘宝或官方渠道购买的 Base64 格式授权 Token，包含 Ed25519 机器签名。")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)

                TextEditor(text: $manualToken)
                    .font(.system(size: 11).monospaced())
                    .frame(height: 90)
                    .padding(6)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.primary.opacity(0.12), lineWidth: 1))

                if let err = manualTokenError {
                    Text(err)
                        .font(.system(size: 11))
                        .foregroundColor(.red)
                }

                HStack {
                    Spacer()
                    Button("取消") {
                        showManualTokenInput = false
                    }
                    Button("立即激活") {
                        let res = LicenseManager.shared.activate(tokenString: manualToken)
                        switch res {
                        case .success(let payload):
                            manualTokenError = nil
                            showManualTokenInput = false
                            checkoutState = .success(tier: payload.tier)
                        case .failure(let error):
                            manualTokenError = error.localizedDescription
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(20)
            .frame(width: 460)
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(12)
            .shadow(radius: 20)
        }
    }

    // MARK: - 邮箱登录 / 验证覆盖层 (方向 B：Luminescent Glass 流光玻璃)
    private var emailAuthOverlay: some View {
        ZStack {
            // 背景遮罩毛玻璃
            Color.black.opacity(colorScheme == .dark ? 0.65 : 0.4)
                .ignoresSafeArea()
                .onTapGesture { showEmailAuthSheet = false }

            // 主弹窗卡片 (460px 舒适大空间)
            VStack(spacing: 0) {
                // 顶部流光光晕
                ZStack {
                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.0, green: 0.89, blue: 1.0).opacity(colorScheme == .dark ? 0.28 : 0.16),
                                    Color(red: 0.04, green: 0.52, blue: 1.0).opacity(colorScheme == .dark ? 0.14 : 0.08),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 90
                            )
                        )
                        .frame(width: 260, height: 110)
                        .blur(radius: 18)
                        .offset(y: -40)

                    // 右上角关闭按钮
                    HStack {
                        Spacer()
                        Button {
                            showEmailAuthSheet = false
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.secondary)
                                .frame(width: 24, height: 24)
                                .background(Color.primary.opacity(0.06))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }

                    // 居中自发光钥匙徽章
                    ZStack {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.04, green: 0.52, blue: 1.0).opacity(0.22),
                                        Color(red: 0.0, green: 0.89, blue: 1.0).opacity(0.22)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)
                            .overlay {
                                RoundedRectangle(cornerRadius: 15, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.35), lineWidth: 0.8)
                            }
                            .shadow(color: Color(red: 0.0, green: 0.89, blue: 1.0).opacity(0.35), radius: 10)

                        Image(systemName: "key.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.0, green: 0.89, blue: 1.0),
                                        Color(red: 0.05, green: 0.52, blue: 1.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .padding(.top, 6)
                }

                // 标题与特权微标
                VStack(spacing: 8) {
                    Text("登录 SnapScreen 账户")
                        .font(.system(size: 18.5, weight: .bold))
                        .foregroundStyle(
                            colorScheme == .dark
                                ? LinearGradient(colors: [.white, Color(white: 0.88)], startPoint: .top, endPoint: .bottom)
                                : LinearGradient(colors: [Color(white: 0.1), Color(white: 0.25)], startPoint: .top, endPoint: .bottom)
                        )

                    HStack(spacing: 6) {
                        ForEach(["同步 Pro 终身特权", "多台 Mac 绑定", "发票与订单收据"], id: \.self) { text in
                            Text(text)
                                .font(.system(size: 10.5, weight: .medium))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.primary.opacity(0.04))
                                .clipShape(Capsule())
                                .overlay {
                                    Capsule()
                                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.6)
                                }
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 22)

                // 核心表单区域
                VStack(spacing: 14) {
                    // 1. 邮箱输入卡片
                    VStack(alignment: .leading, spacing: 7) {
                        HStack {
                            Text("电子邮箱账号")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("用于接收身份验证码")
                                .font(.system(size: 10.5))
                                .foregroundColor(Color(red: 0.0, green: 0.89, blue: 1.0))
                        }

                        HStack(spacing: 8) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)

                            TextField("name@example.com", text: $inputEmail)
                                .textFieldStyle(.plain)
                                .font(.system(size: 13.5))

                            Button {
                                sendVerificationCode()
                            } label: {
                                HStack(spacing: 4) {
                                    if isSendingCode {
                                        ProgressView()
                                            .controlSize(.mini)
                                    }
                                    Text(isSendingCode ? "发送中" : (countdownSeconds > 0 ? "重新发送 (\(countdownSeconds)s)" : (codeSentSuccess ? "已发送 · 重发" : "获取验证码")))
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundColor(Color(red: 0.0, green: 0.89, blue: 1.0))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.18), Color.cyan.opacity(0.18)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .strokeBorder(Color.cyan.opacity(0.35), lineWidth: 0.8)
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(inputEmail.isEmpty || isSendingCode || countdownSeconds > 0)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(colorScheme == .dark ? 0.25 : 0.03))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 0.8)
                        }
                    }

                    // 2. 6 位独立流光验证码输入卡片
                    VStack(alignment: .leading, spacing: 7) {
                        HStack {
                            Text("安全验证码")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("已发送至您的邮箱")
                                .font(.system(size: 10.5))
                                .foregroundColor(.secondary)
                        }

                        ZStack {
                            // 底层真实接收输入的隐藏 TextField (透明无感)
                            TextField("", text: $inputCode)
                                .focused($isCodeFocused)
                                .font(.system(size: 1))
                                .opacity(0.01)
                                .padding(0)
                                .onChange(of: inputCode) { _, newValue in
                                    if newValue.count > 6 {
                                        inputCode = String(newValue.prefix(6))
                                    }
                                }

                            // 顶层 6 个独立流光方格
                            HStack(spacing: 8) {
                                ForEach(0..<6, id: \.self) { index in
                                    let char: String = {
                                        if index < inputCode.count {
                                            let strIndex = inputCode.index(inputCode.startIndex, offsetBy: index)
                                            return String(inputCode[strIndex])
                                        } else {
                                            return ""
                                        }
                                    }()
                                    let isCurrent = (index == inputCode.count) || (index == 5 && inputCode.count == 6)

                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(Color.black.opacity(colorScheme == .dark ? 0.35 : 0.04))

                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .strokeBorder(
                                                isCurrent ? Color(red: 0.0, green: 0.89, blue: 1.0) : Color.primary.opacity(0.12),
                                                lineWidth: isCurrent ? 1.5 : 0.8
                                            )
                                            .shadow(color: isCurrent ? Color(red: 0.0, green: 0.89, blue: 1.0).opacity(0.35) : .clear, radius: 4)

                                        if !char.isEmpty {
                                            Text(char)
                                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                                .foregroundColor(Color(red: 0.0, green: 0.89, blue: 1.0))
                                        } else {
                                            Circle()
                                                .fill(Color.secondary.opacity(0.35))
                                                .frame(width: 5, height: 5)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        isCodeFocused = true
                                    }
                                }
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isCodeFocused = true
                        }
                    }

                    // 3. 错误提示
                    if let err = authErrorMessage {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.red)
                            Text(err)
                                .font(.system(size: 11))
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }

                    // 4. 主操作按钮 (流光海蓝渐变胶囊)
                    Button {
                        loginWithCode()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                            Text("立即验证并登录")
                                .font(.system(size: 13.5, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.0, green: 0.52, blue: 1.0),
                                    Color(red: 0.0, green: 0.82, blue: 1.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.25), lineWidth: 0.8)
                        }
                        .shadow(color: Color(red: 0.0, green: 0.52, blue: 1.0).opacity(0.35), radius: 8, y: 3)
                    }
                    .buttonStyle(.plain)
                    .disabled(inputEmail.isEmpty || inputCode.count < 4)
                    .padding(.top, 6)

                    // 5. 底部保障与退出状态
                    HStack {
                        if authManager.isLoggedIn {
                            Button("退出当前登录 (\(authManager.currentEmail ?? ""))") {
                                authManager.logout()
                                showEmailAuthSheet = false
                            }
                            .buttonStyle(.plain)
                            .font(.system(size: 11))
                            .foregroundColor(.red)
                        } else {
                            HStack(spacing: 4) {
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 10))
                                Text("端到端硬件级数字防伪 · 不上传任何截图内容")
                                    .font(.system(size: 10.5))
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 6)
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 30)
            .frame(width: 460)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(nsColor: .windowBackgroundColor).opacity(0.92))
                    .background(.ultraThinMaterial)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color(red: 0.0, green: 0.89, blue: 1.0).opacity(0.35),
                                Color.primary.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            }
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.6 : 0.25), radius: 36, x: 0, y: 16)
        }
    }

    // MARK: - 逻辑与网络处理
    private func startCheckoutFlow() {
        stopPolling()
        checkoutState = .requestingOrder

        Task {
            do {
                let order = try await authManager.createOrder(
                    tier: selectedTier,
                    channel: selectedChannel,
                    email: authManager.currentEmail
                )
                await MainActor.run {
                    self.activeOrderNo = order.orderNo
                    self.activeQrRawText = order.qrCodeText
                    self.activeQrImage = QRCodeGenerator.generate(from: order.qrCodeText, size: 240)
                    self.checkoutState = .awaitingPayment(
                        orderNo: order.orderNo,
                        qrCodeText: order.qrCodeText,
                        expiresAt: Date().addingTimeInterval(900)
                    )
                    startPolling(orderNo: order.orderNo)
                }
            } catch {
                await MainActor.run {
                    // 若无在线服务，生成演示/离线预留扫码
                    let demoQrText = "https://cduyzh.top/pay?order=DEMO_\(selectedTier.rawValue)_\(UUID().uuidString.prefix(6))"
                    self.activeOrderNo = "DEMO_\(selectedTier.rawValue)"
                    self.activeQrRawText = demoQrText
                    self.activeQrImage = QRCodeGenerator.generate(from: demoQrText, size: 240)
                    self.checkoutState = .awaitingPayment(
                        orderNo: "DEMO_\(selectedTier.rawValue)",
                        qrCodeText: demoQrText,
                        expiresAt: Date().addingTimeInterval(900)
                    )
                }
            }
        }
    }

    private func startPolling(orderNo: String) {
        stopPolling()
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            Task {
                if let token = try? await authManager.checkOrderStatus(orderNo: orderNo) {
                    await MainActor.run {
                        LicenseManager.shared.activate(tokenString: token)
                        self.checkoutState = .success(tier: self.selectedTier)
                        self.stopPolling()
                    }
                }
            }
        }
    }

    private func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }

    private func sendVerificationCode() {
        guard !inputEmail.isEmpty else { return }
        isSendingCode = true
        authErrorMessage = nil
        Task {
            do {
                try await authManager.sendCode(email: inputEmail)
                await MainActor.run {
                    self.isSendingCode = false
                    self.codeSentSuccess = true
                    self.countdownSeconds = 60
                    self.countdownTimer?.invalidate()
                    self.countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] timer in
                        if countdownSeconds > 0 {
                            countdownSeconds -= 1
                        } else {
                            timer.invalidate()
                        }
                    }
                    self.isCodeFocused = true
                }
            } catch {
                await MainActor.run {
                    self.isSendingCode = false
                    self.authErrorMessage = error.localizedDescription
                }
            }
        }
    }

    private func loginWithCode() {
        authErrorMessage = nil
        Task {
            do {
                _ = try await authManager.verifyCode(email: inputEmail, code: inputCode)
                await MainActor.run {
                    self.showEmailAuthSheet = false
                }
            } catch {
                await MainActor.run {
                    self.authErrorMessage = error.localizedDescription
                }
            }
        }
    }
}
