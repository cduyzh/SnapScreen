import Foundation
import Combine

public enum LicenseError: LocalizedError {
    case invalidFormat
    case signatureVerificationFailed
    case productMismatch
    case deviceMismatch
    case expired
    case clockTampered

    public var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "许可证格式无效，请检查是否复制完整。"
        case .signatureVerificationFailed:
            return "许可证签名校验未通过，无法确认官方有效性。"
        case .productMismatch:
            return "许可证产品不匹配，该授权属于其他 cduyzh 应用。"
        case .deviceMismatch:
            return "此许可证已被绑定至其他 Mac 设备，无法在此电脑使用。"
        case .expired:
            return "此许可证已到期，请续费升级。"
        case .clockTampered:
            return "检测到系统时钟异常，已暂时锁定试用权益。请校准时间后重试。"
        }
    }
}

public final class LicenseManager: ObservableObject {
    public static let shared = LicenseManager()

    /// 当前 Mac 应用产品标识
    public let currentProductId: String = "snapscreen"

    // MARK: - Keys
    private let kSavedLicenseToken = "cduyzh.license.token"
    private let kTrialStartDate = "cduyzh.trial.start_date"
    private let kHighestKnownTime = "cduyzh.trial.highest_known_time"

    // MARK: - Published States
    @Published public private(set) var currentTier: LicenseTier = .lifetime
    @Published public private(set) var isPro: Bool = true
    @Published public private(set) var trialDaysRemaining: Int = 0
    @Published public private(set) var activeEmail: String? = nil
    @Published public private(set) var expirationDate: Date? = nil
    @Published public private(set) var activeLicense: LicenseToken? = nil

    private init() {
        refreshState()
    }

    /// 重新计算与刷新当前授权与试用状态（当前完全免费，全功能开放）
    public func refreshState() {
        // 暂时完全免费模式：全功能无限制开放，不附加任何水印与门禁
        self.currentTier = .lifetime
        self.isPro = true
        self.trialDaysRemaining = 0
        self.activeEmail = nil
        self.expirationDate = nil
        self.activeLicense = nil
    }

    /// 异步向服务器核验设备硬件指纹（完全免费模式下跳过）
    public func checkDeviceTrialOnline() {
        // 完全免费模式无需请求
    }

    /// 评估 7 天试用期
    private func evaluateTrialStatus() {
        let now = Date().timeIntervalSince1970
        let highest = UserDefaults.standard.double(forKey: kHighestKnownTime)

        // 防时钟倒拨检测 (允许 5 分钟网络/休眠漂移)
        if highest > 0 && now < (highest - 300) {
            self.currentTier = .free
            self.isPro = false
            self.trialDaysRemaining = 0
            self.activeEmail = nil
            self.expirationDate = nil
            return
        }

        // 更新历史最高时间
        if now > highest {
            UserDefaults.standard.set(now, forKey: kHighestKnownTime)
        }

        // 获取或初始化试用起始时间：结合本地受保护持久化（UserDefaults + Application Support 安全文件，零系统权限）
        var trialStart: TimeInterval = 0
        if let storedVal = KeychainHelper.getString(forKey: kTrialStartDate),
           let val = TimeInterval(storedVal), val > 0 {
            trialStart = val
        } else {
            trialStart = UserDefaults.standard.double(forKey: kTrialStartDate)
        }

        if trialStart <= 0 {
            trialStart = now
            UserDefaults.standard.set(trialStart, forKey: kTrialStartDate)
            KeychainHelper.setString(String(trialStart), forKey: kTrialStartDate)
        } else {
            // 同步恢复双端
            UserDefaults.standard.set(trialStart, forKey: kTrialStartDate)
            KeychainHelper.setString(String(trialStart), forKey: kTrialStartDate)
        }

        let trialDuration: TimeInterval = 7 * 24 * 3600 // 7 天
        let trialEnd = trialStart + trialDuration

        if now < trialEnd {
            let remainingSeconds = trialEnd - now
            let days = Int(ceil(remainingSeconds / (24 * 3600)))
            self.currentTier = .trial
            self.isPro = true
            self.trialDaysRemaining = max(1, days)
            self.activeEmail = "免费体验用户"
            self.expirationDate = Date(timeIntervalSince1970: trialEnd)
        } else {
            // 试用已结束，降级为免费版
            self.currentTier = .free
            self.isPro = false
            self.trialDaysRemaining = 0
            self.activeEmail = nil
            self.expirationDate = nil
        }
    }

    /// 激活 License Token
    @discardableResult
    public func activate(tokenString: String) -> Result<LicensePayload, LicenseError> {
        let trimmed = tokenString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let token = LicenseToken.parse(from: trimmed, expectedProductId: currentProductId) else {
            // 细分是否为跨应用串货
            if let looseToken = LicenseToken.parse(from: trimmed, expectedProductId: "") {
                if let prod = looseToken.payload.product, prod.lowercased() != currentProductId.lowercased() {
                    return .failure(.productMismatch)
                }
            }
            return .failure(.invalidFormat)
        }

        if token.payload.isExpired {
            return .failure(.expired)
        }

        if let bound = token.payload.deviceUuid, !bound.isEmpty, bound != HardwareIdentifier.uuid {
            return .failure(.deviceMismatch)
        }

        // 保存并生效
        UserDefaults.standard.set(trimmed, forKey: kSavedLicenseToken)
        refreshState()
        return .success(token.payload)
    }

    /// 解除激活
    public func deactivate() {
        UserDefaults.standard.removeObject(forKey: kSavedLicenseToken)
        refreshState()
    }
}
