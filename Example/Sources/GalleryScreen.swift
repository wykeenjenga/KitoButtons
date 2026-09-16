//
//  GalleryScreen.swift
//  KitoButtonsExample
//
//  Created by Wycliff Njenga on 16/09/2026.
//  Copyright © 2026 Wycliff Njenga. All rights reserved.
//

import SwiftUI
import KitoButtons

struct GalleryScreen: View {
    @State private var isLoading = false
    @State private var tapCount = 0

    private let variants: [(String, KitoButtonVariant)] = [
        ("Primary", .primary), ("Tonal", .tonal), ("Outlined", .outlined),
        ("Ghost", .ghost), ("Destructive", .destructive), ("Link", .link)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    section("Variants") {
                        ForEach(variants, id: \.0) { name, variant in
                            KitoButton(name) { tapCount += 1 }.variant(variant).fullWidth()
                        }
                        Text("Tapped \(tapCount) times").font(.footnote).foregroundColor(.secondary)
                    }
                    section("Sizes") {
                        HStack(spacing: 12) {
                            KitoButton("Small") {}.size(.small)
                            KitoButton("Medium") {}.size(.medium)
                            KitoButton("Large") {}.size(.large)
                        }
                    }
                    section("Icons") {
                        KitoButton("Add to cart", systemImage: "cart.badge.plus") {}.fullWidth()
                        KitoButton("Continue", systemImage: "arrow.right", iconPlacement: .trailing) {}.variant(.tonal).fullWidth()
                        HStack(spacing: 12) {
                            KitoButton(systemImage: "heart", accessibilityLabel: "Like") {}.variant(.outlined)
                            KitoButton(systemImage: "square.and.arrow.up", accessibilityLabel: "Share") {}.variant(.tonal)
                            KitoButton(systemImage: "trash", accessibilityLabel: "Delete") {}.variant(.destructive)
                            KitoButton(systemImage: "ellipsis", accessibilityLabel: "More") {}.variant(.ghost)
                        }
                    }
                    section("Loading & disabled") {
                        KitoButton("Controlled loading") { isLoading.toggle() }.loading(isLoading).variant(.tonal).fullWidth()
                        Toggle("isLoading", isOn: $isLoading)
                        KitoButton("Disabled") {}.fullWidth().disabled(true)
                    }
                    section("Roles") {
                        KitoButton("Delete account", systemImage: "trash") {}.role(.destructive).fullWidth()
                    }
                    section("Native Button + Kito style") {
                        Button("Plain SwiftUI Button") {}.buttonStyle(.kito(.outlined, fullWidth: true))
                        Button { } label: { Label("With Label", systemImage: "sparkles") }
                            .buttonStyle(.kito(.primary, size: .large, fullWidth: true))
                    }
                    section("Per-button theme overrides") {
                        KitoButton("Orange capsule with glow") {}
                            .fullWidth()
                            .kitoButtonTheme { theme in
                                theme.tint = .orange
                                theme.shape = .capsule
                                theme.shadow = KitoButtonShadow(color: .orange.opacity(0.35), radius: 12, y: 6)
                            }
                        KitoButton("Custom colors") {}
                            .fullWidth()
                            .kitoButtonTheme { theme in
                                theme.overrides[.primary] = KitoButtonColors(background: .black, foreground: .yellow)
                                theme.shape = .rectangle
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("KitoButtons")
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.subheadline.weight(.semibold)).foregroundColor(.secondary)
            content()
        }
    }
}
