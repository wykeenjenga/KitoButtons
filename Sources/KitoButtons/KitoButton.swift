//
//  KitoButton.swift
//  KitoButtons
//
//  Created by Wycliff Njenga on 16/09/2026.
//  Copyright © 2026 Wycliff Njenga. All rights reserved.
//

import SwiftUI

public enum KitoIconPlacement: Sendable { case leading, trailing }

/// A native `ButtonStyle` that draws KitoButtons chrome. Use directly on any `Button`, or through `KitoButton`.
///
/// ```swift
/// Button("Save") { save() }.buttonStyle(.kito(.primary))
/// ```
public struct KitoButtonStyle: ButtonStyle {
    public var variant: KitoButtonVariant
    public var size: KitoButtonSize
    public var isFullWidth: Bool
    public var phase: KitoButtonPhase

    @Environment(\.kitoButtonTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(_ variant: KitoButtonVariant = .primary, size: KitoButtonSize = .medium, fullWidth: Bool = false, loading: Bool = false) {
        self.init(variant, size: size, fullWidth: fullWidth, phase: loading ? .loading : .idle)
    }

    public init(_ variant: KitoButtonVariant = .primary, size: KitoButtonSize = .medium, fullWidth: Bool = false, phase: KitoButtonPhase) {
        self.variant = variant
        self.size = size
        self.isFullWidth = fullWidth
        self.phase = phase
    }

    public func makeBody(configuration: Configuration) -> some View {
        let colors = resolvedColors
        let pressed = configuration.isPressed
        let isLink = variant == .link

        configuration.label
            .font(size.font)
            .foregroundColor(colors.foreground)
            .opacity(phase == .loading ? 0 : 1)
            .overlay {
                if phase == .loading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(colors.foreground)
                        .scaleEffect(size == .small ? 0.8 : 1)
                        .transition(.opacity)
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
            .scaleEffect(pressed && !isLink && !reduceMotion ? theme.pressedScale : 1)
            .opacity(!isEnabled && phase == .idle ? theme.disabledOpacity : (pressed ? theme.pressedOpacity : 1))
            .animation(theme.motion(reducesMotion: reduceMotion).press, value: pressed)
            .animation(theme.motion(reducesMotion: reduceMotion).morph, value: phase)
    }

    /// Variant colours, recoloured for success/failure phases.
    private var resolvedColors: KitoButtonColors {
        let base = theme.colors(for: variant)
        let accent: Color?
        switch phase {
        case .success: accent = theme.successColor
        case .failure: accent = theme.failureColor
        default: accent = nil
        }
        guard let accent else { return base }
        switch variant {
        case .primary, .destructive:
            return KitoButtonColors(background: accent, foreground: base.foreground, pressedBackground: accent.opacity(0.8))
        case .tonal:
            return KitoButtonColors(background: accent.opacity(0.14), foreground: accent, pressedBackground: accent.opacity(0.24))
        case .outlined:
            return KitoButtonColors(background: .clear, foreground: accent, border: accent, pressedBackground: accent.opacity(0.1))
        case .ghost, .link:
            return KitoButtonColors(background: .clear, foreground: accent, pressedBackground: accent.opacity(0.1))
        }
    }
}

public extension ButtonStyle where Self == KitoButtonStyle {
    static func kito(_ variant: KitoButtonVariant = .primary, size: KitoButtonSize = .medium, fullWidth: Bool = false, loading: Bool = false) -> KitoButtonStyle {
        KitoButtonStyle(variant, size: size, fullWidth: fullWidth, loading: loading)
    }
    static func kito(_ variant: KitoButtonVariant = .primary, size: KitoButtonSize = .medium, fullWidth: Bool = false, phase: KitoButtonPhase) -> KitoButtonStyle {
        KitoButtonStyle(variant, size: size, fullWidth: fullWidth, phase: phase)
    }
}

/// Comprehensive button: variants, sizes, icons, loading/success/failure phases with icon morphing,
/// full width, async actions and fly-to-target hooks.
///
/// ```swift
/// KitoButton("Add to cart", systemImage: "cart.badge.plus") {
///     try await cart.add(product)        // spinner → tick, or shake + ✕ if it throws
/// }
/// .showsResult()
/// .successTitle("Added")
/// .flies(to: "cart", with: flights) { Image(product.image) }
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
    private var phaseBinding: Binding<KitoButtonPhase>? = nil
    private var showsSuccess = false
    private var showsFailure = false
    private var successTitle: String?
    private var failureTitle: String?
    private var successSystemImage = "checkmark"
    private var failureSystemImage = "xmark"
    private var hapticsEnabled = true
    private var role: ButtonRole? = nil
    private var accessibilityHint: String?
    private var flight: FlightRequest?
    private let syncAction: (() -> Void)?
    private let asyncAction: (() async throws -> Void)?

    @State private var internalPhase: KitoButtonPhase = .idle
    @State private var shakes: CGFloat = 0
    @State private var sourceID = UUID()
    @Environment(\.kitoButtonTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var motion: KitoButtonMotion { theme.motion(reducesMotion: reduceMotion) }

    private struct FlightRequest {
        let controller: KitoFlightController
        let target: AnyHashable
        let size: CGSize
        let arcHeight: CGFloat
        let content: () -> AnyView
    }

    // MARK: Init

    public init(_ title: String, systemImage: String? = nil, iconPlacement: KitoIconPlacement = .leading, action: @escaping () -> Void) {
        self.title = title; self.systemImage = systemImage; self.image = nil
        self.iconPlacement = iconPlacement; syncAction = action; asyncAction = nil
    }

    /// Async variant: shows a spinner while `action` runs. With `.showsResult()` a thrown error
    /// becomes a shake + failure icon and a normal return becomes a success tick.
    public init(_ title: String, systemImage: String? = nil, iconPlacement: KitoIconPlacement = .leading, action: @escaping () async throws -> Void) {
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

    /// Icon-only async button.
    public init(systemImage: String, accessibilityLabel: String, action: @escaping () async throws -> Void) {
        self.title = nil; self.systemImage = systemImage; self.image = nil
        self.iconPlacement = .leading; syncAction = nil; asyncAction = action
        self.accessibilityHint = accessibilityLabel
    }

    // MARK: Body

    private var phase: KitoButtonPhase {
        if let externalLoading, externalLoading { return .loading }
        return phaseBinding?.wrappedValue ?? internalPhase
    }

    private var displayedTitle: String? {
        switch phase {
        case .success: return successTitle ?? title
        case .failure: return failureTitle ?? title
        default: return title
        }
    }

    public var body: some View {
        Button(role: role, action: perform) {
            HStack(spacing: theme.iconSpacing) {
                if iconPlacement == .leading { icon }
                if let displayedTitle {
                    Text(displayedTitle)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .id(displayedTitle)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
                if iconPlacement == .trailing { icon }
            }
            .frame(minWidth: title == nil ? size.height - (variant == .link ? 0 : size.horizontalPadding * 2) : nil)
            .animation(motion.morph, value: phase)
        }
        .buttonStyle(KitoButtonStyle(variant, size: size, fullWidth: isFullWidth, phase: phase))
        .disabled(phase != .idle)
        .modifier(KitoButtonShakeEffect(shakes: shakes))
        .background(anchorReader)
        .accessibilityLabel(displayedTitle ?? accessibilityHint ?? "")
        .accessibilityAddTraits(phase == .loading ? .updatesFrequently : [])
        .accessibilityValue(accessibilityValue)
    }

    private var accessibilityValue: String {
        switch phase {
        case .idle: return ""
        case .loading: return KitoButtonsLocalization.string("phase.loading", "Loading")
        case .success: return KitoButtonsLocalization.string("phase.succeeded", "Succeeded")
        case .failure: return KitoButtonsLocalization.string("phase.failed", "Failed")
        }
    }

    /// Icon that morphs between the idle glyph and the success/failure glyph.
    @ViewBuilder private var icon: some View {
        ZStack {
            switch phase {
            case .success:
                symbol(successSystemImage).transition(.scale.combined(with: .opacity))
            case .failure:
                symbol(failureSystemImage).transition(.scale.combined(with: .opacity))
            default:
                if let systemImage {
                    symbol(systemImage).transition(.scale.combined(with: .opacity))
                } else if let image {
                    image.resizable().scaledToFit()
                        .frame(width: size.iconSize, height: size.iconSize)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }

    private func symbol(_ name: String) -> some View {
        Image(systemName: name).font(.system(size: size.iconSize, weight: .semibold))
    }

    private var anchorReader: some View {
        GeometryReader { proxy in
            Color.clear.preference(key: KitoFlightFramesKey.self, value: flight.map { _ in [AnyHashable(flightSourceID): proxy.frame(in: .named("KitoFlightSpace"))] } ?? [:])
        }
    }

    private var flightSourceID: String { "kitobutton.\(sourceID.uuidString)" }

    // MARK: Behaviour

    private func perform() {
        haptic()
        launchFlightIfNeeded()
        if let syncAction {
            syncAction()
        } else if let asyncAction {
            guard phase == .idle else { return }
            setPhase(.loading)
            Task { @MainActor in
                do {
                    try await asyncAction()
                    finish(success: true)
                } catch {
                    finish(success: false)
                }
            }
        }
    }

    @MainActor private func finish(success: Bool) {
        let shows = success ? showsSuccess : showsFailure
        guard shows else { setPhase(.idle); return }
        setPhase(success ? .success : .failure)
        if !success {
            if !reduceMotion { withAnimation(motion.shake) { shakes += 1 } }
            #if os(iOS)
            if hapticsEnabled { UINotificationFeedbackGenerator().notificationOccurred(.error) }
            #endif
        } else {
            #if os(iOS)
            if hapticsEnabled { UINotificationFeedbackGenerator().notificationOccurred(.success) }
            #endif
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + motion.resultDuration) {
            if phase != .loading { setPhase(.idle) }
        }
    }

    private func setPhase(_ newPhase: KitoButtonPhase) {
        withAnimation(motion.morph) {
            if let phaseBinding { phaseBinding.wrappedValue = newPhase } else { internalPhase = newPhase }
        }
    }

    private func launchFlightIfNeeded() {
        guard let flight else { return }
        flight.controller.fly(from: AnyHashable(flightSourceID), to: flight.target, size: flight.size, arcHeight: flight.arcHeight) {
            flight.content()
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
    /// Drive or observe the phase from outside (e.g. set `.success` after a websocket ack).
    public func phase(_ binding: Binding<KitoButtonPhase>) -> KitoButton { mutating { $0.phaseBinding = binding } }
    /// After an async action, morph to a tick (and/or shake with a cross on error) before returning to idle.
    public func showsResult(success: Bool = true, failure: Bool = true) -> KitoButton {
        mutating { $0.showsSuccess = success; $0.showsFailure = failure }
    }
    /// Title shown during the success phase ("Added!"). Nil keeps the normal title.
    public func successTitle(_ title: String?) -> KitoButton { mutating { $0.successTitle = title } }
    public func failureTitle(_ title: String?) -> KitoButton { mutating { $0.failureTitle = title } }
    /// Glyphs used in the success/failure phases (default checkmark / xmark).
    public func resultIcons(success: String = "checkmark", failure: String = "xmark") -> KitoButton {
        mutating { $0.successSystemImage = success; $0.failureSystemImage = failure }
    }
    public func haptics(_ enabled: Bool) -> KitoButton { mutating { $0.hapticsEnabled = enabled } }
    /// Semantic role (e.g. `.destructive` also switches to the destructive variant).
    public func role(_ role: ButtonRole?) -> KitoButton {
        mutating {
            $0.role = role
            if role == .destructive { $0.variant = .destructive }
        }
    }
    public func iconPlacement(_ placement: KitoIconPlacement) -> KitoButton { mutating { $0.iconPlacement = placement } }

    /// On tap, flies `content` from this button to the anchor named `target` (see `KitoFlightController`).
    public func flies<Content: View, Target: Hashable>(to target: Target, with controller: KitoFlightController, size: CGSize = CGSize(width: 44, height: 44), arcHeight: CGFloat = 120, @ViewBuilder content: @escaping () -> Content) -> KitoButton {
        mutating {
            $0.flight = FlightRequest(controller: controller, target: AnyHashable(target), size: size, arcHeight: arcHeight, content: { AnyView(content()) })
        }
    }
}
