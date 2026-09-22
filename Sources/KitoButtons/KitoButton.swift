//
//  KitoButton.swift
//  KitoButtons
//
//  Created by Wycliff Njenga on 16/09/2026.
//  Copyright © 2026 Wycliff Njenga. All rights reserved.
//

import SwiftUI

public enum KitoIconPlacement: Sendable { case leading, trailing }

/// How a `KitoButton`'s content lays out horizontally. Only `.spaceBetween` changes anything on
/// its own (it inserts a spacer between the title and a trailing slot); `.leading`/`.trailing`
/// only matter once the button is wider than its content, e.g. via `.fullWidth()`.
public enum KitoButtonContentAlignment: Sendable, Equatable {
    case leading, center, trailing, spaceBetween
}

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
    /// Overrides `theme.shape` for this style instance; nil keeps the theme's shape.
    public var shape: KitoButtonShape?
    /// Overrides the default horizontal padding for this style instance; nil keeps the default.
    public var contentPadding: EdgeInsets?
    /// Overrides `theme.disabledStyle` for this style instance; nil keeps the theme's style.
    public var disabledStyle: KitoButtonDisabledStyle?
    /// Overrides `theme.pressedStyle` for this style instance; nil keeps the theme's style.
    public var pressedStyle: KitoButtonPressedStyle?

    @Environment(\.kitoButtonTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(_ variant: KitoButtonVariant = .primary, size: KitoButtonSize = .medium, fullWidth: Bool = false, loading: Bool = false, shape: KitoButtonShape? = nil, contentPadding: EdgeInsets? = nil, disabledStyle: KitoButtonDisabledStyle? = nil, pressedStyle: KitoButtonPressedStyle? = nil) {
        self.init(variant, size: size, fullWidth: fullWidth, phase: loading ? .loading : .idle, shape: shape, contentPadding: contentPadding, disabledStyle: disabledStyle, pressedStyle: pressedStyle)
    }

    public init(_ variant: KitoButtonVariant = .primary, size: KitoButtonSize = .medium, fullWidth: Bool = false, phase: KitoButtonPhase, shape: KitoButtonShape? = nil, contentPadding: EdgeInsets? = nil, disabledStyle: KitoButtonDisabledStyle? = nil, pressedStyle: KitoButtonPressedStyle? = nil) {
        self.variant = variant
        self.size = size
        self.isFullWidth = fullWidth
        self.phase = phase
        self.shape = shape
        self.contentPadding = contentPadding
        self.disabledStyle = disabledStyle
        self.pressedStyle = pressedStyle
    }

    public func makeBody(configuration: Configuration) -> some View {
        let colors = resolvedColors
        let pressed = configuration.isPressed
        let isLink = variant == .link
        let effectiveShape = shape ?? theme.shape
        let effectivePressedStyle = pressedStyle ?? theme.pressedStyle
        let effectiveDisabledStyle = disabledStyle ?? theme.disabledStyle
        let defaultPadding = EdgeInsets(top: 0, leading: isLink ? 0 : size.horizontalPadding, bottom: 0, trailing: isLink ? 0 : size.horizontalPadding)
        let backgroundFill = (pressed && effectivePressedStyle != .none) ? colors.pressedBackground : colors.background

        configuration.label
            .font(theme.font(for: size))
            .foregroundColor(colors.foreground)
            .modifier(LinkUnderline(enabled: isLink && theme.underlinesLink, color: colors.foreground))
            .opacity(phase == .loading ? 0 : 1)
            .overlay {
                if phase == .loading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(theme.loadingForeground ?? colors.foreground)
                        .scaleEffect(size == .small ? 0.8 : 1)
                        .transition(.opacity)
                }
            }
            .padding(contentPadding ?? defaultPadding)
            .frame(maxWidth: isFullWidth && !isLink ? .infinity : nil)
            .frame(minHeight: isLink ? nil : size.height)
            .background {
                if !isLink {
                    KitoButtonOutline(effectiveShape)
                        .fill(backgroundFill)
                        .overlay {
                            if colors.border != .clear {
                                KitoButtonOutline(effectiveShape).strokeBorder(colors.border, lineWidth: theme.borderWidth)
                            }
                        }
                        .shadow(color: (isEnabled ? theme.shadow?.color : nil) ?? .clear,
                                radius: theme.shadow?.radius ?? 0,
                                x: theme.shadow?.x ?? 0,
                                y: theme.shadow?.y ?? 0)
                }
            }
            .contentShape(KitoButtonOutline(effectiveShape))
            .scaleEffect(pressed && !isLink && !reduceMotion && effectivePressedStyle == .scale ? theme.pressedScale : 1)
            .opacity(KitoButtonStyle.resolvedOpacity(isEnabled: isEnabled, phase: phase, pressed: pressed, disabledOpacity: theme.disabledOpacity, pressedOpacity: theme.pressedOpacity, disabledStyle: effectiveDisabledStyle, pressedStyle: effectivePressedStyle))
            .animation(theme.motion(reducesMotion: reduceMotion).press, value: pressed)
            .animation(theme.motion(reducesMotion: reduceMotion).morph, value: phase)
    }

    /// Extracted so it's testable without a view-hosting harness.
    static func resolvedOpacity(isEnabled: Bool, phase: KitoButtonPhase, pressed: Bool, disabledOpacity: Double, pressedOpacity: Double, disabledStyle: KitoButtonDisabledStyle, pressedStyle: KitoButtonPressedStyle) -> Double {
        if !isEnabled, phase == .idle, disabledStyle == .faded { return disabledOpacity }
        if pressed, pressedStyle == .scale { return pressedOpacity }
        return 1
    }

    /// Variant colours, recoloured for disabled/loading/success/failure phases.
    private var resolvedColors: KitoButtonColors {
        KitoButtonStyle.resolvedColors(
            base: theme.colors(for: variant),
            isEnabled: isEnabled,
            phase: phase,
            disabledStyle: disabledStyle ?? theme.disabledStyle,
            loadingBackground: theme.loadingBackground,
            loadingForeground: theme.loadingForeground,
            successColor: theme.successColor,
            failureColor: theme.failureColor,
            variant: variant
        )
    }

    /// Extracted so it's testable without a view-hosting harness.
    static func resolvedColors(base: KitoButtonColors, isEnabled: Bool, phase: KitoButtonPhase, disabledStyle: KitoButtonDisabledStyle, loadingBackground: Color?, loadingForeground: Color?, successColor: Color, failureColor: Color, variant: KitoButtonVariant) -> KitoButtonColors {
        if !isEnabled, phase == .idle {
            switch disabledStyle {
            case .faded:
                break
            case .filled(let background, let foreground):
                return KitoButtonColors(background: background, foreground: foreground, pressedBackground: background)
            case .outlined:
                return KitoButtonColors(background: .clear, foreground: .secondary, border: base.foreground.opacity(0.35), pressedBackground: .clear)
            }
        }
        if phase == .loading, loadingBackground != nil || loadingForeground != nil {
            let background = loadingBackground ?? base.background
            return KitoButtonColors(background: background, foreground: loadingForeground ?? base.foreground, border: base.border == .clear ? .clear : (loadingBackground ?? base.border), pressedBackground: background)
        }
        let accent: Color?
        switch phase {
        case .success: accent = successColor
        case .failure: accent = failureColor
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
    /// Fallback accessibility label for icon-only buttons (set by the icon-only initializers).
    /// Not a real `.accessibilityHint` — see `hintText` for that.
    private var accessibilityLabelFallback: String?
    // Internal, not private: read back directly in tests without a view-hosting harness.
    var accessibilityIdentifierValue: String?
    var hintText: String?
    var leadingSlot: (() -> AnyView)?
    var trailingSlot: (() -> AnyView)?
    var labelOverride: (() -> AnyView)?
    var subtitleText: String?
    var contentAlignmentValue: KitoButtonContentAlignment = .center
    var shapeOverride: KitoButtonShape?
    var contentPaddingOverride: EdgeInsets?
    var minWidthOverride: CGFloat?
    var disabledStyleOverride: KitoButtonDisabledStyle?
    var pressedStyleOverride: KitoButtonPressedStyle?
    private var flight: FlightRequest?
    private let syncAction: (() -> Void)?
    private let asyncAction: (() async throws -> Void)?

    @State private var internalPhase: KitoButtonPhase = .idle
    @State private var shakes: CGFloat = 0
    @State private var sourceID = UUID()
    @Environment(\.kitoButtonTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
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
        self.accessibilityLabelFallback = accessibilityLabel
    }

    /// Icon-only async button.
    public init(systemImage: String, accessibilityLabel: String, action: @escaping () async throws -> Void) {
        self.title = nil; self.systemImage = systemImage; self.image = nil
        self.iconPlacement = .leading; syncAction = nil; asyncAction = action
        self.accessibilityLabelFallback = accessibilityLabel
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
            content
                .frame(minWidth: minWidthOverride ?? (title == nil && labelOverride == nil ? size.height - (variant == .link ? 0 : size.horizontalPadding * 2) : nil))
                .animation(motion.morph, value: phase)
        }
        .kitoAccessibilityIdentifier(accessibilityIdentifierValue)
        .buttonStyle(KitoButtonStyle(variant, size: size, fullWidth: isFullWidth, phase: phase, shape: shapeOverride, contentPadding: contentPaddingOverride, disabledStyle: disabledStyleOverride, pressedStyle: pressedStyleOverride))
        .disabled(phase != .idle)
        .modifier(KitoButtonShakeEffect(shakes: shakes))
        .background(anchorReader)
        // 44x44pt minimum hit target for compact variants, without growing the drawn chrome.
        .modifier(KitoHitTargetModifier(active: expandsHitTarget))
        .accessibilityLabel(displayedTitle ?? accessibilityLabelFallback ?? "")
        .kitoAccessibilityHint(hintText)
        .accessibilityAddTraits(phase == .loading ? .updatesFrequently : [])
        .accessibilityValue(accessibilityValue)
        .onChange(of: phase) { newPhase in
            guard newPhase == .loading else { return }
            #if os(iOS)
            UIAccessibility.post(notification: .announcement, argument: KitoButtonsLocalization.string("phase.inProgress", "In progress"))
            #endif
        }
    }

    /// Small/link buttons can draw well under the 44x44pt minimum recommended tap target; expand
    /// only their tappable area (not their visible size) to meet it. Internal, not private: read
    /// directly in tests without a view-hosting harness.
    var expandsHitTarget: Bool {
        (size == .small || variant == .link) && !isFullWidth
    }

    @ViewBuilder private var content: some View {
        if let labelOverride {
            labelOverride()
        } else {
            HStack(spacing: theme.iconSpacing) {
                leadingElement
                titleBlock
                if contentAlignmentValue == .spaceBetween { Spacer(minLength: 8) }
                trailingElement
            }
            .frame(maxWidth: (isFullWidth && contentAlignmentValue != .center) ? .infinity : nil, alignment: contentFrameAlignment)
        }
    }

    @ViewBuilder private var leadingElement: some View {
        if let leadingSlot {
            leadingSlot()
        } else if iconPlacement == .leading {
            icon
        }
    }

    @ViewBuilder private var trailingElement: some View {
        if let trailingSlot {
            trailingSlot()
        } else if iconPlacement == .trailing {
            icon
        }
    }

    @ViewBuilder private var titleBlock: some View {
        if let displayedTitle {
            VStack(alignment: titleBlockAlignment, spacing: 1) {
                Text(displayedTitle)
                    // At accessibility Dynamic Type sizes, wrap onto a second line instead of
                    // scaling text down below what the user asked for.
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                    .minimumScaleFactor(dynamicTypeSize.isAccessibilitySize ? 1 : 0.8)
                    .multilineTextAlignment(.center)
                    .id(displayedTitle)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                if let subtitleText {
                    Text(subtitleText)
                        .font(.caption)
                        .opacity(0.75)
                        .lineLimit(1)
                }
            }
        }
    }

    var titleBlockAlignment: HorizontalAlignment {
        switch contentAlignmentValue {
        case .trailing: return .trailing
        case .leading, .spaceBetween: return .leading
        case .center: return .center
        }
    }

    var contentFrameAlignment: Alignment {
        switch contentAlignmentValue {
        case .leading, .spaceBetween: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
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

    // MARK: Identifiers and content slots

    /// Reaches the button XCUITest actually taps, e.g. `app.buttons["checkout.pay"]`.
    public func accessibilityIdentifier(_ id: String) -> KitoButton { mutating { $0.accessibilityIdentifierValue = id } }
    /// A genuine VoiceOver hint ("Double tap to pay"), read after the label. Distinct from the
    /// `accessibilityLabel:` initializer parameter, which is the label itself.
    public func accessibilityHint(_ hint: String) -> KitoButton { mutating { $0.hintText = hint } }

    /// Content before the title, replacing the plain icon in that position (a flag, a composed
    /// view). Inherits the variant's foreground colour unless the view sets its own.
    public func leading<V: View>(@ViewBuilder _ content: @escaping () -> V) -> KitoButton { mutating { $0.leadingSlot = { AnyView(content()) } } }
    /// Content after the title, replacing the plain icon in that position (a chevron, a price).
    public func trailing<V: View>(@ViewBuilder _ content: @escaping () -> V) -> KitoButton { mutating { $0.trailingSlot = { AnyView(content()) } } }
    /// Replaces the whole title/icon row with your own view. Phase (loading spinner, shake,
    /// success/failure chrome) still applies around it.
    public func label<V: View>(@ViewBuilder _ content: @escaping () -> V) -> KitoButton { mutating { $0.labelOverride = { AnyView(content()) } } }
    /// A second, smaller line under the title.
    public func subtitle(_ text: String?) -> KitoButton { mutating { $0.subtitleText = text } }
    /// How the title/slots distribute horizontally. `.spaceBetween` only has room to work once the
    /// button is wider than its content, e.g. via `.fullWidth()`.
    public func contentAlignment(_ alignment: KitoButtonContentAlignment) -> KitoButton { mutating { $0.contentAlignmentValue = alignment } }

    /// Overrides `theme.shape` for this button only.
    public func shape(_ shape: KitoButtonShape?) -> KitoButton { mutating { $0.shapeOverride = shape } }
    /// A minimum width beyond `KitoButtonSize`'s own metrics, e.g. to line up buttons of different
    /// titles in a row.
    public func minWidth(_ width: CGFloat?) -> KitoButton { mutating { $0.minWidthOverride = width } }
    /// Overrides the size's default horizontal padding with explicit insets.
    public func contentPadding(_ insets: EdgeInsets?) -> KitoButton { mutating { $0.contentPaddingOverride = insets } }
    /// Overrides `theme.disabledStyle` for this button only.
    public func disabledStyle(_ style: KitoButtonDisabledStyle?) -> KitoButton { mutating { $0.disabledStyleOverride = style } }
    /// Overrides `theme.pressedStyle` for this button only.
    public func pressedStyle(_ style: KitoButtonPressedStyle?) -> KitoButton { mutating { $0.pressedStyleOverride = style } }
}


/// Applies `.underline` where the API exists (iOS 16 / macOS 13); older systems draw the plain title.
struct LinkUnderline: ViewModifier {
    let enabled: Bool
    let color: Color
    func body(content: Content) -> some View {
        if enabled, #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *) {
            content.underline(true, color: color)
        } else {
            content
        }
    }
}

/// Expands a view's tappable area to at least 44x44pt via its frame, without changing what's
/// drawn. Inactive is a pure passthrough so buttons that don't need it render byte-for-byte the
/// same as before this existed.
struct KitoHitTargetModifier: ViewModifier {
    let active: Bool
    func body(content: Content) -> some View {
        if active {
            content.frame(minWidth: 44, minHeight: 44).contentShape(Rectangle())
        } else {
            content
        }
    }
}
