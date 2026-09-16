//
//  KitoButtonThemeTests.swift
//  KitoButtons
//
//  Created by Wycliff Njenga on 16/09/2026.
//  Copyright © 2026 Wycliff Njenga. All rights reserved.
//

import XCTest
import SwiftUI
@testable import KitoButtons

final class KitoButtonThemeTests: XCTestCase {
    func testDefaultVariantColors() {
        let theme = KitoButtonTheme()
        XCTAssertEqual(theme.colors(for: .primary).foreground, theme.onTint)
        XCTAssertEqual(theme.colors(for: .destructive).background, theme.destructive)
        XCTAssertEqual(theme.colors(for: .outlined).background, .clear)
        XCTAssertEqual(theme.colors(for: .outlined).border, theme.tint)
        XCTAssertEqual(theme.colors(for: .ghost).border, .clear)
        XCTAssertEqual(theme.colors(for: .link).pressedBackground, .clear)
    }

    func testOverridesWin() {
        var theme = KitoButtonTheme()
        theme.overrides[.primary] = KitoButtonColors(background: .black, foreground: .yellow)
        XCTAssertEqual(theme.colors(for: .primary).background, .black)
        XCTAssertEqual(theme.colors(for: .primary).foreground, .yellow)
        XCTAssertEqual(theme.colors(for: .primary).pressedBackground, Color.black.opacity(0.85))
    }

    func testSizesScaleMonotonically() {
        XCTAssertLessThan(KitoButtonSize.small.height, KitoButtonSize.medium.height)
        XCTAssertLessThan(KitoButtonSize.medium.height, KitoButtonSize.large.height)
        XCTAssertLessThan(KitoButtonSize.small.iconSize, KitoButtonSize.large.iconSize)
    }

    func testOutlineClampsRadius() {
        let outline = KitoButtonOutline(.roundedRectangle(cornerRadius: 100))
        let rect = CGRect(x: 0, y: 0, width: 40, height: 20)
        XCTAssertEqual(outline.path(in: rect).boundingRect, rect)
        XCTAssertEqual(outline.inset(by: 2).insetAmount, 2)
    }
}
