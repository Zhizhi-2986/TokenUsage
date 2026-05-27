import TokenUsageCore
import TokenUsageMacroSupport
import Foundation

@ProviderImplementationRegistration
struct KiroProviderImplementation: ProviderImplementation {
    let id: UsageProvider = .kiro
}
