import Testing
@testable import TokenUsage

struct KeychainMigrationTests {
    @Test
    func `migration list covers known keychain items`() {
        let items = Set(KeychainMigration.itemsToMigrate.map(\.label))
        let expected: Set = [
            "com.steipete.TokenUsage:codex-cookie",
            "com.steipete.TokenUsage:claude-cookie",
            "com.steipete.TokenUsage:cursor-cookie",
            "com.steipete.TokenUsage:factory-cookie",
            "com.steipete.TokenUsage:minimax-cookie",
            "com.steipete.TokenUsage:minimax-api-token",
            "com.steipete.TokenUsage:augment-cookie",
            "com.steipete.TokenUsage:copilot-api-token",
            "com.steipete.TokenUsage:zai-api-token",
            "com.steipete.TokenUsage:synthetic-api-key",
        ]

        let missing = expected.subtracting(items)
        #expect(missing.isEmpty, "Missing migration entries: \(missing.sorted())")
    }
}
