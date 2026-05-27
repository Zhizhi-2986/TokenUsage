import TokenUsageCore
import Foundation
import Testing

struct ConfigValidationTests {
    @Test
    func `reports unsupported source`() {
        var config = TokenUsageConfig.makeDefault()
        config.setProviderConfig(ProviderConfig(id: .codex, source: .api))
        let issues = TokenUsageConfigValidator.validate(config)
        #expect(issues.contains(where: { $0.code == "unsupported_source" }))
    }

    @Test
    func `reports missing API key when source API`() {
        var config = TokenUsageConfig.makeDefault()
        config.setProviderConfig(ProviderConfig(id: .zai, source: .api, apiKey: nil))
        let issues = TokenUsageConfigValidator.validate(config)
        #expect(issues.contains(where: { $0.code == "api_key_missing" }))
    }

    @Test
    func `reports invalid region`() {
        var config = TokenUsageConfig.makeDefault()
        config.setProviderConfig(ProviderConfig(id: .minimax, region: "nowhere"))
        let issues = TokenUsageConfigValidator.validate(config)
        #expect(issues.contains(where: { $0.code == "invalid_region" }))
    }

    @Test
    func `warns on unsupported token accounts`() {
        let accounts = ProviderTokenAccountData(
            version: 1,
            accounts: [ProviderTokenAccount(id: UUID(), label: "a", token: "t", addedAt: 0, lastUsed: nil)],
            activeIndex: 0)
        var config = TokenUsageConfig.makeDefault()
        config.setProviderConfig(ProviderConfig(id: .gemini, tokenAccounts: accounts))
        let issues = TokenUsageConfigValidator.validate(config)
        #expect(issues.contains(where: { $0.code == "token_accounts_unused" }))
    }

    @Test
    func `allows ollama token accounts`() {
        let accounts = ProviderTokenAccountData(
            version: 1,
            accounts: [ProviderTokenAccount(id: UUID(), label: "a", token: "t", addedAt: 0, lastUsed: nil)],
            activeIndex: 0)
        var config = TokenUsageConfig.makeDefault()
        config.setProviderConfig(ProviderConfig(id: .ollama, tokenAccounts: accounts))
        let issues = TokenUsageConfigValidator.validate(config)
        #expect(!issues.contains(where: { $0.code == "token_accounts_unused" && $0.provider == .ollama }))
    }

    @Test
    func `accepts kilo extras config field`() {
        var config = TokenUsageConfig.makeDefault()
        config.setProviderConfig(ProviderConfig(id: .kilo, extrasEnabled: true))
        let issues = TokenUsageConfigValidator.validate(config)
        #expect(!issues.contains(where: { $0.provider == .kilo && $0.field == "extrasEnabled" }))
    }
}
