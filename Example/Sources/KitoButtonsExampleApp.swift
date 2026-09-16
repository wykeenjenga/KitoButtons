//
//  KitoButtonsExampleApp.swift
//  KitoButtonsExample
//
//  Created by Wycliff Njenga on 16/09/2026.
//  Copyright © 2026 Wycliff Njenga. All rights reserved.
//

import SwiftUI
import KitoButtons

@main
struct KitoButtonsExampleApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

/// Everything the theme exposes, adjustable live. Black (the label colour) is the default tint;
/// pick any colour to see the whole gallery re-themed.
final class ButtonAppearance: ObservableObject {
    enum Language: String, CaseIterable, Identifiable {
        case system, en, sw, fr
        var id: String { rawValue }
        var title: String {
            switch self {
            case .system: return "System"
            case .en: return "English"
            case .sw: return "Kiswahili"
            case .fr: return "Français"
            }
        }
    }

    /// Switches KitoButtons' own strings (default cart titles, accessibility values) at runtime.
    @Published var language: Language = .system {
        didSet {
            guard language != .system,
                  let path = KitoButtonsLocalization.bundle.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: language.rawValue),
                  let table = NSDictionary(contentsOfFile: path) as? [String: String] else {
                KitoButtonsLocalization.provider = nil
                return
            }
            KitoButtonsLocalization.provider = { key, _ in table[key] }
        }
    }

    enum Shape: String, CaseIterable, Identifiable {
        case capsule, rounded, rectangle
        var id: String { rawValue }
    }
    enum Motion: String, CaseIterable, Identifiable {
        case `default`, lively, subtle
        var id: String { rawValue }
        var preset: KitoButtonMotion {
            switch self {
            case .default: return .default
            case .lively: return .lively
            case .subtle: return .subtle
            }
        }
    }
    enum Mode: String, CaseIterable, Identifiable {
        case system, light, dark
        var id: String { rawValue }
        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }
    }
    struct Swatch: Identifiable {
        let name: String
        let color: Color?      // nil = mono (label colour)
        var id: String { name }
    }

    static let swatches: [Swatch] = [
        Swatch(name: "Mono", color: nil),
        Swatch(name: "Indigo", color: .indigo), Swatch(name: "Blue", color: .blue), Swatch(name: "Teal", color: .teal),
        Swatch(name: "Green", color: .green), Swatch(name: "Orange", color: .orange), Swatch(name: "Pink", color: .pink),
        Swatch(name: "Red", color: .red), Swatch(name: "Purple", color: .purple), Swatch(name: "Brown", color: .brown),
    ]

    // Theme
    @Published var mode: Mode = .system
    @Published var tint: Color? = nil                 // nil = mono
    @Published var customTint: Color = .indigo
    @Published var successColor: Color = .green
    @Published var failureColor: Color = .red
    // Shape
    @Published var shape: Shape = .capsule
    @Published var cornerRadius: Double = 12
    @Published var borderWidth: Double = 1.5
    // Motion & feel
    @Published var motion: Motion = .default
    @Published var resultDuration: Double = 1.2
    @Published var pressedScale: Double = 0.98
    @Published var showsShadow = false
    @Published var disabledOpacity: Double = 0.45

    var theme: KitoButtonTheme {
        var theme = KitoButtonTheme()
        if let tint {
            theme.tint = tint
            theme.onTint = .white
        }
        theme.successColor = successColor
        theme.failureColor = failureColor
        switch shape {
        case .capsule: theme.shape = .capsule
        case .rounded: theme.shape = .roundedRectangle(cornerRadius: cornerRadius)
        case .rectangle: theme.shape = .rectangle
        }
        theme.borderWidth = borderWidth
        theme.motion = motion.preset
        theme.motion.resultDuration = resultDuration
        theme.pressedScale = pressedScale
        theme.disabledOpacity = disabledOpacity
        theme.shadow = showsShadow ? KitoButtonShadow(color: (tint ?? .black).opacity(0.3), radius: 12, y: 6) : nil
        return theme
    }
}

struct ContentView: View {
    @StateObject private var appearance = ButtonAppearance()

    var body: some View {
        TabView {
            SamplesScreen().tabItem { Label("Samples", systemImage: "square.grid.2x2") }
            ShopScreen().tabItem { Label("Shop", systemImage: "cart") }
            AppearanceScreen().tabItem { Label("Appearance", systemImage: "slider.horizontal.3") }
        }
        .environmentObject(appearance)
        .kitoButtonTheme(appearance.theme)
        .tint(appearance.tint ?? .primary)
        .id(appearance.language)
        .preferredColorScheme(appearance.mode.colorScheme)
    }
}

struct AppearanceScreen: View {
    @EnvironmentObject private var appearance: ButtonAppearance

    var body: some View {
        NavigationStack {
            Form {
                Section("Language") {
                    Picker("Language", selection: $appearance.language) {
                        ForEach(ButtonAppearance.Language.allCases) { Text($0.title).tag($0) }
                    }.pickerStyle(.segmented)
                    Text("Default cart titles and accessibility text switch instantly.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                Section("Theme") {
                    Picker("Mode", selection: $appearance.mode) {
                        ForEach(ButtonAppearance.Mode.allCases) { Text($0.rawValue.capitalized).tag($0) }
                    }.pickerStyle(.segmented)
                }

                Section("Colour") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ButtonAppearance.swatches) { swatch in
                                let selected = swatch.color == appearance.tint
                                VStack(spacing: 6) {
                                    Circle()
                                        .fill(swatch.color ?? Color.primary)
                                        .frame(width: 34, height: 34)
                                        .overlay(Circle().stroke(Color.primary.opacity(selected ? 0.9 : 0), lineWidth: 2).padding(-3))
                                    Text(swatch.name).font(.caption2).foregroundStyle(selected ? .primary : .secondary)
                                }
                                .onTapGesture { appearance.tint = swatch.color }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    ColorPicker("Custom tint", selection: $appearance.customTint, supportsOpacity: false)
                        .onChange(of: appearance.customTint) { appearance.tint = $0 }
                    ColorPicker("Success colour", selection: $appearance.successColor, supportsOpacity: false)
                    ColorPicker("Failure colour", selection: $appearance.failureColor, supportsOpacity: false)
                    Text("Mono uses the label colour: black in light mode, white in dark mode.")
                        .font(.footnote).foregroundStyle(.secondary)
                }

                Section("Shape") {
                    Picker("Shape", selection: $appearance.shape) {
                        ForEach(ButtonAppearance.Shape.allCases) { Text($0.rawValue.capitalized).tag($0) }
                    }.pickerStyle(.segmented)
                    if appearance.shape == .rounded {
                        LabeledSlider("Corner radius", value: $appearance.cornerRadius, in: 0...28, unit: "pt")
                    }
                    LabeledSlider("Border width", value: $appearance.borderWidth, in: 0.5...4, step: 0.5, unit: "pt")
                    Toggle("Drop shadow", isOn: $appearance.showsShadow)
                }

                Section("Motion & feel") {
                    Picker("Motion", selection: $appearance.motion) {
                        ForEach(ButtonAppearance.Motion.allCases) { Text($0.rawValue.capitalized).tag($0) }
                    }.pickerStyle(.segmented)
                    LabeledSlider("Result hold", value: $appearance.resultDuration, in: 0.4...3, step: 0.1, unit: "s")
                    LabeledSlider("Press scale", value: $appearance.pressedScale, in: 0.9...1, step: 0.01)
                    LabeledSlider("Disabled opacity", value: $appearance.disabledOpacity, in: 0.2...0.8, step: 0.05)
                }

                Section("Preview") {
                    VStack(spacing: 12) {
                        KitoButton("Primary") {}.fullWidth()
                        KitoButton("Tonal") {}.variant(.tonal).fullWidth()
                        KitoButton("Outlined") {}.variant(.outlined).fullWidth()
                        KitoButton("Save", systemImage: "square.and.arrow.down") { try await work() }.showsResult().successTitle("Saved").fullWidth()
                        KitoButton("Fails") { try await work(0.5, fail: true) }.showsResult().failureTitle("Try again").variant(.tonal).fullWidth()
                        KitoCartButton("Add to cart", animation: .rollingCart) {}.fullWidth()
                        KitoButton("Disabled") {}.fullWidth().disabled(true)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Appearance")
        }
    }
}

private struct LabeledSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double = 1
    var unit: String = ""

    init(_ title: String, value: Binding<Double>, in range: ClosedRange<Double>, step: Double = 1, unit: String = "") {
        self.title = title; _value = value; self.range = range; self.step = step; self.unit = unit
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text(String(format: step < 1 ? "%.2f" : "%.0f", value) + unit).foregroundStyle(.secondary).monospacedDigit()
            }
            Slider(value: $value, in: range, step: step)
        }
    }
}
