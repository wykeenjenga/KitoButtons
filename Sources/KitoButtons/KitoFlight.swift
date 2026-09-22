//
//  KitoFlight.swift
//  KitoButtons
//
//  Created by Wycliff Njenga on 16/09/2026.
//  Copyright © 2026 Wycliff Njenga. All rights reserved.
//

import SwiftUI

/// Coordinates "fly to target" animations: a product image arcing from an Add-to-cart button
/// into the cart icon, a heart flying to a favourites tab, and so on.
///
/// 1. Attach `.kitoFlightLayer(controller)` to a root view (the flights are drawn in its overlay).
/// 2. Mark sources and targets with `.kitoFlightAnchor("product-1")` / `.kitoFlightAnchor("cart")`.
/// 3. Call `controller.fly(from: "product-1", to: "cart") { Image("shoe") }`.
@MainActor
public final class KitoFlightController: ObservableObject {
    public struct Flight: Identifiable {
        public let id = UUID()
        public let start: CGPoint
        public let end: CGPoint
        public let size: CGSize
        public let content: AnyView
        public let arcHeight: CGFloat
        public let completion: (() -> Void)?
    }

    @Published var flights: [Flight] = []
    @Published var landedTargets: [AnyHashable: Int] = [:]
    var frames: [AnyHashable: CGRect] = [:]

    public var motion: KitoButtonMotion
    /// When true (set automatically by `.kitoFlightLayer` from the Reduce Motion setting) flights
    /// land immediately without drawing an arc.
    public var reducesMotion = false

    public init(motion: KitoButtonMotion = .default) {
        self.motion = motion
    }

    /// Frame of an anchored view in the flight layer's coordinate space, if it is on screen.
    public func frame(of anchor: AnyHashable) -> CGRect? { frames[anchor] }

    /// Number of times something has landed on `target`; use it to drive badge bounces.
    public func landings(on target: AnyHashable) -> Int { landedTargets[target] ?? 0 }

    /// Flies `content` from the centre of the `source` anchor to the centre of the `target` anchor.
    /// Returns false when either anchor is unknown (not yet laid out).
    @discardableResult
    public func fly<Content: View>(from source: AnyHashable, to target: AnyHashable, size: CGSize = CGSize(width: 44, height: 44), arcHeight: CGFloat = 120, completion: (() -> Void)? = nil, @ViewBuilder content: () -> Content) -> Bool {
        guard let from = frames[source], let to = frames[target] else { return false }
        fly(from: CGPoint(x: from.midX, y: from.midY), to: CGPoint(x: to.midX, y: to.midY), target: target, size: size, arcHeight: arcHeight, completion: completion, content: content)
        return true
    }

    /// Flies from an explicit point to the `target` anchor.
    @discardableResult
    public func fly<Content: View>(fromPoint start: CGPoint, to target: AnyHashable, size: CGSize = CGSize(width: 44, height: 44), arcHeight: CGFloat = 120, completion: (() -> Void)? = nil, @ViewBuilder content: () -> Content) -> Bool {
        guard let to = frames[target] else { return false }
        fly(from: start, to: CGPoint(x: to.midX, y: to.midY), target: target, size: size, arcHeight: arcHeight, completion: completion, content: content)
        return true
    }

    private func fly<Content: View>(from start: CGPoint, to end: CGPoint, target: AnyHashable, size: CGSize, arcHeight: CGFloat, completion: (() -> Void)?, content: () -> Content) {
        if reducesMotion {
            landedTargets[target, default: 0] += 1
            completion?()
            return
        }
        let flight = Flight(start: start, end: end, size: size, content: AnyView(content()), arcHeight: arcHeight, completion: completion)
        flights.append(flight)
        let id = flight.id
        DispatchQueue.main.asyncAfter(deadline: .now() + motion.flightDuration) { [weak self] in
            guard let self else { return }
            self.flights.removeAll { $0.id == id }
            self.landedTargets[target, default: 0] += 1
            completion?()
        }
    }
}

// MARK: - Anchors

struct KitoFlightFramesKey: PreferenceKey {
    static var defaultValue: [AnyHashable: CGRect] = [:]
    static func reduce(value: inout [AnyHashable: CGRect], nextValue: () -> [AnyHashable: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

private let kitoFlightSpace = "KitoFlightSpace"

struct KitoFlightAnchorModifier: ViewModifier {
    let id: AnyHashable
    func body(content: Content) -> some View {
        content.background(
            GeometryReader { proxy in
                Color.clear.preference(key: KitoFlightFramesKey.self, value: [id: proxy.frame(in: .named(kitoFlightSpace))])
            }
        )
    }
}

struct KitoFlightLayerModifier: ViewModifier {
    @ObservedObject var controller: KitoFlightController
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .onAppear { controller.reducesMotion = reduceMotion }
            .onChange(of: reduceMotion) { controller.reducesMotion = $0 }
            .coordinateSpace(name: kitoFlightSpace)
            .onPreferenceChange(KitoFlightFramesKey.self) { frames in
                controller.frames.merge(frames) { $1 }
            }
            .overlay(
                ZStack {
                    ForEach(controller.flights) { flight in
                        KitoFlightView(flight: flight, animation: controller.motion.flight)
                    }
                }
                .allowsHitTesting(false)
            )
    }
}

public extension View {
    /// Registers this view as a flight source or target under `id`.
    func kitoFlightAnchor<ID: Hashable>(_ id: ID) -> some View {
        modifier(KitoFlightAnchorModifier(id: AnyHashable(id)))
    }

    /// Hosts in-flight items. Apply once to a root view that contains all anchors.
    func kitoFlightLayer(_ controller: KitoFlightController) -> some View {
        modifier(KitoFlightLayerModifier(controller: controller))
    }
}

// MARK: - Flight rendering

/// Moves a view along a quadratic arc from `start` to `end` while shrinking and fading it.
public struct KitoArcEffect: GeometryEffect {
    public var progress: CGFloat
    public var start: CGPoint
    public var end: CGPoint
    public var arcHeight: CGFloat
    public var endScale: CGFloat

    public init(progress: CGFloat, start: CGPoint, end: CGPoint, arcHeight: CGFloat = 120, endScale: CGFloat = 0.25) {
        self.progress = progress; self.start = start; self.end = end
        self.arcHeight = arcHeight; self.endScale = endScale
    }

    public var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    public func effectValue(size: CGSize) -> ProjectionTransform {
        let t = progress
        let control = CGPoint(x: (start.x + end.x) / 2, y: min(start.y, end.y) - arcHeight)
        let x = (1 - t) * (1 - t) * start.x + 2 * (1 - t) * t * control.x + t * t * end.x
        let y = (1 - t) * (1 - t) * start.y + 2 * (1 - t) * t * control.y + t * t * end.y
        let scale = 1 - (1 - endScale) * t
        var transform = CGAffineTransform(translationX: x - start.x, y: y - start.y)
        // Scale about the view's centre.
        transform = transform.translatedBy(x: size.width / 2, y: size.height / 2)
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: -size.width / 2, y: -size.height / 2)
        return ProjectionTransform(transform)
    }
}

struct KitoFlightView: View {
    let flight: KitoFlightController.Flight
    let animation: Animation
    @State private var progress: CGFloat = 0

    var body: some View {
        flight.content
            .frame(width: flight.size.width, height: flight.size.height)
            .modifier(KitoArcEffect(progress: progress, start: flight.start, end: flight.end, arcHeight: flight.arcHeight))
            .opacity(Double(1 - max(0, progress - 0.7) / 0.3))
            .position(flight.start)
            .onAppear { withAnimation(animation) { progress = 1 } }
    }
}

// MARK: - Badge target

/// Icon with a count badge that bounces every time the count changes or a flight lands on it.
/// Typically used as the cart button in a toolbar.
///
/// ```swift
/// KitoBadgeButton(systemImage: "cart", count: cart.count) { showCart = true }
///     .kitoFlightAnchor("cart")
/// ```
public struct KitoBadgeButton: View {
    private let systemImage: String
    private let count: Int
    private let action: () -> Void
    private var badgeColor: Color = .red
    private var iconColor: Color? = nil
    private var iconSize: CGFloat = 22
    private var landingTrigger: Int = 0
    private var accessibilityLabelOverride: String?
    // Internal, not private: read back directly in tests without a view-hosting harness.
    var accessibilityIdentifierValue: String?

    @Environment(\.kitoButtonTheme) private var theme

    public init(systemImage: String, count: Int, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.count = count
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            // The badge lives inside the view's own bounds so toolbars and clipping containers
            // never cut it off.
            ZStack(alignment: .topTrailing) {
                Image(systemName: count > 0 ? systemImage + ".fill" : systemImage)
                    .font(.system(size: iconSize, weight: .medium))
                    .foregroundColor(iconColor ?? theme.tint)
                    .frame(width: iconSize + 12, height: iconSize + 12)
                    .padding(.top, 8)
                    .padding(.trailing, 10)
                if count > 0 {
                    Text(count > 99 ? "99+" : "\(count)")
                        .font(theme.fontFamily?.font(size: 11, weight: .bold, relativeTo: .caption2) ?? .caption2.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(badgeColor))
                        .transition(.scale.combined(with: .opacity))
                        .kitoAccessibilityIdentifier(accessibilityIdentifierValue.map { "\($0).badge" })
                }
            }
            .kitoButtonBounce(trigger: count, animation: theme.motion.bounce)
            .kitoButtonBounce(trigger: landingTrigger, animation: theme.motion.bounce)
            .animation(theme.motion.morph, value: count)
            .contentShape(Rectangle())
        }
        .kitoAccessibilityIdentifier(accessibilityIdentifierValue)
        .buttonStyle(.plain)
        .accessibilityLabel(Self.accessibilityLabel(systemImage: systemImage, count: count, override: accessibilityLabelOverride))
    }

    /// Extracted so it's testable without a view-hosting harness.
    static func accessibilityLabel(systemImage: String, count: Int, override: String?) -> String {
        let name = override ?? systemImage
        guard count > 0 else { return name }
        return KitoButtonsLocalization.format("badge.items", "%@, %d items", name, count)
    }

    /// A human-readable name announced by VoiceOver (e.g. "Shopping cart"), used in place of the
    /// raw SF Symbol name. Localize it yourself, same as any other user-facing string.
    public func accessibilityLabel(_ label: String) -> KitoBadgeButton { var c = self; c.accessibilityLabelOverride = label; return c }
    public func badgeColor(_ color: Color) -> KitoBadgeButton { var c = self; c.badgeColor = color; return c }
    public func iconColor(_ color: Color?) -> KitoBadgeButton { var c = self; c.iconColor = color; return c }
    public func iconSize(_ size: CGFloat) -> KitoBadgeButton { var c = self; c.iconSize = size; return c }
    /// Reaches the button XCUITest actually taps, e.g. `app.buttons["shop.cart"]`. The count label
    /// gets a companion `"<id>.badge"` identifier of its own.
    public func accessibilityIdentifier(_ id: String) -> KitoBadgeButton { var c = self; c.accessibilityIdentifierValue = id; return c }
    /// Bounce whenever this value changes, e.g. `controller.landings(on: "cart")`.
    public func bounces(on trigger: Int) -> KitoBadgeButton { var c = self; c.landingTrigger = trigger; return c }
}
