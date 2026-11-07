import Foundation
import Combine

@MainActor
public final class AuthSessionManager: ObservableObject {
    public static let shared = AuthSessionManager()

    // MARK: - Keys
    private let kUserEmail = "cduyzh.auth.user_email"

    // MARK: - Published Properties
    @Published public private(set) var currentEmail: String?
    @Published public private(set) var isLoggedIn: Bool = false
    @Published public var apiBaseURL: String = "https://auth.cduyzh.top"

    /// 当前 Mac 应用产品标识
    public let currentProductId: String = "snapscreen"

    private init() {
        if let savedEmail = UserDefaults.standard.string(forKey: kUserEmail), !savedEmail.isEmpty {
            self.currentEmail = savedEmail
            self.isLoggedIn = true
        }
    }

    // MARK: - Core Network Request

    /// 向授权中台统一发送网络请求
    public func sendRequest(path: String, method: String = "GET", body: [String: Any]? = nil) async throws -> (Data, HTTPURLResponse) {
        guard let url = URL(string: "\(apiBaseURL)\(path)") else {
            throw NSError(domain: "SnapScreenAuth", code: 400, userInfo: [NSLocalizedDescriptionKey: "中台服务地址无效"])
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 10

        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "SnapScreenNetwork", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法解析服务器响应"])
        }

        return (data, httpResponse)
    }

    // MARK: - API Methods

    /// 发送 6 位通用邮箱验证码
    public func sendCode(email: String) async throws {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard cleanEmail.contains("@") && cleanEmail.contains(".") else {
            throw NSError(domain: "SnapScreenAuth", code: 400, userInfo: [NSLocalizedDescriptionKey: "请输入合法的邮箱地址"])
        }

        let body: [String: Any] = [
            "email": cleanEmail,
            "device_uuid": HardwareIdentifier.uuid
        ]

        let (_, response) = try await sendRequest(path: "/api/auth/send-code", method: "POST", body: body)
        guard (200...299).contains(response.statusCode) else {
            throw NSError(domain: "SnapScreenAuth", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "验证码发送失败，请稍后重试"])
        }
    }

    /// 校验邮箱与验证码进行登录 (通用账户体系，自动拉取当前产品授权)
    public func verifyCode(email: String, code: String) async throws -> String? {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanCode = code.trimmingCharacters(in: .whitespacesAndNewlines)

        let body: [String: Any] = [
            "email": cleanEmail,
            "code": cleanCode,
            "product_id": currentProductId,
            "device_uuid": HardwareIdentifier.uuid
        ]

        let (data, response) = try await sendRequest(path: "/api/auth/verify-code", method: "POST", body: body)
        guard (200...299).contains(response.statusCode) else {
            throw NSError(domain: "SnapScreenAuth", code: 401, userInfo: [NSLocalizedDescriptionKey: "验证码错误或已过期"])
        }

        struct ProductLicenseItem: Decodable {
            let productId: String
            let tier: String
            let token: String
            let expiresAt: TimeInterval
        }

        struct LoginResponse: Decodable {
            let success: Bool
            let email: String
            let productId: String?
            let licenseToken: String?
            let licenses: [ProductLicenseItem]?
        }

        if let res = try? JSONDecoder().decode(LoginResponse.self, from: data) {
            self.currentEmail = res.email
            self.isLoggedIn = true
            UserDefaults.standard.set(res.email, forKey: self.kUserEmail)
            if let token = res.licenseToken {
                LicenseManager.shared.activate(tokenString: token)
            }
            return res.licenseToken
        }

        return nil
    }

    /// 创建支付订单 (按当前产品独立下单)
    public func createOrder(tier: LicenseTier, channel: PaymentChannel, email: String?) async throws -> (orderNo: String, qrCodeText: String) {
        let body: [String: Any] = [
            "product_id": currentProductId,
            "tier": tier.rawValue,
            "channel": channel.rawValue,
            "email": email ?? (currentEmail ?? ""),
            "device_uuid": HardwareIdentifier.uuid
        ]

        let (data, response) = try await sendRequest(path: "/api/payment/create-order", method: "POST", body: body)
        guard (200...299).contains(response.statusCode) else {
            throw NSError(domain: "SnapScreenPay", code: 502, userInfo: [NSLocalizedDescriptionKey: "创建支付订单失败，请稍后重试"])
        }

        struct OrderResponse: Decodable {
            let success: Bool
            let orderNo: String
            let qrCodeText: String
        }

        let res = try JSONDecoder().decode(OrderResponse.self, from: data)
        return (res.orderNo, res.qrCodeText)
    }

    /// 轮询订单支付状态
    public func checkOrderStatus(orderNo: String) async throws -> String? {
        guard let (data, response) = try? await sendRequest(path: "/api/payment/check-order?order_no=\(orderNo)", method: "GET") else {
            return nil
        }
        guard (200...299).contains(response.statusCode) else {
            return nil
        }

        struct CheckResponse: Decodable {
            let status: String // "PENDING", "PAID", "EXPIRED"
            let licenseToken: String?
        }

        let res = try JSONDecoder().decode(CheckResponse.self, from: data)
        if res.status == "PAID", let token = res.licenseToken {
            return token
        }
        return nil
    }

    /// 退出登录
    public func logout() {
        self.currentEmail = nil
        self.isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: kUserEmail)
        LicenseManager.shared.deactivate()
    }
}
