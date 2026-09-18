//
//  KitoAccessibilityTests.swift
//  KitoButtonsTests
//
//  Created by Wycliff Njenga on 18/09/2026.
//  Copyright © 2026 Wycliff Njenga. All rights reserved.
//

import XCTest
@testable import KitoButtons

final class KitoBadgeButtonAccessibilityTests: XCTestCase {
    func testFallsBackToRawSymbolNameWithoutAnOverride() {
        XCTAssertEqual(KitoBadgeButton.accessibilityLabel(systemImage: "cart", count: 0, override: nil), "cart")
    }

    func testUsesTheHumanReadableOverrideWhenGiven() {
        XCTAssertEqual(KitoBadgeButton.accessibilityLabel(systemImage: "cart", count: 0, override: "Shopping cart"), "Shopping cart")
    }

    func testIncludesTheCountWhenAboveZero() {
        let label = KitoBadgeButton.accessibilityLabel(systemImage: "cart", count: 3, override: "Shopping cart")
        XCTAssertTrue(label.contains("Shopping cart"))
        XCTAssertTrue(label.contains("3"))
    }

    func testOmitsTheCountWhenZero() {
        let label = KitoBadgeButton.accessibilityLabel(systemImage: "bag", count: 0, override: "Wishlist")
        XCTAssertEqual(label, "Wishlist", "an empty badge should announce just the name, not \"Wishlist, 0 items\"")
    }
}
