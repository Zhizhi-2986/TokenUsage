import SwiftUI
import WidgetKit

@main
struct TokenUsageWidgetBundle: WidgetBundle {
    var body: some Widget {
        TokenUsageSwitcherWidget()
        TokenUsageUsageWidget()
        TokenUsageHistoryWidget()
        TokenUsageCompactWidget()
    }
}

struct TokenUsageSwitcherWidget: Widget {
    private let kind = "TokenUsageSwitcherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: self.kind,
            provider: TokenUsageSwitcherTimelineProvider())
        { entry in
            TokenUsageSwitcherWidgetView(entry: entry)
        }
        .configurationDisplayName("TokenUsage Switcher")
        .description("Usage widget with a provider switcher.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct TokenUsageUsageWidget: Widget {
    private let kind = "TokenUsageUsageWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: self.kind,
            intent: ProviderSelectionIntent.self,
            provider: TokenUsageTimelineProvider())
        { entry in
            TokenUsageUsageWidgetView(entry: entry)
        }
        .configurationDisplayName("TokenUsage Usage")
        .description("Session and weekly usage with credits and costs.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct TokenUsageHistoryWidget: Widget {
    private let kind = "TokenUsageHistoryWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: self.kind,
            intent: ProviderSelectionIntent.self,
            provider: TokenUsageTimelineProvider())
        { entry in
            TokenUsageHistoryWidgetView(entry: entry)
        }
        .configurationDisplayName("TokenUsage History")
        .description("Usage history chart with recent totals.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct TokenUsageCompactWidget: Widget {
    private let kind = "TokenUsageCompactWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: self.kind,
            intent: CompactMetricSelectionIntent.self,
            provider: TokenUsageCompactTimelineProvider())
        { entry in
            TokenUsageCompactWidgetView(entry: entry)
        }
        .configurationDisplayName("TokenUsage Metric")
        .description("Compact widget for credits or cost.")
        .supportedFamilies([.systemSmall])
    }
}
