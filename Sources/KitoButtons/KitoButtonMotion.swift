//
//  KitoButtonMotion.swift
//  KitoButtons
//
//  Created by Wycliff Njenga on 16/09/2026.
//  Copyright © 2026 Wycliff Njenga. All rights reserved.
//

import SwiftUI

/// Motion presets used by KitoButtons. Read them as computed properties so every animation in
/// your app stays consistent, or replace them in `KitoButtonTheme.motion`.
public struct KitoButtonMotion: Sendable {
    /// Press-down scale/opacity.
    public var press: Animation = .spring(response: 0.25, dampingFraction: 0.6)
    /// Idle → loading → success/failure icon morph.
    public var morph: Animation = .spring(response: 0.35, dampingFraction: 0.7)
    /// Item flying towards its target (cart, favourites…).
    public var flight: Animation = .timingCurve(0.25, 0.1, 0.25, 1.0, duration: 0.7)
    /// Badge / target bounce when a flight lands.
    public var bounce: Animation = .spring(response: 0.3, dampingFraction: 0.45)
    /// Failure shake.
    public var shake: Animation = .linear(duration: 0.4)
    /// How long a success/failure result stays visible before returning to idle.
    public var resultDuration: TimeInterval = 1.2
    /// Flight duration in seconds; keep in sync with `flight` if you change its timing curve.
    public var flightDuration: TimeInterval = 0.7

    public init() {}

    public static var `default`: KitoButtonMotion { KitoButtonMotion() }

    /// Snappier, more playful timings.
    public static var lively: KitoButtonMotion {
        var m = KitoButtonMotion()
        m.press = .spring(response: 0.2, dampingFraction: 0.5)
        m.morph = .spring(response: 0.3, dampingFraction: 0.55)
        m.bounce = .spring(response: 0.25, dampingFraction: 0.35)
        return m
    }

    /// Reduced movement for accessibility-sensitive contexts.
    public static var subtle: KitoButtonMotion {
        var m = KitoButtonMotion()
        m.press = .easeOut(duration: 0.12)
        m.morph = .easeInOut(duration: 0.2)
        m.flight = .easeInOut(duration: 0.4)
        m.flightDuration = 0.4
        m.bounce = .easeOut(duration: 0.2)
        return m
    }
}

/// Lifecycle of a `KitoButton` action.
public enum KitoButtonPhase: Hashable, Sendable {
    case idle
    case loading
    case success
    case failure

    public var isBusy: Bool { self == .loading }
}

// MARK: - Effects

/// Horizontal shake. Increase `shakes` by one (inside `withAnimation`) to trigger.
public struct KitoButtonShakeEffect: GeometryEffect {
    public var shakes: CGFloat
    public var amplitude: CGFloat

    public init(shakes: CGFloat, amplitude: CGFloat = 8) {
        self.shakes = shakes
        self.amplitude = amplitude
    }

    public var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }

    public func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: amplitude * sin(shakes * .pi * 4), y: 0))
    }
}

/// Bounces (scale up then settle) whenever `trigger` changes.
struct KitoBounceOnChange<Trigger: Equatable>: ViewModifier {
    var trigger: Trigger
    var scale: CGFloat
    var animation: Animation
    @State private var bounced = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(bounced ? scale : 1)
            .onChange(of: trigger) { _ in
                withAnimation(animation) { bounced = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    withAnimation(animation) { bounced = false }
                }
            }
    }
}

/// Shakes whenever `trigger` changes.
struct KitoShakeOnChange<Trigger: Equatable>: ViewModifier {
    var trigger: Trigger
    var animation: Animation
    @State private var shakes: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .modifier(KitoButtonShakeEffect(shakes: shakes))
            .onChange(of: trigger) { _ in withAnimation(animation) { shakes += 1 } }
    }
}

public extension View {
    /// Pops the view (e.g. a cart badge) each time `trigger` changes.
    func kitoButtonBounce<T: Equatable>(trigger: T, scale: CGFloat = 1.3, animation: Animation = KitoButtonMotion.default.bounce) -> some View {
        modifier(KitoBounceOnChange(trigger: trigger, scale: scale, animation: animation))
    }

    /// Shakes the view horizontally each time `trigger` changes.
    func kitoButtonShake<T: Equatable>(trigger: T, animation: Animation = KitoButtonMotion.default.shake) -> some View {
        modifier(KitoShakeOnChange(trigger: trigger, animation: animation))
    }
}
