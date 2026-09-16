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

final class KitoMotionTests: XCTestCase {
    func testArcEffectEndpoints() {
        let start = CGPoint(x: 10, y: 300), end = CGPoint(x: 350, y: 40)
        let size = CGSize(width: 40, height: 40)
        let atStart = KitoArcEffect(progress: 0, start: start, end: end).effectValue(size: size)
        XCTAssertEqual(atStart.m31, 0, accuracy: 0.001)
        XCTAssertEqual(atStart.m32, 0, accuracy: 0.001)
        XCTAssertEqual(atStart.m11, 1, accuracy: 0.001)
        let scale: CGFloat = 0.25
        let atEnd = KitoArcEffect(progress: 1, start: start, end: end, endScale: scale).effectValue(size: size)
        XCTAssertEqual(atEnd.m11, scale, accuracy: 0.001)
        // Scaling about the centre adds (size/2)(1 - scale) to the translation.
        XCTAssertEqual(atEnd.m31, end.x - start.x + size.width / 2 * (1 - scale), accuracy: 0.001)
        XCTAssertEqual(atEnd.m32, end.y - start.y + size.height / 2 * (1 - scale), accuracy: 0.001)
        let mid = KitoArcEffect(progress: 0.5, start: start, end: end, arcHeight: 100).effectValue(size: size)
        let linearMidY = (start.y + end.y) / 2
        XCTAssertLessThan(mid.m32 + start.y, linearMidY, "arc should bow upward relative to a straight line")
    }

    func testShakeEffectReturnsToRest() {
        let rest = KitoButtonShakeEffect(shakes: 1).effectValue(size: .zero).m31
        XCTAssertEqual(rest, 0, accuracy: 0.0001)
        XCTAssertNotEqual(KitoButtonShakeEffect(shakes: 0.125).effectValue(size: .zero).m31, 0)
    }

    func testMotionPresetsDiffer() {
        XCTAssertLessThan(KitoButtonMotion.subtle.flightDuration, KitoButtonMotion.default.flightDuration)
        XCTAssertEqual(KitoButtonPhase.loading.isBusy, true)
        XCTAssertEqual(KitoButtonPhase.success.isBusy, false)
    }

    @MainActor func testFlightControllerNeedsAnchors() {
        let controller = KitoFlightController(motion: .subtle)
        XCTAssertFalse(controller.fly(from: "a", to: "b") { Color.red })
        controller.frames["a"] = CGRect(x: 0, y: 0, width: 10, height: 10)
        controller.frames["b"] = CGRect(x: 100, y: 100, width: 10, height: 10)
        XCTAssertTrue(controller.fly(from: "a", to: "b") { Color.red })
        XCTAssertEqual(controller.flights.count, 1)
        XCTAssertEqual(controller.flights.first?.end, CGPoint(x: 105, y: 105))
        XCTAssertEqual(controller.landings(on: "b"), 0)
    }
}

final class KitoReducedMotionTests: XCTestCase {
    func testThemeMotionSwitch() {
        var theme = KitoButtonTheme()
        theme.motion = .lively
        XCTAssertEqual(theme.motion(reducesMotion: false).flightDuration, KitoButtonMotion.lively.flightDuration)
        XCTAssertEqual(theme.motion(reducesMotion: true).flightDuration, KitoButtonMotion.subtle.flightDuration)
    }

    @MainActor func testFlightsLandImmediatelyWhenReduced() {
        let controller = KitoFlightController()
        controller.frames["a"] = CGRect(x: 0, y: 0, width: 10, height: 10)
        controller.frames["b"] = CGRect(x: 100, y: 100, width: 10, height: 10)
        controller.reducesMotion = true
        var completed = false
        XCTAssertTrue(controller.fly(from: "a", to: "b", completion: { completed = true }) { Color.red })
        XCTAssertTrue(completed)
        XCTAssertEqual(controller.landings(on: "b"), 1)
        XCTAssertTrue(controller.flights.isEmpty)
    }
}
