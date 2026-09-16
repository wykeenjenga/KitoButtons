//
//  KitoButton.swift
//  KitoButtons
//
//  Created by Wycliff Njenga on 16/09/2026.
//  Copyright © 2026 Wycliff Njenga. All rights reserved.
//

import SwiftUI

public enum KitoIconPlacement: Sendable { case leading, trailing }

/// A native `ButtonStyle` that draws KitoFields chrome. Use directly on any `Button`, or through `KitoButton`.
///
/// ```swift
/// Button("Save") { save() }.buttonStyle(.kito(.primary))
/// ```
public struct KitoButtonStyle: ButtonStyle {
    public var variant: KitoButtonVariant
    public var size: KitoButtonSize
    public var isFullWidth: Bool
    public var isLoading: Bool

    @Environment(\.kitoButtonTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    public init(_ variant: KitoButtonVariant = .primary, size: KitoButtonSize = .medium, fullWidth: Bool = false, loading: Bool = false) {
        self.variant = variant
        self.size = size
        self.isFullWidth = fullWidth
        self.isLoading = loading
    }

    public func makeBody(configuration: Configuration) -> some View {
        let colors = theme.colors(for: variant)
        let pressed = configuration.isPressed
        let isLink = variant == .link

        configuration.label
            .font(size.font)
            .foregroundColor(colors.foreground)
            .opacity(isLoading ? 0 : 1)
            .overlay {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(colors.foreground)
                        .scaleEffect(size == .small ? 0.8 : 1)
                }
            }
            .padding(.horizontal, isLink ? 0 : size.horizontalPadding)
            .frame(maxWidth: isFullWidth && !isLink ? .infinity : nil)
            .frame(minHeight: isLink ? nil : size.height)
            .background {
                if !isLink {
                    KitoButtonOutline(theme.shape)
                        .fill(pressed ? colors.pressedBackground : colors.background)
                        .overlay {
                            if colors.border != .clear {
                                KitoButtonOutline(theme.shape).strokeBorder(colors.border, lineWidth: theme.borderWidth)
                            }
                        }
                        .shadow(color: (isEnabled ? theme.shadow?.color : nil) ?? .clear,
                                radius: theme.shadow?.radius ?? 0,
                                x: theme.shadow?.x ?? 0,
                                y: theme.shadow?.y ?? 0)
                }
            }
            .contentShape(KitoButtonOutline(theme.shape))
            .scaleEffect(pressed && !isLink ? theme.pressedScale : 1)
            .opacity(!isEnabled ? theme.disabledOpacity : (pressed ? theme.pressedOpacity : 1))
            .animation(theme.animation, value: pressed)
            .animation(theme.animation, value: isLoading)
    }
}

public extension ButtonStyle where Self == KitoButtonStyle {
    static func kito(_ variant: KitoButtonVariant = .primary, size: KitoButtonSize = .medium, fullWidth: Bool = false, loading: Bool = false) -> KitoButtonStyle {
        KitoButtonStyle(variant, size: size, fullWidth: fullWidth, loading: loading)
    }
}

/// Comprehensive button: variants, sizes, icons, loading state, full width, async actions.
///
/// ```swift
/// KitoButton("Continue", systemImage: "arrow.right", iconPlacement: .trailing) {
///     await submit()          // shows a spinner and disables the button until done
/// }
/// .fullWidth()
/// .disabled(!formIsValid)
/// ```
public struct KitoButton: View {
    private let title: String?
    private let systemImage: String?
    private let image: Image?
    private var iconPlacement: KitoIconPlacement
    private var variant: KitoButtonVariant = .primary
    private var size: KitoButtonSize = .medium
    private var isFullWidth = false
    private var externalLoading: Bool? = nil
    private var hapticsEnabled = true
    private var role: ButtonRole? = nil
    private var accessibilityHint: String?
    private let syncAction: (() -> Void)?
    private let asyncAction: (() async -> Void)?

    @State private var isRunning = false
    @Environment(\.kitoButtonTheme) private var theme

    // MARK: Init

    public init(_ title: String, systemImage: String? = nil, iconPlacement: KitoIconPlacement = .leading, action: @escaping () -> Void) {
        self.title = title; self.systemImage = systemImage; self.image = nil
        self.iconPlacement = iconPlacement; syncAction = action; asyncAction = nil
    }

    /// Async variant: the button shows a spinner and is disabled while `action` runs.
    public init(_ title: String, systemImage: String? = nil, iconPlacement: KitoIconPlacement = .leading, action: @escaping () async -> Void) {
        self.title = title; self.systemImage = systemImage; self.image = nil
        self.iconPlacement = iconPlacement; syncAction = nil; asyncAction = action
    }

    public init(_ title: String, image: Image, iconPlacement: KitoIconPlacement = .leading, action: @escaping () -> Void) {
        self.title = title; self.systemImage = nil; self.image = image
        self.iconPlacement = iconPlacement; syncAction = action; asyncAction = nil
    }

    /// Icon-only button (square).
    public init(systemImage: String, accessibilityLabel: String, action: @escaping () -> Void) {
        self.title = nil; self.systemImage = systemImage; self.image = nil
        self.iconPlacement = .leading; syncAction = action; asyncAction = nil
        self.accessibilityHint = accessibilityLabel
    }

    // MARK: Body

    private var isLoading: Bool { externalLoading ?? isRunning }

    public var body: some View {
        Button(role: role, action: perform) {
            HStack(spacing: theme.iconSpacing) {
                if iconPlacement == .leading { icon }
                if let title { Text(title).lineLimit(1).minimumScaleFactor(0.8) }
                if iconPlacement == .trailing { icon }
            }
            .frame(minWidth: title == nil ? size.height - (variant == .link ? 0 : size.horizontalPadding * 2) : nil)
        }
        .buttonStyle(KitoButtonStyle(variant, size: size, fullWidth: isFullWidth, loading: isLoading))
        .disabled(isLoading)
        .accessibilityLabel(title ?? accessibilityHint ?? "")
        .accessibilityAddTraits(isLoading ? .updatesFrequently : [])
        .accessibilityValue(isLoading ? "Loading" : "")
    }

    @ViewBuilder private var icon: some View {
        if let systemImage {
            Image(systemName: systemImage).font(.system(size: size.iconSize, weight: .semibold))
        } else if let image {
            image.resizable().scaledToFit().frame(width: size.iconSize, height: size.iconSize)
        }
    }

    private func perform() {
        haptic()
        if let syncAction {
            syncAction()
        } else if let asyncAction {
            guard !isRunning else { return }
            isRunning = true
            Task { @MainActor in
                await asyncAction()
                isRunning = false
            }
        }
    }

    private func haptic() {
        #if os(iOS)
        guard hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }

    // MARK: Fluent configuration

    private func mutating(_ change: (inout KitoButton) -> Void) -> KitoButton {
        var copy = self
        change(&copy)
        return copy
    }

    public func variant(_ variant: KitoButtonVariant) -> KitoButton { mutating { $0.variant = variant } }
    public func size(_ size: KitoButtonSize) -> KitoButton { mutating { $0.size = size } }
    public func fullWidth(_ enabled: Bool = true) -> KitoButton { mutating { $0.isFullWidth = enabled } }
    /// Externally controlled spinner (overrides the automatic async state).
    public func loading(_ isLoading: Bool) -> KitoButton { mutating { $0.externalLoading = isLoading } }
    public func haptics(_ enabled: Bool) -> KitoButton { mutating { $0.hapticsEnabled = enabled } }
    /// Semantic role (e.g. `.destructive` also switches to the destructive variant).
    public func role(_ role: ButtonRole?) -> KitoButton {
        mutating {
            $0.role = role
            if role == .destructive { $0.variant = .destructive }
        }
    }
    public func iconPlacement(_ placement: KitoIconPlacement) -> KitoButton { mutating { $0.iconPlacement = placement } }
}
