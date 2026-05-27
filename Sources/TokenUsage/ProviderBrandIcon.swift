import AppKit
import TokenUsageCore

enum ProviderBrandIcon {
    private static let size = NSSize(width: 16, height: 16)

    /// Lazy-loaded resource bundle for provider icons.
    private static let resourceBundle: Bundle? = {
        // SwiftPM creates a TokenUsage_TokenUsage.bundle for resources in the TokenUsage target.
        if let bundleURL = Bundle.main.url(forResource: "TokenUsage_TokenUsage", withExtension: "bundle"),
           let bundle = Bundle(url: bundleURL)
        {
            return bundle
        }
        // Fallback to main bundle for development/testing.
        return Bundle.main
    }()

    static func image(for provider: UsageProvider) -> NSImage? {
        let baseName = ProviderDescriptorRegistry.descriptor(for: provider).branding.iconResourceName
        guard let bundle = self.resourceBundle,
              let url = bundle.url(forResource: baseName, withExtension: "svg"),
              let image = NSImage(contentsOf: url)
        else {
            return nil
        }

        image.size = self.size
        image.isTemplate = true
        return image
    }
}
