import Foundation

public enum TokenUsageConfigStoreError: LocalizedError {
    case invalidURL
    case decodeFailed(String)
    case encodeFailed(String)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Invalid TokenUsage config path."
        case let .decodeFailed(details):
            "Failed to decode TokenUsage config: \(details)"
        case let .encodeFailed(details):
            "Failed to encode TokenUsage config: \(details)"
        }
    }
}

public struct TokenUsageConfigStore: @unchecked Sendable {
    public let fileURL: URL
    private let fileManager: FileManager

    public init(fileURL: URL = Self.defaultURL(), fileManager: FileManager = .default) {
        self.fileURL = fileURL
        self.fileManager = fileManager
    }

    public func load() throws -> TokenUsageConfig? {
        guard self.fileManager.fileExists(atPath: self.fileURL.path) else { return nil }
        let data = try Data(contentsOf: self.fileURL)
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(TokenUsageConfig.self, from: data)
            return decoded.normalized()
        } catch {
            throw TokenUsageConfigStoreError.decodeFailed(error.localizedDescription)
        }
    }

    public func loadOrCreateDefault() throws -> TokenUsageConfig {
        if let existing = try self.load() {
            return existing
        }
        // Migrate from legacy ~/.codexbar/ if present
        if let legacy = try? Self.migrateIfNeeded(to: self.fileURL, fileManager: self.fileManager) {
            return legacy
        }
        let config = TokenUsageConfig.makeDefault()
        try self.save(config)
        return config
    }

    private static func migrateIfNeeded(to targetURL: URL, fileManager: FileManager) throws -> TokenUsageConfig? {
        let legacyURL = targetURL
            .deletingLastPathComponent()  // config.json
            .deletingLastPathComponent()  // .tokenusage
            .appendingPathComponent(".codexbar", isDirectory: true)
            .appendingPathComponent("config.json")
        guard fileManager.fileExists(atPath: legacyURL.path) else { return nil }
        let data = try Data(contentsOf: legacyURL)
        let decoder = JSONDecoder()
        let config = try decoder.decode(TokenUsageConfig.self, from: data)
        let directory = targetURL.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        let normalized = config.normalized()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(normalized).write(to: targetURL, options: [.atomic])
        return normalized
    }

    public func save(_ config: TokenUsageConfig) throws {
        let normalized = config.normalized()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data: Data
        do {
            data = try encoder.encode(normalized)
        } catch {
            throw TokenUsageConfigStoreError.encodeFailed(error.localizedDescription)
        }
        let directory = self.fileURL.deletingLastPathComponent()
        if !self.fileManager.fileExists(atPath: directory.path) {
            try self.fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        try data.write(to: self.fileURL, options: [.atomic])
        try self.applySecurePermissionsIfNeeded()
    }

    public func deleteIfPresent() throws {
        guard self.fileManager.fileExists(atPath: self.fileURL.path) else { return }
        try self.fileManager.removeItem(at: self.fileURL)
    }

    public static func defaultURL(home: URL = FileManager.default.homeDirectoryForCurrentUser) -> URL {
        home
            .appendingPathComponent(".tokenusage", isDirectory: true)
            .appendingPathComponent("config.json")
    }

    private func applySecurePermissionsIfNeeded() throws {
        #if os(macOS) || os(Linux)
        try self.fileManager.setAttributes([
            .posixPermissions: NSNumber(value: Int16(0o600)),
        ], ofItemAtPath: self.fileURL.path)
        #endif
    }
}
