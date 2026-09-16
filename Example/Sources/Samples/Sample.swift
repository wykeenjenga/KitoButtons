//
//  Sample.swift
//  KitoButtonsExample
//
//  Created by Wycliff Njenga on 16/09/2026.
//  Copyright © 2026 Wycliff Njenga. All rights reserved.
//

import SwiftUI

enum SampleCategory: String, CaseIterable, Identifiable {
    case commerce = "Commerce"
    case booking = "Booking & travel"
    case social = "Social"
    case media = "Media & files"
    case auth = "Auth & forms"
    case utility = "Utility & theming"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .commerce: return "cart"
        case .booking: return "calendar"
        case .social: return "person.2"
        case .media: return "arrow.down.circle"
        case .auth: return "person.badge.key"
        case .utility: return "wrench.and.screwdriver"
        }
    }
}

/// One entry in the gallery: what it is, the code to paste, and the live view.
struct Sample: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let category: SampleCategory
    let code: String
    let view: () -> AnyView

    init<V: View>(_ title: String, _ subtitle: String, category: SampleCategory, code: String, @ViewBuilder view: @escaping () -> V) {
        self.title = title
        self.subtitle = subtitle
        self.category = category
        self.code = code
        self.view = { AnyView(view()) }
    }
}

struct DemoError: Error {}

/// Simulates a network call; throws when `fail` is true.
func work(_ seconds: Double = 0.8, fail: Bool = false) async throws {
    try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    if fail { throw DemoError() }
}
