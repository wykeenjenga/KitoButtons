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

public enum KitoButtonSize: Hashable, Sendable {
    case small, medium, large

    var height: CGFloat {
        switch self {
        case .small: return 36
        case .medium: return 48
        case .large: return 56
        }
    }
    var horizontalPadding: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 20
        case .large: return 24
        }
    }
    var font: Font {
        switch self {
        case .small: return .subheadline.weight(.semibold)
        case .medium: return .body.weight(.semibold)
        case .large: return .title3.weight(.semibold)
        }
    }
    var iconSize: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 17
        case .large: return 20
        }
    }
}

/// Colors resolved for one variant.
public struct KitoButtonColors: Sendable {
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
    /// Brand color used by primary/tonal/outlined/ghost/link.
    public var tint: Color = .accentColor
    public var onTint: Color = .white
    public var destructive: Color = .red
    public var onDestructive: Color = .white
    /// Fill for `.tonal`; nil derives from `tint`.
    public var tonalBackground: Color? = nil
    public var shape: KitoButtonShape = .rounded
    public var borderWidth: CGFloat = 1.5
    public var pressedScale: CGFloat = 0.98
    public var pressedOpacity: Double = 0.9
    public var disabledOpacity: Double = 0.45
    public var shadow: KitoButtonShadow? = nil
    public var animation: Animation? = .easeOut(duration: 0.12)
    public var iconSpacing: CGFloat = 8
    /// Overrides for any variant.
    public var overrides: [KitoButtonVariant: KitoButtonColors] = [:]

    public init() {}
    public static let `default` = KitoButtonTheme()

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
    static let defaultValue = KitoButtonTheme.default
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
