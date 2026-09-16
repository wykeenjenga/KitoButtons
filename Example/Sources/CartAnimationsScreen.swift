//
//  CartAnimationsScreen.swift
//  KitoButtonsExample
//
//  Created by Wycliff Njenga on 16/09/2026.
//  Copyright © 2026 Wycliff Njenga. All rights reserved.
//

import SwiftUI
import KitoButtons

/// Every built-in add-to-cart choreography, in each variant, plus a live "playground".
struct CartAnimationsScreen: View {
    @State private var variant: KitoButtonVariant = .primary
    @State private var speed: Double = 1
    @State private var shouldFail = false
    @State private var added = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Tap any button. Each animation is a native, time-based timeline you can restyle, speed up or slow down.")
                        .font(.footnote).foregroundColor(.secondary)

                    Picker("Variant", selection: $variant) {
                        Text("Primary").tag(KitoButtonVariant.primary)
                        Text("Tonal").tag(KitoButtonVariant.tonal)
                        Text("Outlined").tag(KitoButtonVariant.outlined)
                    }
                    .pickerStyle(.segmented)

                    HStack {
                        Text("Speed").font(.subheadline)
                        Slider(value: $speed, in: 0.25...2, step: 0.25)
                        Text("\(speed, specifier: "%.2g")×").font(.subheadline.monospacedDigit()).frame(width: 44)
                    }
                    Toggle("Simulate failure (shake + reset)", isOn: $shouldFail)
                    Text("Landed \(added) times").font(.footnote).foregroundColor(.secondary)

                    ForEach(KitoCartAnimation.allCases) { style in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(style.title).font(.subheadline.weight(.semibold)).foregroundColor(.secondary)
                            KitoCartButton("Add to cart", animation: style) {
                                try? await Task.sleep(nanoseconds: 300_000_000)
                                if shouldFail { throw DemoError() }
                            }
                            .variant(variant)
                            .fullWidth()
                            .duration(style.defaultDurationForDemo / speed)
                            .onAdded { added += 1 }
                        }
                    }

                    Divider()
                    Text("Compact sizes").font(.subheadline.weight(.semibold)).foregroundColor(.secondary)
                    HStack(spacing: 12) {
                        KitoCartButton("Add", animation: .burst) {}.size(.small).variant(.tonal)
                        KitoCartButton("Add", animation: .dropIn) {}.size(.small)
                        KitoCartButton("Add", animation: .bounceCart) {}.size(.small).variant(.outlined)
                    }
                    Text("Custom titles & shapes").font(.subheadline.weight(.semibold)).foregroundColor(.secondary)
                    KitoCartButton("Buy now · KES 8,900", animation: .fillSweep) {}
                        .addedTitle("In your bag")
                        .size(.large)
                        .fullWidth()
                        .kitoButtonTheme { $0.shape = .capsule; $0.tint = .black; $0.successColor = .green }
                    KitoCartButton("Reserve", animation: .morphCircle) {}
                        .addedTitle("Reserved")
                        .fullWidth()
                        .kitoButtonTheme { $0.shape = .rectangle; $0.tint = .orange }
                }
                .padding()
            }
            .navigationTitle("Cart animations")
        }
    }
}

private extension KitoCartAnimation {
    var defaultDurationForDemo: TimeInterval {
        switch self {
        case .rollingCart: return 1.8
        case .morphCircle: return 1.9
        default: return 1.3
        }
    }
}
