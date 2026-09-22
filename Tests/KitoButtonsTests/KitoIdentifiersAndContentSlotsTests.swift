//
//  KitoIdentifiersAndContentSlotsTests.swift
//  KitoButtonsTests
//
//  Created by Wycliff Njenga on 22/09/2026.
//  Copyright © 2026 Wycliff Njenga. All rights reserved.
//

import SwiftUI
import XCTest
@testable import KitoButtons

final class KitoAccessibilityIdentifierTests: XCTestCase {
    func testNotCalledLeavesTheIdentifierNil() {
        let button = KitoButton("Pay") {}
        XCTAssertNil(button.accessibilityIdentifierValue)
    }

    func testAccessibilityIdentifierIsStored() {
        let button = KitoButton("Pay") {}.accessibilityIdentifier("checkout.pay")
        XCTAssertEqual(button.accessibilityIdentifierValue, "checkout.pay")
    }

    func testAccessibilityHintIsStoredSeparatelyFromTheLabelFallback() {
        let button = KitoButton("Pay") {}.accessibilityHint("Double tap to pay")
        XCTAssertEqual(button.hintText, "Double tap to pay")
    }

    func testCartButtonAccessibilityIdentifierIsStored() {
        let button = KitoCartButton("Add") {}.accessibilityIdentifier("shop.addToCart")
        XCTAssertEqual(button.accessibilityIdentifierValue, "shop.addToCart")
    }

    func testBadgeButtonAccessibilityIdentifierIsStored() {
        let button = KitoBadgeButton(systemImage: "cart", count: 1) {}.accessibilityIdentifier("shop.cart")
        XCTAssertEqual(button.accessibilityIdentifierValue, "shop.cart")
    }
}

final class KitoContentSlotTests: XCTestCase {
    func testLeadingAndTrailingSlotsAreNilUntilSet() {
        let button = KitoButton("Pay") {}
        XCTAssertNil(button.leadingSlot)
        XCTAssertNil(button.trailingSlot)
        XCTAssertNil(button.labelOverride)
    }

    func testLeadingSlotIsStored() {
        let button = KitoButton("Pay") {}.leading { Text("KES") }
        XCTAssertNotNil(button.leadingSlot)
    }

    func testTrailingSlotIsStored() {
        let button = KitoButton("Pay") {}.trailing { Image(systemName: "chevron.right") }
        XCTAssertNotNil(button.trailingSlot)
    }

    func testLabelOverrideReplacesTheWholeRow() {
        let button = KitoButton("Pay") {}.label { Text("Custom") }
        XCTAssertNotNil(button.labelOverride)
    }

    func testSubtitleDefaultsToNil() {
        XCTAssertNil(KitoButton("Pay") {}.subtitleText)
    }

    func testSubtitleIsStored() {
        let button = KitoButton("Pay") {}.subtitle("KES 1,500")
        XCTAssertEqual(button.subtitleText, "KES 1,500")
    }

    func testSubtitleCanBeClearedBackToNil() {
        let button = KitoButton("Pay") {}.subtitle("KES 1,500").subtitle(nil)
        XCTAssertNil(button.subtitleText)
    }
}

final class KitoContentAlignmentTests: XCTestCase {
    func testDefaultsToCenter() {
        XCTAssertEqual(KitoButton("Pay") {}.contentAlignmentValue, .center)
    }

    func testContentAlignmentIsStored() {
        let button = KitoButton("Pay") {}.contentAlignment(.spaceBetween)
        XCTAssertEqual(button.contentAlignmentValue, .spaceBetween)
    }

    func testFrameAlignmentMapsLeadingAndSpaceBetweenToLeadingEdge() {
        XCTAssertEqual(KitoButton("Pay") {}.contentAlignment(.leading).contentFrameAlignment, .leading)
        XCTAssertEqual(KitoButton("Pay") {}.contentAlignment(.spaceBetween).contentFrameAlignment, .leading)
        XCTAssertEqual(KitoButton("Pay") {}.contentAlignment(.trailing).contentFrameAlignment, .trailing)
        XCTAssertEqual(KitoButton("Pay") {}.contentAlignment(.center).contentFrameAlignment, .center)
    }
}

final class KitoPerButtonOverrideTests: XCTestCase {
    func testShapeOverrideDefaultsToNil() {
        XCTAssertNil(KitoButton("Pay") {}.shapeOverride)
    }

    func testShapeOverrideIsStored() {
        let button = KitoButton("Pay") {}.shape(.rectangle)
        XCTAssertEqual(button.shapeOverride, .rectangle)
    }

    func testMinWidthOverrideIsStored() {
        let button = KitoButton("Pay") {}.minWidth(120)
        XCTAssertEqual(button.minWidthOverride, 120)
    }

    func testContentPaddingOverrideIsStored() {
        let insets = EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        let button = KitoButton("Pay") {}.contentPadding(insets)
        XCTAssertEqual(button.contentPaddingOverride, insets)
    }

    func testDisabledStyleOverrideIsStored() {
        let button = KitoButton("Pay") {}.disabledStyle(.outlined)
        XCTAssertEqual(button.disabledStyleOverride, .outlined)
    }

    func testPressedStyleOverrideIsStored() {
        let button = KitoButton("Pay") {}.pressedStyle(KitoButtonPressedStyle.none)
        XCTAssertEqual(button.pressedStyleOverride, KitoButtonPressedStyle.none)
    }
}

final class KitoHitTargetTests: XCTestCase {
    func testMediumPrimaryDoesNotExpand() {
        XCTAssertFalse(KitoButton("Pay") {}.expandsHitTarget)
    }

    func testSmallExpands() {
        XCTAssertTrue(KitoButton("Pay") {}.size(.small).expandsHitTarget)
    }

    func testLinkExpands() {
        XCTAssertTrue(KitoButton("Pay") {}.variant(.link).expandsHitTarget)
    }

    func testFullWidthSmallDoesNotNeedExpansion() {
        // Already occupies the full row width, so there's no undersized target to fix.
        XCTAssertFalse(KitoButton("Pay") {}.size(.small).fullWidth().expandsHitTarget)
    }
}

final class KitoButtonStylePureFunctionTests: XCTestCase {
    func testFadedDisabledStyleDimsOpacity() {
        let opacity = KitoButtonStyle.resolvedOpacity(isEnabled: false, phase: .idle, pressed: false, disabledOpacity: 0.45, pressedOpacity: 0.9, disabledStyle: .faded, pressedStyle: .scale)
        XCTAssertEqual(opacity, 0.45)
    }

    func testFilledDisabledStyleStaysFullOpacity() {
        let opacity = KitoButtonStyle.resolvedOpacity(isEnabled: false, phase: .idle, pressed: false, disabledOpacity: 0.45, pressedOpacity: 0.9, disabledStyle: .filled(background: .black, foreground: .white), pressedStyle: .scale)
        XCTAssertEqual(opacity, 1)
    }

    func testPressedScaleStyleDimsOpacity() {
        let opacity = KitoButtonStyle.resolvedOpacity(isEnabled: true, phase: .idle, pressed: true, disabledOpacity: 0.45, pressedOpacity: 0.9, disabledStyle: .faded, pressedStyle: .scale)
        XCTAssertEqual(opacity, 0.9)
    }

    func testPressedDarkenStyleDoesNotDimOpacity() {
        let opacity = KitoButtonStyle.resolvedOpacity(isEnabled: true, phase: .idle, pressed: true, disabledOpacity: 0.45, pressedOpacity: 0.9, disabledStyle: .faded, pressedStyle: .darken)
        XCTAssertEqual(opacity, 1)
    }

    func testFilledDisabledStyleReplacesColors() {
        let base = KitoButtonColors(background: .blue, foreground: .white)
        let resolved = KitoButtonStyle.resolvedColors(base: base, isEnabled: false, phase: .idle, disabledStyle: .filled(background: .gray, foreground: .black), loadingBackground: nil, loadingForeground: nil, successColor: .green, failureColor: .red, variant: .primary)
        XCTAssertEqual(resolved.background, .gray)
        XCTAssertEqual(resolved.foreground, .black)
    }

    func testOutlinedDisabledStyleClearsBackground() {
        let base = KitoButtonColors(background: .blue, foreground: .white)
        let resolved = KitoButtonStyle.resolvedColors(base: base, isEnabled: false, phase: .idle, disabledStyle: .outlined, loadingBackground: nil, loadingForeground: nil, successColor: .green, failureColor: .red, variant: .primary)
        XCTAssertEqual(resolved.background, .clear)
        XCTAssertEqual(resolved.foreground, .secondary)
    }

    func testFadedDisabledStyleKeepsBaseColors() {
        let base = KitoButtonColors(background: .blue, foreground: .white)
        let resolved = KitoButtonStyle.resolvedColors(base: base, isEnabled: false, phase: .idle, disabledStyle: .faded, loadingBackground: nil, loadingForeground: nil, successColor: .green, failureColor: .red, variant: .primary)
        XCTAssertEqual(resolved, base)
    }

    func testEnabledIgnoresDisabledStyleEntirely() {
        let base = KitoButtonColors(background: .blue, foreground: .white)
        let resolved = KitoButtonStyle.resolvedColors(base: base, isEnabled: true, phase: .idle, disabledStyle: .filled(background: .gray, foreground: .black), loadingBackground: nil, loadingForeground: nil, successColor: .green, failureColor: .red, variant: .primary)
        XCTAssertEqual(resolved, base)
    }

    func testSuccessPhaseStillRecoloursOverAFilledDisabledStyle() {
        // isEnabled is true here (a result phase implies the action finished), so the disabled
        // branch never applies regardless of which disabledStyle is configured.
        let base = KitoButtonColors(background: .blue, foreground: .white)
        let resolved = KitoButtonStyle.resolvedColors(base: base, isEnabled: true, phase: .success, disabledStyle: .filled(background: .gray, foreground: .black), loadingBackground: nil, loadingForeground: nil, successColor: .green, failureColor: .red, variant: .primary)
        XCTAssertEqual(resolved.background, .green)
    }
}
