//
//  KitoCartButton.swift
//  KitoButtons
//
//  Created by Wycliff Njenga on 16/09/2026.
//  Copyright © 2026 Wycliff Njenga. All rights reserved.
//

import SwiftUI

/// Choreographed add-to-cart animations, in the spirit of the popular Lottie "add to cart" buttons.
/// Each style is a time-based timeline rendered natively in SwiftUI (no Lottie dependency).
public enum KitoCartAnimation: String, CaseIterable, Identifiable, Sendable {
    /// Label slides away, a cart rolls in from the left, the product drops into it, the cart rolls
    /// off to the right and "Added ✓" appears.
    case rollingCart
    /// The product falls from above into the cart icon, which squashes and bounces; a badge pops.
    case dropIn
    /// The button squeezes into a circle with a spinner, a tick draws itself with a burst, then the
    /// button expands back with the added title.
    case morphCircle
    /// The plus icon spins into a tick while particles burst outward.
    case burst
    /// The whole button flips over (3D) to reveal the added state.
    case flip
    /// A success-coloured fill sweeps across the button and a tick draws itself.
    case fillSweep
    /// The cart jumps, a plus falls into it, the cart wiggles and the badge pops.
    case bounceCart

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .rollingCart: return "Rolling cart"
        case .dropIn: return "Drop in"
        case .morphCircle: return "Morph to circle"
        case .burst: return "Burst"
        case .flip: return "Flip"
        case .fillSweep: return "Fill sweep"
        case .bounceCart: return "Bounce cart"
        }
    }

    /// Fraction of the timeline at which the item "lands" (badge increments, flights launch).
    var landingPoint: Double {
        switch self {
        case .rollingCart: return 0.5
        case .dropIn: return 0.45
        case .morphCircle: return 0.62
        case .burst: return 0.35
        case .flip: return 0.5
        case .fillSweep: return 0.5
        case .bounceCart: return 0.45
        }
    }

    var defaultDuration: TimeInterval {
        switch self {
        case .rollingCart: return 1.8
        case .morphCircle: return 1.9
        default: return 1.3
        }
    }
}

/// Easing helpers shared by the choreographies.
public enum KitoEase {
    /// Normalised progress of `p` inside the segment [a, b], clamped to 0...1.
    public static func segment(_ p: Double, _ a: Double, _ b: Double) -> Double {
        guard b > a else { return p >= b ? 1 : 0 }
        return min(max((p - a) / (b - a), 0), 1)
    }
    public static func outCubic(_ t: Double) -> Double { 1 - pow(1 - t, 3) }
    public static func inCubic(_ t: Double) -> Double { t * t * t }
    public static func inOutCubic(_ t: Double) -> Double { t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2 }
    public static func outBack(_ t: Double, overshoot: Double = 1.70158) -> Double {
        let c3 = overshoot + 1
        return 1 + c3 * pow(t - 1, 3) + overshoot * pow(t - 1, 2)
    }
    public static func outBounce(_ t: Double) -> Double {
        let n1 = 7.5625, d1 = 2.75
        if t < 1 / d1 { return n1 * t * t }
        if t < 2 / d1 { let x = t - 1.5 / d1; return n1 * x * x + 0.75 }
        if t < 2.5 / d1 { let x = t - 2.25 / d1; return n1 * x * x + 0.9375 }
        let x = t - 2.625 / d1
        return n1 * x * x + 0.984375
    }
    /// 0 → 1 → 0 hump centred in the segment.
    public static func pulse(_ t: Double) -> Double { sin(t * .pi) }
    public static func lerp(_ a: CGFloat, _ b: CGFloat, _ t: Double) -> CGFloat { a + (b - a) * CGFloat(t) }
}

// MARK: - Drawing primitives (public so you can reuse them)

/// A tick you can draw progressively with `.trim(from:to:)`.
public struct KitoCheckmarkShape: Shape {
    public init() {}
    public func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX + rect.width * 0.12, y: rect.midY + rect.height * 0.05))
        p.addLine(to: CGPoint(x: rect.minX + rect.width * 0.40, y: rect.maxY - rect.height * 0.15))
        p.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.10, y: rect.minY + rect.height * 0.22))
        return p
    }
}

/// Radial particle burst; `progress` 0...1.
public struct KitoBurst: View {
    public var progress: Double
    public var color: Color
    public var count: Int
    public var radius: CGFloat

    public init(progress: Double, color: Color, count: Int = 10, radius: CGFloat = 34) {
        self.progress = progress; self.color = color; self.count = count; self.radius = radius
    }

    public var body: some View {
        let t = KitoEase.outCubic(progress)
        ZStack {
            ForEach(0..<count, id: \.self) { i in
                let angle = Double(i) / Double(count) * 2 * .pi
                let r = radius * CGFloat(t)
                let size = CGFloat(6 - 4 * t) * (i.isMultiple(of: 2) ? 1 : 0.7)
                Circle()
                    .fill(color)
                    .frame(width: max(size, 0.5), height: max(size, 0.5))
                    .offset(x: cos(angle) * r, y: sin(angle) * r)
                    .opacity(progress > 0 && progress < 1 ? 1 - t : 0)
            }
        }
    }
}

/// Minimal press feedback used by the cart button (the chrome is drawn by the choreography).
struct KitoPressStyle: ButtonStyle {
    var scale: CGFloat
    var animation: Animation
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(animation, value: configuration.isPressed)
    }
}

// MARK: - Button

/// Add-to-cart button with a built-in choreographed animation.
///
/// ```swift
/// KitoCartButton("Add to cart", animation: .rollingCart) {
///     try await cart.add(product)
/// }
/// .addedTitle("Added")
/// .onAdded { cart.count += 1 }
/// .flies(to: "cart", with: flights) { Image(product.image) }   // optional flight at landing
/// ```
///
/// The timeline is time-based like a Lottie file (`duration`), so it plays the same whether the
/// action returns instantly or after a second. If the action throws, the button shakes and resets.
public struct KitoCartButton: View {
    private let title: String
    private let animation: KitoCartAnimation
    private let action: () async throws -> Void
    private var addedTitle = KitoButtonsLocalization.string("cart.added", "Added")
    private var variant: KitoButtonVariant = .primary
    private var size: KitoButtonSize = .medium
    private var isFullWidth = false
    private var duration: TimeInterval?
    private var holdDuration: TimeInterval = 1.0
    private var hapticsEnabled = true
    private var onAdded: (() -> Void)?
    private var flight: (controller: KitoFlightController, target: AnyHashable, size: CGSize, arcHeight: CGFloat, content: () -> AnyView)?

    @State private var progress: Double = 0
    @State private var isPlaying = false
    @State private var contentOpacity: Double = 1
    @State private var shakes: CGFloat = 0
    @State private var sourceID = UUID()
    @Environment(\.kitoButtonTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(_ title: String = KitoButtonsLocalization.string("cart.addToCart", "Add to cart"), animation: KitoCartAnimation = .rollingCart, action: @escaping () async throws -> Void) {
        self.title = title
        self.animation = animation
        self.action = action
    }

    public init(_ title: String = KitoButtonsLocalization.string("cart.addToCart", "Add to cart"), animation: KitoCartAnimation = .rollingCart, action: @escaping () -> Void) {
        self.init(title, animation: animation, action: { @Sendable in action() } as () async throws -> Void)
    }

    public var body: some View {
        Button(action: play) {
            KitoCartChoreography(
                progress: progress,
                style: animation,
                title: title,
                addedTitle: addedTitle,
                size: size,
                titleFont: theme.font(for: size),
                colors: theme.colors(for: variant),
                successColor: theme.successColor,
                shape: theme.shape,
                borderWidth: theme.borderWidth,
                fullWidth: isFullWidth
            )
            .opacity(contentOpacity)
            .background(GeometryReader { proxy in
                Color.clear
                    .preference(key: KitoFlightFramesKey.self, value: flight == nil ? [:] : [AnyHashable("kitocart.\(sourceID.uuidString)"): proxy.frame(in: .named("KitoFlightSpace"))])
            })
        }
        .buttonStyle(KitoPressStyle(scale: reduceMotion ? 1 : theme.pressedScale, animation: theme.motion(reducesMotion: reduceMotion).press))
        .disabled(isPlaying)
        .opacity(isEnabled ? 1 : theme.disabledOpacity)
        .modifier(KitoButtonShakeEffect(shakes: shakes))
        .accessibilityLabel(title)
        .accessibilityValue(isPlaying ? KitoButtonsLocalization.string("cart.adding", "Adding") : "")
    }

    // MARK: Playback

    private var resolvedDuration: TimeInterval { duration ?? animation.defaultDuration }

    private func play() {
        guard !isPlaying else { return }
        isPlaying = true
        #if os(iOS)
        if hapticsEnabled { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
        #endif
        // Reduce Motion: crossfade straight to the added state instead of playing the choreography.
        let total = reduceMotion ? 0.35 : resolvedDuration
        if reduceMotion {
            withAnimation(.easeOut(duration: 0.15)) { contentOpacity = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                var transaction = Transaction(); transaction.disablesAnimations = true
                withTransaction(transaction) { progress = 1 }
                withAnimation(.easeIn(duration: 0.15)) { contentOpacity = 1 }
            }
        } else {
            withAnimation(.linear(duration: total)) { progress = 1 }
        }

        let landing = reduceMotion ? 0.2 : total * animation.landingPoint
        DispatchQueue.main.asyncAfter(deadline: .now() + landing) {
            guard isPlaying else { return }
            #if os(iOS)
            if hapticsEnabled { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
            #endif
            launchFlight()
            onAdded?()
        }

        Task { @MainActor in
            do {
                try await action()
                // Let the choreography finish, hold the added state, then fade back to idle.
                let elapsed = 0.0
                try? await Task.sleep(nanoseconds: UInt64(max(0, total - elapsed + holdDuration) * 1_000_000_000))
                await reset()
            } catch {
                withAnimation(theme.motion.shake) { shakes += 1 }
                #if os(iOS)
                if hapticsEnabled { UINotificationFeedbackGenerator().notificationOccurred(.error) }
                #endif
                await reset()
            }
        }
    }

    @MainActor private func reset() async {
        withAnimation(.easeOut(duration: 0.15)) { contentOpacity = 0 }
        try? await Task.sleep(nanoseconds: 160_000_000)
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) { progress = 0 }
        withAnimation(.easeIn(duration: 0.2)) { contentOpacity = 1 }
        isPlaying = false
    }

    private func launchFlight() {
        guard let flight else { return }
        flight.controller.fly(from: AnyHashable("kitocart.\(sourceID.uuidString)"), to: flight.target, size: flight.size, arcHeight: flight.arcHeight) {
            flight.content()
        }
    }

    // MARK: Fluent configuration

    private func mutating(_ change: (inout KitoCartButton) -> Void) -> KitoCartButton {
        var copy = self
        change(&copy)
        return copy
    }

    /// Title shown once the item has been added.
    public func addedTitle(_ title: String) -> KitoCartButton { mutating { $0.addedTitle = title } }
    public func variant(_ variant: KitoButtonVariant) -> KitoCartButton { mutating { $0.variant = variant } }
    public func size(_ size: KitoButtonSize) -> KitoCartButton { mutating { $0.size = size } }
    public func fullWidth(_ enabled: Bool = true) -> KitoCartButton { mutating { $0.isFullWidth = enabled } }
    /// Length of the choreography. Each style has a tuned default.
    public func duration(_ seconds: TimeInterval) -> KitoCartButton { mutating { $0.duration = seconds } }
    /// How long the added state stays before fading back to idle.
    public func hold(_ seconds: TimeInterval) -> KitoCartButton { mutating { $0.holdDuration = seconds } }
    public func haptics(_ enabled: Bool) -> KitoCartButton { mutating { $0.hapticsEnabled = enabled } }
    /// Called at the landing moment of the animation (the natural place to bump a badge count).
    public func onAdded(_ handler: @escaping () -> Void) -> KitoCartButton { mutating { $0.onAdded = handler } }
    /// Also fly `content` from this button to a `kitoFlightAnchor` when the item lands.
    public func flies<Content: View, Target: Hashable>(to target: Target, with controller: KitoFlightController, size: CGSize = CGSize(width: 44, height: 44), arcHeight: CGFloat = 120, @ViewBuilder content: @escaping () -> Content) -> KitoCartButton {
        mutating { $0.flight = (controller, AnyHashable(target), size, arcHeight, { AnyView(content()) }) }
    }
}

// MARK: - Choreography

/// Renders one frame of a cart animation for `progress` in 0...1. Being `Animatable`, SwiftUI
/// re-renders it every frame while `progress` animates, so every sub-motion can be derived from a
/// single timeline exactly like a Lottie file.
struct KitoCartChoreography: View, Animatable {
    var progress: Double
    let style: KitoCartAnimation
    let title: String
    let addedTitle: String
    let size: KitoButtonSize
    /// Resolved by the caller (`theme.font(for: size)`), since this view has no environment
    /// access of its own — everything it draws with comes in through its init.
    let titleFont: Font
    let colors: KitoButtonColors
    let successColor: Color
    let shape: KitoButtonShape
    let borderWidth: CGFloat
    let fullWidth: Bool

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    private var p: Double { progress }
    private var height: CGFloat { size.height }
    private var icon: CGFloat { size.iconSize + 2 }
    private var isCollapsedShape: Bool { if case .capsule = shape { return true }; return false }

    var body: some View {
        switch style {
        case .rollingCart: rollingCart
        case .dropIn: dropIn
        case .morphCircle: morphCircle
        case .burst: burst
        case .flip: flip
        case .fillSweep: fillSweep
        case .bounceCart: bounceCart
        }
    }

    // MARK: Shared pieces

    private func chrome(fill: Color? = nil, border: Color? = nil, cornerRadius: CGFloat? = nil) -> some View {
        let outline = KitoButtonOutline(cornerRadius.map { .roundedRectangle(cornerRadius: $0) } ?? shape)
        return outline
            .fill(fill ?? colors.background)
            .overlay {
                if (border ?? colors.border) != .clear {
                    outline.strokeBorder(border ?? colors.border, lineWidth: borderWidth)
                }
            }
    }

    private func label(_ text: String, color: Color? = nil) -> some View {
        Text(text)
            .font(titleFont)
            .foregroundColor(color ?? colors.foreground)
            .lineLimit(1)
    }

    private func symbol(_ name: String, color: Color? = nil, scale: CGFloat = 1) -> some View {
        Image(systemName: name)
            .font(.system(size: icon * scale, weight: .semibold))
            .foregroundColor(color ?? colors.foreground)
    }

    private func check(_ t: Double, color: Color? = nil, lineWidth: CGFloat = 2.5, side: CGFloat? = nil) -> some View {
        KitoCheckmarkShape()
            .trim(from: 0, to: CGFloat(t))
            .stroke(color ?? colors.foreground, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            .frame(width: side ?? icon, height: side ?? icon)
    }

    private var product: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(colors.foreground)
            .frame(width: icon * 0.55, height: icon * 0.55)
            .overlay(RoundedRectangle(cornerRadius: 3).stroke(colors.background.opacity(0.6), lineWidth: 1))
    }

    /// Gives width-dependent choreographies an intrinsic size: the wider of the idle and added
    /// labels (or the full available width), then hands the measured width to `content`.
    private func sized<Content: View>(@ViewBuilder _ content: @escaping (CGFloat) -> Content) -> some View {
        ZStack {
            HStack(spacing: 8) { symbol("cart.badge.plus"); label(title) }
            HStack(spacing: 8) { check(1); label(addedTitle) }
        }
        .padding(.horizontal, size.horizontalPadding + 4)
        .frame(maxWidth: fullWidth ? .infinity : nil)
        .frame(height: height)
        .opacity(0)
        .accessibilityHidden(true)
        .overlay(GeometryReader { proxy in
            content(proxy.size.width).frame(width: proxy.size.width, height: height)
        })
    }

    private struct IntrinsicFrame: ViewModifier {
        let fullWidth: Bool
        let height: CGFloat
        func body(content: Content) -> some View {
            content.frame(maxWidth: fullWidth ? .infinity : nil).frame(height: height)
        }
    }

    // MARK: 1. Rolling cart

    private var rollingCart: some View {
        let labelOut = KitoEase.outCubic(KitoEase.segment(p, 0.0, 0.15))
        let cartIn = KitoEase.outCubic(KitoEase.segment(p, 0.08, 0.42))
        let cartOut = KitoEase.inCubic(KitoEase.segment(p, 0.62, 0.85))
        let drop = KitoEase.outBounce(KitoEase.segment(p, 0.34, 0.55))
        let added = KitoEase.outBack(KitoEase.segment(p, 0.82, 1.0))
        let wheelSpin = p * 720
        return sized { w in
            let cartX = KitoEase.lerp(-w / 2 - 30, 0, cartIn) + KitoEase.lerp(0, w / 2 + 40, cartOut)
            ZStack {
                chrome()
                HStack(spacing: 8) {
                    symbol("cart.badge.plus")
                    label(title)
                }
                .opacity(1 - labelOut)
                .offset(y: -12 * labelOut)

                // Cart with a rolling wheel hint
                ZStack(alignment: .top) {
                    symbol("cart", scale: 1.25)
                    product
                        .offset(y: KitoEase.lerp(-height * 0.9, -2, drop))
                        .opacity(p > 0.3 && p < 0.86 ? 1 : 0)
                    Circle().fill(colors.foreground).frame(width: 3, height: 3)
                        .offset(x: -icon * 0.28, y: icon * 1.05)
                        .rotationEffect(.degrees(wheelSpin), anchor: .center)
                        .opacity(0)
                }
                .offset(x: cartX, y: -1)
                .opacity(p > 0.05 && p < 0.9 ? 1 : 0)

                HStack(spacing: 8) {
                    check(KitoEase.segment(p, 0.84, 0.96))
                    label(addedTitle)
                }
                .opacity(added)
                .offset(y: 10 * (1 - added))
                .scaleEffect(0.9 + 0.1 * added)
            }
            .clipShape(KitoButtonOutline(shape))
        }
    }

    // MARK: 2. Drop in

    private var dropIn: some View {
        let fall = KitoEase.inCubic(KitoEase.segment(p, 0.1, 0.42))
        let squash = KitoEase.pulse(KitoEase.segment(p, 0.42, 0.6))
        let badge = KitoEase.outBack(KitoEase.segment(p, 0.5, 0.75))
        let swap = KitoEase.inOutCubic(KitoEase.segment(p, 0.55, 0.8))
        return ZStack {
            chrome()
            HStack(spacing: 10) {
                ZStack(alignment: .topTrailing) {
                    ZStack(alignment: .top) {
                        symbol("cart", scale: 1.15)
                            .scaleEffect(x: 1 + 0.12 * squash, y: 1 - 0.18 * squash, anchor: .bottom)
                            .offset(y: -6 * KitoEase.pulse(KitoEase.segment(p, 0.55, 0.8)))
                        product
                            .offset(y: KitoEase.lerp(-height, -3, fall))
                            .opacity(p > 0.08 && p < 0.5 ? 1 : 0)
                            .scaleEffect(1 - 0.35 * KitoEase.segment(p, 0.42, 0.5))
                    }
                    Circle().fill(successColor)
                        .frame(width: 9, height: 9)
                        .overlay(Circle().stroke(colors.background, lineWidth: 1.5))
                        .offset(x: 5, y: -4)
                        .scaleEffect(badge)
                        .opacity(badge > 0 ? 1 : 0)
                }
                .frame(width: icon * 1.4, height: icon * 1.4)
                ZStack(alignment: .leading) {
                    label(title).opacity(1 - swap).offset(y: -8 * swap)
                    label(addedTitle).opacity(swap).offset(y: 8 * (1 - swap))
                }
            }
            .padding(.horizontal, size.horizontalPadding)
        }
        .modifier(IntrinsicFrame(fullWidth: fullWidth, height: height))
        .clipShape(KitoButtonOutline(shape))
    }

    // MARK: 3. Morph to circle

    private var morphCircle: some View {
        let collapse = KitoEase.inOutCubic(KitoEase.segment(p, 0.0, 0.22))
        let expand = KitoEase.outBack(KitoEase.segment(p, 0.84, 1.0), overshoot: 0.8)
        let spinnerOn = p > 0.18 && p < 0.62
        let checkDraw = KitoEase.segment(p, 0.62, 0.78)
        let burstT = KitoEase.segment(p, 0.6, 0.9)
        let accent = p > 0.6 ? successColor : colors.background
        let fillMix = KitoEase.segment(p, 0.6, 0.7)
        return sized { full in
            let width = KitoEase.lerp(full, height, collapse) + KitoEase.lerp(0, full - height, expand)
            let radius: CGFloat = {
                if case .roundedRectangle(let r) = shape { return KitoEase.lerp(r, height / 2, collapse) - KitoEase.lerp(0, height / 2 - r, expand) }
                if case .rectangle = shape { return KitoEase.lerp(0, height / 2, collapse) - KitoEase.lerp(0, height / 2, expand) }
                return height / 2
            }()
            ZStack {
                chrome(fill: fillMix > 0 ? accent.opacity(fillMix) : nil, cornerRadius: radius)
                    .background(chrome(cornerRadius: radius))
                    .frame(width: width, height: height)

                HStack(spacing: 8) {
                    symbol("cart.badge.plus")
                    label(title)
                }
                .opacity(1 - KitoEase.segment(p, 0, 0.12))

                Circle()
                    .trim(from: 0.15, to: 0.85)
                    .stroke(colors.foreground, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .frame(width: icon * 1.1, height: icon * 1.1)
                    .rotationEffect(.degrees(p * 1080))
                    .opacity(spinnerOn ? 1 : 0)

                KitoBurst(progress: burstT, color: successColor, radius: height * 0.9)
                // Centred tick while the button is a circle…
                check(checkDraw, color: colors.foreground, lineWidth: 3, side: icon * 1.2)
                    .scaleEffect(1 + 0.15 * KitoEase.pulse(KitoEase.segment(p, 0.75, 0.9)))
                    .opacity(p > 0.62 ? 1 - expand : 0)
                // …then a normal "✓ Added" row once it has expanded again.
                HStack(spacing: 8) {
                    check(1, color: colors.foreground, lineWidth: 3)
                    label(addedTitle)
                }
                .opacity(expand)
                .scaleEffect(0.9 + 0.1 * expand)
            }
        }
    }

    // MARK: 4. Burst

    private var burst: some View {
        let spin = KitoEase.outBack(KitoEase.segment(p, 0.15, 0.5))
        let burstT = KitoEase.segment(p, 0.3, 0.8)
        let swap = KitoEase.inOutCubic(KitoEase.segment(p, 0.3, 0.6))
        let pulse = KitoEase.pulse(KitoEase.segment(p, 0.25, 0.55))
        return ZStack {
            chrome()
                .scaleEffect(1 + 0.04 * pulse)
            HStack(spacing: 10) {
                ZStack {
                    symbol("plus", scale: 1.1)
                        .rotationEffect(.degrees(90 * spin))
                        .opacity(1 - KitoEase.segment(p, 0.3, 0.42))
                        .scaleEffect(1 - 0.5 * KitoEase.segment(p, 0.3, 0.45))
                    check(KitoEase.segment(p, 0.4, 0.62), color: colors.foreground, lineWidth: 3)
                        .scaleEffect(0.8 + 0.2 * KitoEase.outBack(KitoEase.segment(p, 0.4, 0.7)))
                    KitoBurst(progress: burstT, color: colors.foreground, count: 12, radius: icon * 1.9)
                }
                .frame(width: icon * 1.3, height: icon * 1.3)
                ZStack(alignment: .leading) {
                    label(title).opacity(1 - swap).offset(y: -8 * swap)
                    label(addedTitle).opacity(swap).offset(y: 8 * (1 - swap))
                }
            }
            .padding(.horizontal, size.horizontalPadding)
        }
        .modifier(IntrinsicFrame(fullWidth: fullWidth, height: height))
    }

    // MARK: 5. Flip

    private var flip: some View {
        let turn = KitoEase.inOutCubic(KitoEase.segment(p, 0.05, 0.55))
        let angle = 180 * turn
        let showingBack = angle > 90
        let settle = KitoEase.outBack(KitoEase.segment(p, 0.55, 0.8))
        return ZStack {
            // Front face
            ZStack {
                chrome()
                HStack(spacing: 8) { symbol("cart.badge.plus"); label(title) }
            }
            .opacity(showingBack ? 0 : 1)
            // Back face (pre-rotated so text reads correctly after the flip)
            ZStack {
                chrome(fill: variantAccent(successColor), border: colors.border == .clear ? .clear : successColor)
                HStack(spacing: 8) {
                    check(KitoEase.segment(p, 0.55, 0.75), color: accentForeground(successColor), lineWidth: 3)
                        .scaleEffect(0.8 + 0.2 * settle)
                    label(addedTitle, color: accentForeground(successColor))
                }
            }
            .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
            .opacity(showingBack ? 1 : 0)
        }
        .modifier(IntrinsicFrame(fullWidth: fullWidth, height: height))
        .rotation3DEffect(.degrees(angle), axis: (x: 1, y: 0, z: 0), perspective: 0.6)
    }

    // MARK: 6. Fill sweep

    private var fillSweep: some View {
        let sweep = KitoEase.inOutCubic(KitoEase.segment(p, 0.05, 0.5))
        let checkDraw = KitoEase.segment(p, 0.5, 0.72)
        let swap = KitoEase.inOutCubic(KitoEase.segment(p, 0.45, 0.7))
        let fg = accentForeground(successColor)
        return sized { w in
            ZStack {
                chrome()
                variantAccent(successColor)
                    .frame(width: w * CGFloat(sweep))
                    .frame(width: w, alignment: .leading)
                    .clipShape(KitoButtonOutline(shape))
                HStack(spacing: 10) {
                    ZStack {
                        symbol("cart.badge.plus", color: sweep > 0.5 ? fg : colors.foreground)
                            .opacity(1 - KitoEase.segment(p, 0.45, 0.55))
                        check(checkDraw, color: fg, lineWidth: 3)
                    }
                    .frame(width: icon * 1.2, height: icon * 1.2)
                    ZStack(alignment: .leading) {
                        label(title, color: sweep > 0.5 ? fg : colors.foreground).opacity(1 - swap)
                        label(addedTitle, color: fg).opacity(swap).offset(x: 6 * (1 - swap))
                    }
                }
            }
        }
    }

    // MARK: 7. Bounce cart

    private var bounceCart: some View {
        let jump = KitoEase.pulse(KitoEase.segment(p, 0.05, 0.4))
        let plusFall = KitoEase.inCubic(KitoEase.segment(p, 0.15, 0.45))
        let wiggle = sin(KitoEase.segment(p, 0.45, 0.8) * .pi * 3) * (1 - KitoEase.segment(p, 0.45, 0.8))
        let badge = KitoEase.outBack(KitoEase.segment(p, 0.5, 0.75))
        let swap = KitoEase.inOutCubic(KitoEase.segment(p, 0.55, 0.8))
        return ZStack {
            chrome()
            HStack(spacing: 10) {
                ZStack(alignment: .topTrailing) {
                    ZStack(alignment: .top) {
                        symbol("cart", scale: 1.15)
                            .offset(y: -14 * jump)
                            .rotationEffect(.degrees(10 * wiggle), anchor: .bottom)
                        symbol("plus", scale: 0.7)
                            .offset(y: KitoEase.lerp(-height * 0.7, -2, plusFall))
                            .opacity(p > 0.12 && p < 0.5 ? 1 : 0)
                    }
                    Text("1")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(3)
                        .background(Circle().fill(successColor))
                        .offset(x: 7, y: -6)
                        .scaleEffect(badge)
                        .opacity(badge > 0 ? 1 : 0)
                }
                .frame(width: icon * 1.5, height: icon * 1.5)
                ZStack(alignment: .leading) {
                    label(title).opacity(1 - swap).offset(y: -8 * swap)
                    label(addedTitle).opacity(swap).offset(y: 8 * (1 - swap))
                }
            }
            .padding(.horizontal, size.horizontalPadding)
        }
        .modifier(IntrinsicFrame(fullWidth: fullWidth, height: height))
    }

    // MARK: Colour helpers

    /// Success colour adapted to the variant (solid for filled variants, tinted for the rest).
    private func variantAccent(_ accent: Color) -> Color {
        colors.background == .clear ? accent.opacity(0.16) : accent
    }

    private func accentForeground(_ accent: Color) -> Color {
        colors.background == .clear ? accent : colors.foreground
    }
}
