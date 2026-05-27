import Foundation
import Testing
@testable import TokenUsageCore

struct CostUsageCacheTests {
    @Test
    func `cache file URL uses codex specific artifact version`() {
        let root = URL(fileURLWithPath: "/tmp/tokenusage-cost-cache", isDirectory: true)

        let codexURL = CostUsageCacheIO.cacheFileURL(provider: .codex, cacheRoot: root)
        let claudeURL = CostUsageCacheIO.cacheFileURL(provider: .claude, cacheRoot: root)

        #expect(codexURL.lastPathComponent == "codex-v4.json")
        #expect(claudeURL.lastPathComponent == "claude-v2.json")
    }
}
