//
//  KitoButtonShape.swift
//  KitoButtons
//
//  Created by Wycliff Njenga on 16/09/2026.
//  Copyright © 2026 Wycliff Njenga. All rights reserved.
//

import SwiftUI

/// Outline used for a button's background and border.
public enum KitoButtonShape: Hashable, Sendable {
    case rectangle
    case roundedRectangle(cornerRadius: CGFloat)
    case capsule

    /// 12pt continuous corners. The default.
    public static let rounded = KitoButtonShape.roundedRectangle(cornerRadius: 12)
}

/// Insettable shape rendering any `KitoButtonShape`.
public struct KitoButtonOutline: InsettableShape {
    public var shape: KitoButtonShape
    public var insetAmount: CGFloat = 0

    public init(_ shape: KitoButtonShape) { self.shape = shape }

    public func path(in rect: CGRect) -> Path {
        let r = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let maxRadius = min(r.width, r.height) / 2
        switch shape {
        case .rectangle:
            return Path(r)
        case .roundedRectangle(let radius):
            return Path(roundedRect: r, cornerRadius: min(radius, maxRadius), style: .continuous)
        case .capsule:
            return Path(roundedRect: r, cornerRadius: maxRadius, style: .circular)
        }
    }

    public func inset(by amount: CGFloat) -> KitoButtonOutline {
        var copy = self
        copy.insetAmount += amount
        return copy
    }
}

/// Drop shadow for button chrome.
public struct KitoButtonShadow: Equatable, Sendable {
    public var color: Color
    public var radius: CGFloat
    public var x: CGFloat
    public var y: CGFloat

    public init(color: Color = .black.opacity(0.12), radius: CGFloat = 10, x: CGFloat = 0, y: CGFloat = 4) {
        self.color = color; self.radius = radius; self.x = x; self.y = y
    }
}
