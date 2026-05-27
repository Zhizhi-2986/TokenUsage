@attached(peer, names: prefixed(_TokenUsageDescriptorRegistration_))
public macro ProviderDescriptorRegistration() = #externalMacro(
    module: "TokenUsageMacros",
    type: "ProviderDescriptorRegistrationMacro")

@attached(member, names: named(descriptor))
public macro ProviderDescriptorDefinition() = #externalMacro(
    module: "TokenUsageMacros",
    type: "ProviderDescriptorDefinitionMacro")

@attached(peer, names: prefixed(_TokenUsageImplementationRegistration_))
public macro ProviderImplementationRegistration() = #externalMacro(
    module: "TokenUsageMacros",
    type: "ProviderImplementationRegistrationMacro")
