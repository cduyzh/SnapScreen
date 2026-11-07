import AppKit
import Foundation
import Combine

// MARK: - Payment Channel
public enum PaymentChannel: String, CaseIterable, Identifiable {
    case wechat = "wechat"
    case alipay = "alipay"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .wechat: return "微信支付"
        case .alipay: return "支付宝"
        }
    }

    public var iconName: String {
        switch self {
        case .wechat: return "message.fill"
        case .alipay: return "creditcard.fill"
        }
    }

    public var brandColor: NSColor {
        switch self {
        case .wechat: return NSColor(calibratedRed: 0.09, green: 0.73, blue: 0.35, alpha: 1.0)
        case .alipay: return NSColor(calibratedRed: 0.08, green: 0.49, blue: 0.98, alpha: 1.0)
        }
    }
}

// MARK: - Plan Item
public struct PaywallPlanItem: Identifiable, Equatable {
    public let id: LicenseTier
    public let title: String
    public let priceDisplay: String
    public let periodNote: String
    public let badge: String?
    public let isPopular: Bool
    public let features: [String]

    public static let standardPlans: [PaywallPlanItem] = [
        PaywallPlanItem(
            id: .monthly,
            title: "月度会员",
            priceDisplay: "¥9.9",
            periodNote: "/月",
            badge: nil,
            isPopular: false,
            features: [
                "长截图无官方水印",
                "自定义浏览器外壳文案",
                "全格式超清导出",
                "支持 2 台 Mac 设备"
            ]
        ),
        PaywallPlanItem(
            id: .yearly,
            title: "年度会员",
            priceDisplay: "¥58",
            periodNote: "/年 (约 ¥4.8/月)",
            badge: "立省 52% · 强烈推荐",
            isPopular: true,
            features: [
                "包含月度会员全部特权",
                "长截图批量导出无损无水印",
                "美化外壳专属渐变与预设",
                "优先技术支持与大版本升级",
                "支持 3 台 Mac 设备绑定"
            ]
        ),
        PaywallPlanItem(
            id: .lifetime,
            title: "终身买断",
            priceDisplay: "¥99",
            periodNote: "一次付费 · 永久使用",
            badge: "终身授权",
            isPopular: false,
            features: [
                "永久解锁所有现有及未来功能",
                "长截图终身无水印",
                "所有外壳外框自由定制",
                "支持多设备灵活解绑与迁移",
                "尊贵 Pro 终身专属徽章"
            ]
        )
    ]
}

// MARK: - Paywall State Machine
public enum PaywallCheckoutState: Equatable {
    case idle
    case requestingOrder
    case awaitingPayment(orderNo: String, qrCodeText: String, expiresAt: Date)
    case success(tier: LicenseTier)
    case failure(String)
}
