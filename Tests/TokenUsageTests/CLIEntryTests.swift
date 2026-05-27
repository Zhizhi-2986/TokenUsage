import TokenUsageCore
import Commander
import Foundation
import Testing
@testable import TokenUsageCLI

struct CLIEntryTests {
    @Test
    func `effective argv defaults to usage`() {
        #expect(TokenUsageCLI.effectiveArgv([]) == ["usage"])
        #expect(TokenUsageCLI.effectiveArgv(["--json"]) == ["usage", "--json"])
        #expect(TokenUsageCLI.effectiveArgv(["usage", "--json"]) == ["usage", "--json"])
    }

    @Test
    func `decodes format from options and flags`() {
        let jsonOption = ParsedValues(positional: [], options: ["format": ["json"]], flags: [])
        #expect(TokenUsageCLI._decodeFormatForTesting(from: jsonOption) == .json)

        let jsonFlag = ParsedValues(positional: [], options: [:], flags: ["json"])
        #expect(TokenUsageCLI._decodeFormatForTesting(from: jsonFlag) == .json)

        let textDefault = ParsedValues(positional: [], options: [:], flags: [])
        #expect(TokenUsageCLI._decodeFormatForTesting(from: textDefault) == .text)
    }

    @Test
    func `provider selection prefers override`() {
        let selection = TokenUsageCLI.providerSelection(rawOverride: "codex", enabled: [.claude, .gemini])
        #expect(selection.asList == [.codex])
    }

    @Test
    func `normalize version extracts numeric`() {
        #expect(TokenUsageCLI.normalizeVersion(raw: "codex 1.2.3 (build 4)") == "1.2.3")
        #expect(TokenUsageCLI.normalizeVersion(raw: "  v2.0  ") == "2.0")
    }

    @Test
    func `make header includes version when available`() {
        let header = TokenUsageCLI.makeHeader(provider: .codex, version: "1.2.3", source: "cli")
        #expect(header.contains("Codex"))
        #expect(header.contains("1.2.3"))
        #expect(header.contains("cli"))
    }

    @Test
    func `CLI version falls back to containing app bundle`() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("tokenusage-cli-version-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let appURL = root.appendingPathComponent("TokenUsage.app", isDirectory: true)
        let contentsURL = appURL.appendingPathComponent("Contents", isDirectory: true)
        let helpersURL = contentsURL.appendingPathComponent("Helpers", isDirectory: true)
        try FileManager.default.createDirectory(at: helpersURL, withIntermediateDirectories: true)

        let infoURL = contentsURL.appendingPathComponent("Info.plist")
        let plist: [String: Any] = ["CFBundleShortVersionString": "9.8.7"]
        let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try data.write(to: infoURL)

        let helperURL = helpersURL.appendingPathComponent("TokenUsageCLI")
        try Data().write(to: helperURL)

        #expect(TokenUsageCLI.containingAppVersion(for: helperURL) == "9.8.7")
    }

    @Test
    func `CLI version follows symlinked helper`() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("tokenusage-cli-version-symlink-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let appURL = root.appendingPathComponent("TokenUsage.app", isDirectory: true)
        let emptyBundleURL = root.appendingPathComponent("Empty.bundle", isDirectory: true)
        let contentsURL = appURL.appendingPathComponent("Contents", isDirectory: true)
        let helpersURL = contentsURL.appendingPathComponent("Helpers", isDirectory: true)
        let binURL = root.appendingPathComponent("bin", isDirectory: true)
        try FileManager.default.createDirectory(at: helpersURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: binURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: emptyBundleURL, withIntermediateDirectories: true)

        let infoURL = contentsURL.appendingPathComponent("Info.plist")
        let plist: [String: Any] = ["CFBundleShortVersionString": "2.4.6"]
        let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try data.write(to: infoURL)

        let helperURL = helpersURL.appendingPathComponent("TokenUsageCLI")
        try Data().write(to: helperURL)

        let symlinkURL = binURL.appendingPathComponent("tokenusage")
        try FileManager.default.createSymbolicLink(at: symlinkURL, withDestinationURL: helperURL)

        let emptyBundle = try #require(Bundle(url: emptyBundleURL))
        #expect(TokenUsageCLI.currentVersion(bundle: emptyBundle, executablePath: symlinkURL.path) == "2.4.6")
    }

    @Test
    func `render open AI web dashboard text includes summary`() {
        let event = CreditEvent(
            date: Date(timeIntervalSince1970: 1_700_000_000),
            service: "codex",
            creditsUsed: 10)
        let snapshot = OpenAIDashboardSnapshot(
            signedInEmail: "user@example.com",
            codeReviewRemainingPercent: 45,
            codeReviewLimit: RateWindow(
                usedPercent: 55,
                windowMinutes: nil,
                resetsAt: Date().addingTimeInterval(3600),
                resetDescription: nil),
            creditEvents: [event],
            dailyBreakdown: [],
            usageBreakdown: [],
            creditsPurchaseURL: nil,
            updatedAt: Date())

        let text = TokenUsageCLI.renderOpenAIWebDashboardText(snapshot)

        #expect(text.contains("Web session: user@example.com"))
        #expect(text.contains("Code review: 45% remaining (Resets in "))
        #expect(text.contains("Web history: 1 events"))
    }

    @Test
    func `maps errors to exit codes`() {
        #expect(TokenUsageCLI.mapError(CodexStatusProbeError.codexNotInstalled) == ExitCode(2))
        #expect(TokenUsageCLI.mapError(CodexStatusProbeError.timedOut) == ExitCode(4))
        #expect(TokenUsageCLI.mapError(UsageError.noRateLimitsFound) == ExitCode(3))
    }

    @Test
    func `provider selection falls back to both for primary pair`() {
        let selection = TokenUsageCLI.providerSelection(rawOverride: nil, enabled: [.codex, .claude])
        switch selection {
        case .both:
            break
        default:
            #expect(Bool(false))
        }
    }

    @Test
    func `provider selection falls back to custom when non primary`() {
        let selection = TokenUsageCLI.providerSelection(rawOverride: nil, enabled: [.codex, .gemini])
        switch selection {
        case let .custom(providers):
            #expect(providers == [.codex, .gemini])
        default:
            #expect(Bool(false))
        }
    }

    @Test
    func `provider selection defaults to codex when empty`() {
        let selection = TokenUsageCLI.providerSelection(rawOverride: nil, enabled: [])
        switch selection {
        case let .single(provider):
            #expect(provider == .codex)
        default:
            #expect(Bool(false))
        }
    }

    @Test
    func `decodes source and timeout options`() throws {
        let signature = TokenUsageCLI._usageSignatureForTesting()
        let parser = CommandParser(signature: signature)
        let parsed = try parser.parse(arguments: ["--web-timeout", "45", "--source", "oauth"])
        #expect(TokenUsageCLI._decodeWebTimeoutForTesting(from: parsed) == 45)
        #expect(TokenUsageCLI._decodeSourceModeForTesting(from: parsed) == .oauth)

        let parsedWeb = try parser.parse(arguments: ["--web"])
        #expect(TokenUsageCLI._decodeSourceModeForTesting(from: parsedWeb) == .web)
    }

    @Test
    func `should use color respects format and flags`() {
        #expect(!TokenUsageCLI.shouldUseColor(noColor: true, format: .text))
        #expect(!TokenUsageCLI.shouldUseColor(noColor: false, format: .json))
    }

    @Test
    func `kilo usage text notes show fallback only for auto resolved to CLI`() {
        #expect(TokenUsageCLI.usageTextNotes(
            provider: .kilo,
            sourceMode: .auto,
            resolvedSourceLabel: "cli") == ["Using CLI fallback"])
        #expect(TokenUsageCLI.usageTextNotes(
            provider: .kilo,
            sourceMode: .api,
            resolvedSourceLabel: "cli").isEmpty)
        #expect(TokenUsageCLI.usageTextNotes(
            provider: .codex,
            sourceMode: .auto,
            resolvedSourceLabel: "cli").isEmpty)
    }

    @Test
    func `kilo auto fallback summary includes ordered attempt details`() {
        let attempts = [
            ProviderFetchAttempt(
                strategyID: "kilo.api",
                kind: .apiToken,
                wasAvailable: true,
                errorDescription: "Kilo authentication failed (401/403)."),
            ProviderFetchAttempt(
                strategyID: "kilo.cli",
                kind: .cli,
                wasAvailable: true,
                errorDescription: "Kilo CLI session not found."),
        ]

        let summary = TokenUsageCLI.kiloAutoFallbackSummary(
            provider: .kilo,
            sourceMode: .auto,
            attempts: attempts)
        let expected = [
            "Kilo auto fallback attempts: api: Kilo authentication failed (401/403).",
            " -> cli: Kilo CLI session not found.",
        ].joined()

        #expect(
            summary ==
                expected)
    }

    @Test
    func `kilo auto fallback summary is nil outside kilo auto failures`() {
        let attempts = [
            ProviderFetchAttempt(
                strategyID: "kilo.api",
                kind: .apiToken,
                wasAvailable: true,
                errorDescription: "example"),
        ]

        #expect(TokenUsageCLI.kiloAutoFallbackSummary(
            provider: .kilo,
            sourceMode: .api,
            attempts: attempts) == nil)
        #expect(TokenUsageCLI.kiloAutoFallbackSummary(
            provider: .codex,
            sourceMode: .auto,
            attempts: attempts) == nil)
    }

    @Test
    func `source mode requires web support is provider aware`() {
        #expect(TokenUsageCLI.sourceModeRequiresWebSupport(.web, provider: .kilo))
        #expect(TokenUsageCLI.sourceModeRequiresWebSupport(.auto, provider: .codex))
        #expect(!TokenUsageCLI.sourceModeRequiresWebSupport(.auto, provider: .kilo))
        #expect(!TokenUsageCLI.sourceModeRequiresWebSupport(.api, provider: .kilo))
    }
}
