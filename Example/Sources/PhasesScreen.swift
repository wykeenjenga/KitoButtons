//
//  PhasesScreen.swift
//  KitoButtonsExample
//
//  Created by Wycliff Njenga on 16/09/2026.
//  Copyright © 2026 Wycliff Njenga. All rights reserved.
//

import SwiftUI
import KitoButtons

struct DemoError: Error {}

/// Idle → loading → success tick / failure shake, driven automatically by async actions or manually.
struct PhasesScreen: View {
    @State private var shouldFail = false
    @State private var manualPhase: KitoButtonPhase = .idle
    @State private var log: [String] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Toggle("Simulate failure", isOn: $shouldFail)

                    Text("Automatic (async action)").font(.subheadline.weight(.semibold)).foregroundColor(.secondary)
                    KitoButton("Save changes", systemImage: "square.and.arrow.down") {
                        try await work()
                    }
                    .showsResult()
                    .successTitle("Saved")
                    .failureTitle("Try again")
                    .fullWidth()

                    KitoButton("Add to cart", systemImage: "cart.badge.plus") {
                        try await work()
                    }
                    .showsResult()
                    .resultIcons(success: "cart.fill.badge.plus", failure: "cart.badge.minus")
                    .successTitle("Added")
                    .variant(.tonal)
                    .fullWidth()

                    KitoButton("Follow", systemImage: "person.badge.plus") { try await work() }
                        .showsResult()
                        .successTitle("Following")
                        .resultIcons(success: "person.fill.checkmark")
                        .variant(.outlined)
                        .fullWidth()

                    HStack(spacing: 12) {
                        KitoButton(systemImage: "heart", accessibilityLabel: "Like") { try await work() }
                            .showsResult().resultIcons(success: "heart.fill").variant(.tonal)
                        KitoButton(systemImage: "bookmark", accessibilityLabel: "Save") { try await work() }
                            .showsResult().resultIcons(success: "bookmark.fill").variant(.outlined)
                        KitoButton(systemImage: "arrow.down.circle", accessibilityLabel: "Download") { try await work() }
                            .showsResult().resultIcons(success: "checkmark.circle.fill").variant(.ghost)
                    }

                    Text("Manual phase binding").font(.subheadline.weight(.semibold)).foregroundColor(.secondary)
                    KitoButton("Pay KES 1,200", systemImage: "creditcard") {}
                        .phase($manualPhase)
                        .successTitle("Paid")
                        .failureTitle("Declined")
                        .size(.large)
                        .fullWidth()
                    Picker("Phase", selection: $manualPhase) {
                        Text("Idle").tag(KitoButtonPhase.idle)
                        Text("Loading").tag(KitoButtonPhase.loading)
                        Text("Success").tag(KitoButtonPhase.success)
                        Text("Failure").tag(KitoButtonPhase.failure)
                    }
                    .pickerStyle(.segmented)

                    if !log.isEmpty {
                        Text(log.suffix(5).joined(separator: "\n")).font(.footnote.monospaced()).foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Phases")
        }
    }

    private func work() async throws {
        try? await Task.sleep(nanoseconds: 900_000_000)
        if shouldFail {
            log.append("✕ failed at \(Date().formatted(date: .omitted, time: .standard))")
            throw DemoError()
        }
        log.append("✓ succeeded at \(Date().formatted(date: .omitted, time: .standard))")
    }
}
