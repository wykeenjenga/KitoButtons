//
//  SampleCatalog+Generated.swift
//  KitoButtonsExample
//
//  Created by Wycliff Njenga on 16/09/2026.
//  Copyright © 2026 Wycliff Njenga. All rights reserved.
//

import SwiftUI
import KitoButtons

/// Table-driven samples. Each row is a real product action; the sample view and the copyable
/// snippet are generated from the same definition so they never drift apart.
extension SampleCatalog {

    struct Action {
        let title: String
        let subtitle: String
        let icon: String
        let successIcon: String?
        let successTitle: String
        var variant: KitoButtonVariant = .primary
        var size: KitoButtonSize = .medium
        var fullWidth = true
        var destructive = false
        var duration: Double = 0.8
    }

    static func sample(_ action: Action, category: SampleCategory) -> Sample {
        var lines: [String] = []
        lines.append("KitoButton(\"\(action.title)\", systemImage: \"\(action.icon)\") {")
        lines.append("    try await service.\(camel(action.title))()")
        lines.append("}")
        lines.append(".showsResult()")
        if let icon = action.successIcon { lines.append(".resultIcons(success: \"\(icon)\")") }
        lines.append(".successTitle(\"\(action.successTitle)\")")
        if action.destructive { lines.append(".role(.destructive)") }
        if action.variant != .primary && !action.destructive { lines.append(".variant(.\(variantName(action.variant)))") }
        if action.size != .medium { lines.append(".size(.\(action.size == .small ? "small" : "large"))") }
        if action.fullWidth { lines.append(".fullWidth()") }
        return Sample(action.title, action.subtitle, category: category, code: lines.joined(separator: "\n")) {
            var button = KitoButton(action.title, systemImage: action.icon) { try await work(action.duration) }
                .showsResult()
                .successTitle(action.successTitle)
                .size(action.size)
                .fullWidth(action.fullWidth)
            if let icon = action.successIcon { button = button.resultIcons(success: icon) }
            button = action.destructive ? button.role(.destructive) : button.variant(action.variant)
            return button
        }
    }

    private static func camel(_ title: String) -> String {
        let words = title.split { !$0.isLetter }.map(String.init)
        guard let first = words.first else { return "run" }
        return first.lowercased() + words.dropFirst().map { $0.capitalized }.joined()
    }

    private static func variantName(_ v: KitoButtonVariant) -> String {
        switch v {
        case .primary: return "primary"
        case .tonal: return "tonal"
        case .outlined: return "outlined"
        case .ghost: return "ghost"
        case .destructive: return "destructive"
        case .link: return "link"
        }
    }

    // MARK: Every cart animation in every variant and size

    static let cartAnimations: [Sample] = {
        var samples: [Sample] = []
        let variants: [(String, KitoButtonVariant)] = [("primary", .primary), ("tonal", .tonal), ("outlined", .outlined)]
        for animation in KitoCartAnimation.allCases {
            for (name, variant) in variants {
                samples.append(Sample("\(animation.title) · \(name)", "KitoCartButton(.\(animation.rawValue)) in the \(name) variant.", category: .cartAnimations, code: """
                KitoCartButton("Add to cart", animation: .\(animation.rawValue)) {
                    try await cart.add(product)
                }
                .variant(.\(name))
                .fullWidth()
                """) {
                    KitoCartButton("Add to cart", animation: animation) { try await work(0.5) }.variant(variant).fullWidth()
                })
            }
            samples.append(Sample("\(animation.title) · small & large", "Compact and prominent sizes of the same animation.", category: .cartAnimations, code: """
            KitoCartButton("Add", animation: .\(animation.rawValue)) { … }.size(.small)
            KitoCartButton("Add to cart", animation: .\(animation.rawValue)) { … }.size(.large).fullWidth()
            """) {
                VStack(spacing: 12) {
                    KitoCartButton("Add", animation: animation) { try await work(0.5) }.size(.small)
                    KitoCartButton("Add to cart", animation: animation) { try await work(0.5) }.size(.large).fullWidth()
                }
            })
        }
        return samples
    }()

    // MARK: Domains

    static let food: [Sample] = [
        Action(title: "Order now", subtitle: "Primary checkout for a food order.", icon: "bag.fill", successIcon: "checkmark.circle.fill", successTitle: "Order placed", size: .large),
        Action(title: "Reorder", subtitle: "One-tap repeat of a past order.", icon: "arrow.counterclockwise", successIcon: "bag.fill", successTitle: "Added to bag", variant: .tonal),
        Action(title: "Add to order", subtitle: "Small tonal add inside a menu row.", icon: "plus", successIcon: "checkmark", successTitle: "Added", variant: .tonal, size: .small, fullWidth: false),
        Action(title: "Tip rider", subtitle: "Outlined secondary action after delivery.", icon: "hand.thumbsup", successIcon: "heart.fill", successTitle: "Thanks!", variant: .outlined),
        Action(title: "Rate order", subtitle: "Ghost action in an order summary.", icon: "star", successIcon: "star.fill", successTitle: "Rated", variant: .ghost, fullWidth: false),
        Action(title: "Track order", subtitle: "Outlined action that opens live tracking.", icon: "location", successIcon: "location.fill", successTitle: "Tracking", variant: .outlined),
        Action(title: "Cancel order", subtitle: "Destructive with a confirmation state.", icon: "xmark.circle", successIcon: "checkmark", successTitle: "Cancelled", destructive: true),
        Action(title: "Schedule delivery", subtitle: "Book a later slot.", icon: "clock", successIcon: "calendar.badge.checkmark", successTitle: "Scheduled 7–8 PM", variant: .tonal),
    ].map { sample($0, category: .food) }

    static let finance: [Sample] = [
        Action(title: "Send money", subtitle: "M-Pesa style transfer with a paid state.", icon: "paperplane.fill", successIcon: "checkmark.seal.fill", successTitle: "Sent KES 2,500", size: .large, duration: 1.2),
        Action(title: "Request money", subtitle: "Tonal counterpart to send.", icon: "arrow.down.left.circle", successIcon: "checkmark", successTitle: "Request sent", variant: .tonal),
        Action(title: "Pay bill", subtitle: "Utility bill payment.", icon: "doc.text", successIcon: "checkmark.seal.fill", successTitle: "Paid", duration: 1.0),
        Action(title: "Top up", subtitle: "Airtime or wallet top-up.", icon: "plus.circle", successIcon: "checkmark", successTitle: "Topped up", variant: .tonal),
        Action(title: "Withdraw", subtitle: "Cash-out to bank.", icon: "banknote", successIcon: "checkmark", successTitle: "On its way", variant: .outlined),
        Action(title: "Approve transaction", subtitle: "Confirm a pending approval.", icon: "checkmark.shield", successIcon: "checkmark.shield.fill", successTitle: "Approved"),
        Action(title: "Freeze card", subtitle: "Reversible destructive control.", icon: "snowflake", successIcon: "lock.fill", successTitle: "Card frozen", destructive: true),
        Action(title: "Add to savings", subtitle: "Move money into a goal.", icon: "target", successIcon: "checkmark", successTitle: "Saved", variant: .tonal),
        Action(title: "Buy shares", subtitle: "Trade confirmation.", icon: "chart.line.uptrend.xyaxis", successIcon: "checkmark.circle.fill", successTitle: "Order filled", duration: 1.4),
    ].map { sample($0, category: .finance) }

    static let health: [Sample] = [
        Action(title: "Start workout", subtitle: "Large primary start action.", icon: "figure.run", successIcon: "flame.fill", successTitle: "Workout started", size: .large),
        Action(title: "Log water", subtitle: "Quick small increment.", icon: "drop", successIcon: "drop.fill", successTitle: "+250 ml", variant: .tonal, size: .small, fullWidth: false),
        Action(title: "Book appointment", subtitle: "Clinic booking.", icon: "stethoscope", successIcon: "calendar.badge.checkmark", successTitle: "Booked"),
        Action(title: "Refill prescription", subtitle: "Pharmacy request.", icon: "pills", successIcon: "checkmark", successTitle: "Requested", variant: .outlined),
        Action(title: "Log weight", subtitle: "Ghost action in a chart header.", icon: "scalemass", successIcon: "checkmark", successTitle: "Logged", variant: .ghost, fullWidth: false),
        Action(title: "Mark medication taken", subtitle: "Check off a dose.", icon: "checkmark.circle", successIcon: "checkmark.circle.fill", successTitle: "Taken", variant: .tonal),
        Action(title: "Share with doctor", subtitle: "Export health data.", icon: "square.and.arrow.up", successIcon: "checkmark", successTitle: "Shared", variant: .outlined),
    ].map { sample($0, category: .health) }

    static let education: [Sample] = [
        Action(title: "Enroll", subtitle: "Join a course.", icon: "graduationcap", successIcon: "checkmark.seal.fill", successTitle: "Enrolled", size: .large),
        Action(title: "Submit assignment", subtitle: "Upload and submit.", icon: "paperplane", successIcon: "checkmark", successTitle: "Submitted", duration: 1.2),
        Action(title: "Mark lesson complete", subtitle: "Progress tick.", icon: "checkmark.circle", successIcon: "checkmark.circle.fill", successTitle: "Completed", variant: .tonal),
        Action(title: "Join live class", subtitle: "Enter a session.", icon: "video", successIcon: "video.fill", successTitle: "Joining…", variant: .outlined),
        Action(title: "Download notes", subtitle: "Offline material.", icon: "arrow.down.doc", successIcon: "doc.fill", successTitle: "Downloaded", variant: .ghost, fullWidth: false),
        Action(title: "Ask a question", subtitle: "Post to the forum.", icon: "questionmark.bubble", successIcon: "checkmark", successTitle: "Posted", variant: .tonal),
    ].map { sample($0, category: .education) }

    static let productivity: [Sample] = [
        Action(title: "Create task", subtitle: "Primary add action.", icon: "plus", successIcon: "checkmark", successTitle: "Created"),
        Action(title: "Complete task", subtitle: "Tonal done action.", icon: "checkmark.circle", successIcon: "checkmark.circle.fill", successTitle: "Done", variant: .tonal, size: .small, fullWidth: false),
        Action(title: "Archive", subtitle: "Ghost secondary action.", icon: "archivebox", successIcon: "archivebox.fill", successTitle: "Archived", variant: .ghost, fullWidth: false),
        Action(title: "Snooze until tomorrow", subtitle: "Outlined defer action.", icon: "moon.zzz", successIcon: "checkmark", successTitle: "Snoozed", variant: .outlined),
        Action(title: "Share document", subtitle: "Generate a share link.", icon: "link", successIcon: "checkmark", successTitle: "Link copied", variant: .tonal),
        Action(title: "Export PDF", subtitle: "Long-running export.", icon: "doc.richtext", successIcon: "checkmark", successTitle: "Exported", duration: 1.6),
        Action(title: "Invite teammate", subtitle: "Send an invite.", icon: "person.badge.plus", successIcon: "person.fill.checkmark", successTitle: "Invited", variant: .outlined),
        Action(title: "Start timer", subtitle: "Focus session.", icon: "timer", successIcon: "timer", successTitle: "25:00 running", variant: .tonal),
    ].map { sample($0, category: .productivity) }

    static let settings: [Sample] = [
        Action(title: "Enable notifications", subtitle: "Permission prompt trigger.", icon: "bell.badge", successIcon: "bell.fill", successTitle: "Enabled"),
        Action(title: "Sync now", subtitle: "Manual sync with result.", icon: "arrow.triangle.2.circlepath", successIcon: "checkmark", successTitle: "Up to date", variant: .tonal),
        Action(title: "Clear cache", subtitle: "Outlined maintenance action.", icon: "trash", successIcon: "checkmark", successTitle: "Cleared 128 MB", variant: .outlined),
        Action(title: "Check for updates", subtitle: "Ghost action in a footer.", icon: "arrow.down.circle", successIcon: "checkmark", successTitle: "Latest version", variant: .ghost, fullWidth: false),
        Action(title: "Sign out of all devices", subtitle: "Destructive security action.", icon: "iphone.slash", successIcon: "checkmark", successTitle: "Signed out", destructive: true),
        Action(title: "Delete account", subtitle: "Destructive, large, with confirmation state.", icon: "person.crop.circle.badge.xmark", successIcon: "checkmark", successTitle: "Deleted", size: .large, destructive: true, duration: 1.5),
        Action(title: "Restore purchases", subtitle: "StoreKit restore.", icon: "arrow.clockwise", successIcon: "checkmark", successTitle: "Restored", variant: .outlined),
        Action(title: "Export data", subtitle: "GDPR export request.", icon: "square.and.arrow.up.on.square", successIcon: "checkmark", successTitle: "Requested", variant: .tonal),
    ].map { sample($0, category: .settings) }
}
