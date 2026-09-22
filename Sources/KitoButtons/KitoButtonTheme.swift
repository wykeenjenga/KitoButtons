//
//  KitoButtonTheme.swift
//  KitoButtons
//
//  Created by Wycliff Njenga on 16/09/2026.
//  Copyright © 2026 Wycliff Njenga. All rights reserved.
//

import SwiftUI

/// Visual weight of an `KitoButton`.
public enum KitoButtonVariant: Hashable, Sendable {
    /// Solid brand fill. The main call to action.
    case primary
    /// Soft tinted fill.
    case tonal
    /// Border only.
    case outlined
    /// Text only, no chrome; tinted background on press.
    case ghost
    /// Solid destructive fill.
    case destructive
    /// Looks like an inline link.
    case link
}

/// How a button looks when `isEnabled` is false. Set per button with `.disabledStyle(_:)` or for
/// every button via `theme.disabledStyle`.
public enum KitoButtonDisabledStyle: Equatable, Sendable {
    /// The variant's normal colours at `theme.disabledOpacity`. The default; unchanged from
    /// KitoButtons' original disabled look.
    case faded
    /// A flat fill regardless of variant, at full opacity — e.g. a grey button instead of a dimmed one.
    case filled(background: Color, foreground: Color)
    /// Border-only at full opacity, in the secondary text colour.
    case outlined
}

/// How a button reacts to being pressed. Set per button with `.pressedStyle(_:)` or for every
/// button via `theme.pressedStyle`.
public enum KitoButtonPressedStyle: Hashable, Sendable {
    /// Scales down, darkens its fill and dims slightly. The default; unchanged from KitoButtons'
    /// original press feedback.
    case scale
    /// Darkens its fill only — no scale or opacity change. Useful for buttons inside something
    /// that's already animating (a card, a drag handle).
    case darken
    /// No press feedback at all.
    case none
}

public enum KitoButtonSize: Hashable, Sendable {
    case small, medium, large
    /// Your own metrics, e.g. `.custom(height: 52, font: .system(size: 15, weight: .semibold))`.
    case custom(height: CGFloat, font: Font, horizontalPadding: CGFloat = 20, iconSize: CGFloat = 17)

    public var height: CGFloat {
        switch self {
        case .small: return 36
        case .medium: return 48
        case .large: return 56
        case .custom(let height, _, _, _): return height
        }
    }
    public var horizontalPadding: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 20
        case .large: return 24
        case .custom(_, _, let padding, _): return padding
        }
    }
    public var font: Font {
        switch self {
        case .small: return .subheadline.weight(.semibold)
        case .medium: return .body.weight(.semibold)
        case .large: return .title3.weight(.semibold)
        case .custom(_, let font, _, _): return font
        }
    }
    public var iconSize: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 17
        case .large: return 20
        case .custom(_, _, _, let icon): return icon
        }
    }
}

/// Colors resolved for one variant.
public struct KitoButtonColors: Equatable, Sendable {
    public var background: Color
    public var foreground: Color
    public var border: Color
    public var pressedBackground: Color

    public init(background: Color, foreground: Color, border: Color = .clear, pressedBackground: Color? = nil) {
        self.background = background
        self.foreground = foreground
        self.border = border
        self.pressedBackground = pressedBackground ?? background.opacity(0.85)
    }
}

/// Tokens for `KitoButton`. Apply with `.kitoButtonTheme(...)`.
public struct KitoButtonTheme: Sendable {
    /// Brand color used by primary/tonal/outlined/ghost/link. Defaults to black in light mode and
    /// white in dark mode so a primary button always contrasts with the background.
    public var tint: Color = KitoButtonTheme.defaultTint
    /// Text/icon color on the primary fill. Defaults to the system background color.
    public var onTint: Color = KitoButtonTheme.defaultOnTint
    public var destructive: Color = .red
    public var onDestructive: Color = .white
    /// Fill for `.tonal`; nil derives from `tint`.
    public var tonalBackground: Color? = nil
    public var shape: KitoButtonShape = .capsule
    public var borderWidth: CGFloat = 1.5
    public var pressedScale: CGFloat = 0.98
    public var pressedOpacity: Double = 0.9
    public var disabledOpacity: Double = 0.45
    /// How every button looks when disabled, unless it overrides this with `.disabledStyle(_:)`.
    public var disabledStyle: KitoButtonDisabledStyle = .faded
    /// How every button reacts to being pressed, unless it overrides this with `.pressedStyle(_:)`.
    public var pressedStyle: KitoButtonPressedStyle = .scale
    public var shadow: KitoButtonShadow? = nil
    public var animation: Animation? = .easeOut(duration: 0.12)
    public var iconSpacing: CGFloat = 8
    /// Fill used while a button is loading; nil keeps the variant's own background.
    public var loadingBackground: Color? = nil
    /// Spinner colour while loading; nil keeps the variant's foreground.
    public var loadingForeground: Color? = nil
    /// Underline the `.link` variant's title (needs iOS 16 / macOS 13; ignored earlier).
    public var underlinesLink: Bool = true
    /// Fill/foreground used while a button shows its success phase.
    public var successColor: Color = .green
    /// Fill/foreground used while a button shows its failure phase.
    public var failureColor: Color = .red
    /// All animation timings. Swap for `.lively` or `.subtle`, or tune individual curves.
    public var motion: KitoButtonMotion = .default
    /// Overrides for any variant.
    public var overrides: [KitoButtonVariant: KitoButtonColors] = [:]
    /// When set, every button's title uses this family instead of the size's system font, at the
    /// same size/weight the size would otherwise use. `.custom` sizes keep the exact `Font` you
    /// passed them, since you already chose it explicitly. Set via `.custom(_:)` below.
    public var fontFamily: KitoFontFamily? = nil

    public init() {}

    /// The theme every button falls back to when nothing in its view hierarchy sets
    /// `.kitoButtonTheme(...)`. Set this **once**, e.g. in your `App`'s `init()`, to apply a look
    /// (a custom font, a brand tint) app-wide without wrapping every screen in a modifier:
    ///
    /// ```swift
    /// @main
    /// struct MyApp: App {
    ///     init() { KitoButtonTheme.default = .custom(myBrandFont) }
    ///     var body: some Scene { WindowGroup { ContentView() } }
    /// }
    /// ```
    ///
    /// An explicit `.kitoButtonTheme(...)` anywhere in the view hierarchy — including the
    /// built-in `.black`/`.accent` presets, neither of which carries a custom font — still
    /// overrides this for that subtree. Build from `.default` rather than a preset if you need
    /// both a preset's tint and your custom font.
    public static var `default` = KitoButtonTheme()

    /// Builds a theme where every button title uses `family`, at the size/weight this theme would
    /// otherwise use. Dynamic Type still scales, via `relativeTo:`.
    ///
    /// ```swift
    /// KitoButtonTheme.default = .custom(KitoFontFamily(regular: "Inter-Regular", semibold: "Inter-SemiBold"))
    /// ```
    public static func custom(_ family: KitoFontFamily, base: KitoButtonTheme = KitoButtonTheme()) -> KitoButtonTheme {
        var theme = base
        theme.fontFamily = family
        return theme
    }

    /// Resolves `size`'s title font, substituting `fontFamily` for the system font at the same
    /// size/weight when one is set. `.custom` sizes always keep the exact `Font` they were given.
    public func font(for size: KitoButtonSize) -> Font {
        guard let fontFamily else { return size.font }
        switch size {
        case .small: return fontFamily.font(size: 15, weight: .semibold, relativeTo: .subheadline)
        case .medium: return fontFamily.font(size: 17, weight: .semibold, relativeTo: .body)
        case .large: return fontFamily.font(size: 20, weight: .semibold, relativeTo: .title3)
        case .custom: return size.font
        }
    }

    /// Pure black fill regardless of appearance (use when your screens are always light).
    public static var black: KitoButtonTheme {
        var t = KitoButtonTheme()
        t.tint = .black
        t.onTint = .white
        return t
    }

    /// Uses the app accent color instead of black.
    public static var accent: KitoButtonTheme {
        var t = KitoButtonTheme()
        t.tint = .accentColor
        t.onTint = .white
        return t
    }

    public static var defaultTint: Color {
        #if os(iOS) || os(visionOS)
        return Color(UIColor.label)
        #elseif os(macOS)
        return Color(NSColor.labelColor)
        #else
        return .primary
        #endif
    }

    public static var defaultOnTint: Color {
        #if os(iOS) || os(visionOS)
        return Color(UIColor.systemBackground)
        #elseif os(macOS)
        return Color(NSColor.windowBackgroundColor)
        #else
        return .white
        #endif
    }

    /// Motion to use given the system Reduce Motion setting.
    public func motion(reducesMotion: Bool) -> KitoButtonMotion { reducesMotion ? .subtle : motion }

    public func colors(for variant: KitoButtonVariant) -> KitoButtonColors {
        if let custom = overrides[variant] { return custom }
        switch variant {
        case .primary:
            return KitoButtonColors(background: tint, foreground: onTint, pressedBackground: tint.opacity(0.8))
        case .tonal:
            return KitoButtonColors(background: tonalBackground ?? tint.opacity(0.14), foreground: tint, pressedBackground: tint.opacity(0.24))
        case .outlined:
            return KitoButtonColors(background: .clear, foreground: tint, border: tint, pressedBackground: tint.opacity(0.1))
        case .ghost:
            return KitoButtonColors(background: .clear, foreground: tint, pressedBackground: tint.opacity(0.1))
        case .destructive:
            return KitoButtonColors(background: destructive, foreground: onDestructive, pressedBackground: destructive.opacity(0.8))
        case .link:
            return KitoButtonColors(background: .clear, foreground: tint, pressedBackground: .clear)
        }
    }
}

private struct KitoButtonThemeKey: EnvironmentKey {
    // Computed, not `let`: re-reads `KitoButtonTheme.default` on every fallback so setting it
    // once at launch (before any button's environment is first read) takes effect everywhere.
    static var defaultValue: KitoButtonTheme { KitoButtonTheme.default }
}

public extension EnvironmentValues {
    var kitoButtonTheme: KitoButtonTheme {
        get { self[KitoButtonThemeKey.self] }
        set { self[KitoButtonThemeKey.self] = newValue }
    }
}

public extension View {
    func kitoButtonTheme(_ theme: KitoButtonTheme) -> some View {
        environment(\.kitoButtonTheme, theme)
    }
    func kitoButtonTheme(_ transform: @escaping (inout KitoButtonTheme) -> Void) -> some View {
        transformEnvironment(\.kitoButtonTheme, transform: transform)
    }
}
