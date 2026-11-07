import Foundation

/// 纯原生本地安全状态存取帮助类（零系统权限要求、零弹窗打扰）。
/// 遵循 cduyzh 本地优先数据隐私规范：结合 UserDefaults 与 Application Support 受保护文件（0600 权限），
/// 保证应用状态安全可靠持久化，彻底杜绝调用系统全局 Keychain 导致的频繁系统密码授权弹窗。
public enum KeychainHelper {
    private static let bundleID = "com.cduyzh.snapscreen"
    private static let stateFileName = ".device_state"

    private static var storageURL: URL? {
        guard let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        let folder = appSupport.appendingPathComponent(bundleID, isDirectory: true)
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: [
                .posixPermissions: 0o700
            ])
        }
        return folder.appendingPathComponent(stateFileName)
    }

    private static func readStorage() -> [String: String] {
        guard let url = storageURL,
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: String] else {
            return [:]
        }
        return dict
    }

    private static func writeStorage(_ dict: [String: String]) {
        guard let url = storageURL,
              let data = try? PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0) else {
            return
        }
        try? data.write(to: url, options: .atomic)
        try? FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
    }

    /// 保存字符串到本地受保护存储
    public static func setString(_ value: String, forKey key: String) {
        UserDefaults.standard.set(value, forKey: "local_state_\(key)")
        var current = readStorage()
        current[key] = value
        writeStorage(current)
    }

    /// 从本地受保护存储读取字符串
    public static func getString(forKey key: String) -> String? {
        if let val = UserDefaults.standard.string(forKey: "local_state_\(key)"), !val.isEmpty {
            return val
        }
        let current = readStorage()
        return current[key]
    }

    /// 删除本地存储项
    public static func delete(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: "local_state_\(key)")
        var current = readStorage()
        current.removeValue(forKey: key)
        writeStorage(current)
    }
}
