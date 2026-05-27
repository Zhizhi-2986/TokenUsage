import TokenUsageCore
import Foundation

extension Notification.Name {
    static let tokenusageOpenSettings = Notification.Name("tokenusageOpenSettings")
    static let tokenusageDebugBlinkNow = Notification.Name("tokenusageDebugBlinkNow")
    static let tokenusageWeeklyLimitReset = Notification.Name("tokenusageWeeklyLimitReset")
    static let tokenusageProviderConfigDidChange = Notification.Name("tokenusageProviderConfigDidChange")
}

@MainActor
final class WeeklyLimitResetEvent: NSObject {
    let provider: UsageProvider
    let accountIdentifier: String
    let accountLabel: String?
    let usedPercent: Double

    init(provider: UsageProvider, accountIdentifier: String, accountLabel: String?, usedPercent: Double) {
        self.provider = provider
        self.accountIdentifier = accountIdentifier
        self.accountLabel = accountLabel
        self.usedPercent = usedPercent
    }
}
