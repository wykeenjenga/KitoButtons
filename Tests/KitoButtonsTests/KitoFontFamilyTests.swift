//
//  KitoFontFamilyTests.swift
//  KitoButtonsTests
//
//  Created by Wycliff Njenga on 18/09/2026.
//  Copyright © 2026 Wycliff Njenga. All rights reserved.
//

import XCTest
import SwiftUI
@testable import KitoButtons

final class KitoFontFamilyTests: XCTestCase {
    private let brand = KitoFontFamily(regular: "Inter-Regular", medium: "Inter-Medium", semibold: "Inter-SemiBold", bold: "Inter-Bold")

    func testEachWeightResolvesItsOwnName() {
        XCTAssertEqual(brand.name(for: .semibold), "Inter-SemiBold")
        XCTAssertEqual(brand.name(for: .bold), "Inter-Bold")
    }

    func testMissingWeightsFallBackProgressivelyTowardRegular() {
        let sparse = KitoFontFamily(regular: "Brand-Regular")
        XCTAssertEqual(sparse.name(for: .semibold), "Brand-Regular")
        XCTAssertEqual(sparse.name(for: .bold), "Brand-Regular")
    }

    func testCustomBuilderSetsFontFamilyAndKeepsOtherDefaults() {
        let theme = KitoButtonTheme.custom(brand)
        XCTAssertEqual(theme.fontFamily, brand)
        XCTAssertEqual(theme.shape, KitoButtonTheme().shape, "custom(_:) should only touch the font, leaving everything else at its default")
    }

    func testFontForSizeUsesTheFamilyAtEachSizesOwnRoleWhenSet() {
        let theme = KitoButtonTheme.custom(brand)
        XCTAssertEqual(theme.font(for: .small), brand.font(size: 15, weight: .semibold, relativeTo: .subheadline))
        XCTAssertEqual(theme.font(for: .medium), brand.font(size: 17, weight: .semibold, relativeTo: .body))
        XCTAssertEqual(theme.font(for: .large), brand.font(size: 20, weight: .semibold, relativeTo: .title3))
    }

    func testFontForSizeFallsBackToTheSystemFontWhenNoFamilyIsSet() {
        let theme = KitoButtonTheme()
        XCTAssertEqual(theme.font(for: .medium), KitoButtonSize.medium.font)
    }

    /// A `.custom` size already carries an explicit `Font` the caller chose; a global family
    /// override should not silently replace it.
    func testFontForSizeNeverOverridesAnExplicitCustomSizeFont() {
        let explicit = Font.system(size: 15, weight: .semibold)
        let size = KitoButtonSize.custom(height: 52, font: explicit)
        let theme = KitoButtonTheme.custom(brand)
        XCTAssertEqual(theme.font(for: size), explicit)
    }

    /// Regression: `KitoButtonTheme.default` must be a mutable, re-read-every-time fallback (not
    /// a `static let` snapshot) so setting it once at launch reaches every button.
    @MainActor
    func testSettingTheGlobalDefaultChangesWhatNewButtonsFallBackTo() {
        let original = KitoButtonTheme.default
        defer { KitoButtonTheme.default = original }

        KitoButtonTheme.default = .custom(brand)
        XCTAssertEqual(KitoButtonTheme.default.fontFamily, brand)
    }
}
