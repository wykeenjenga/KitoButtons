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
    case cartAnimations = "Cart animations · every style"
    case food = "Food & delivery"
    case finance = "Finance & payments"
    case booking = "Booking & travel"
    case health = "Health & fitness"
    case education = "Education"
    case productivity = "Productivity"
    case social = "Social"
    case media = "Media & files"
    case auth = "Auth & forms"
    case settings = "Settings & system"
    case utility = "Utility & theming"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .commerce: return "cart"
        case .cartAnimations: return "sparkles"
        case .food: return "fork.knife"
        case .finance: return "creditcard"
        case .booking: return "calendar"
        case .health: return "heart.text.square"
        case .education: return "graduationcap"
        case .productivity: return "checklist"
        case .social: return "person.2"
        case .media: return "arrow.down.circle"
        case .auth: return "person.badge.key"
        case .settings: return "gearshape"
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
