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

/// Shape and motion only. The showcase is deliberately black and white so the components carry
/// the design; colour choices are left to the host app.
final class ButtonAppearance: ObservableObject {
    enum Shape: String, CaseIterable, Identifiable {
        case capsule, rounded, rectangle
        var id: String { rawValue }
        var buttonShape: KitoButtonShape {
            switch self {
            case .rounded: return .rounded
            case .capsule: return .capsule
            case .rectangle: return .rectangle
            }
        }
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

    @Published var shape: Shape = .capsule
    @Published var motion: Motion = .default
    @Published var mode: Mode = .system

    var theme: KitoButtonTheme {
        var theme = KitoButtonTheme()
        theme.shape = shape.buttonShape
        theme.motion = motion.preset
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
        .tint(.primary)
        .preferredColorScheme(appearance.mode.colorScheme)
    }
}

struct AppearanceScreen: View {
    @EnvironmentObject private var appearance: ButtonAppearance

    var body: some View {
        NavigationStack {
            Form {
                Section("Theme") {
                    Picker("Mode", selection: $appearance.mode) {
                        ForEach(ButtonAppearance.Mode.allCases) { Text($0.rawValue.capitalized).tag($0) }
                    }.pickerStyle(.segmented)
                    Text("Primary buttons are black in light mode and white in dark mode by default.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                Section("Shape") {
                    Picker("Shape", selection: $appearance.shape) {
                        ForEach(ButtonAppearance.Shape.allCases) { Text($0.rawValue.capitalized).tag($0) }
                    }.pickerStyle(.segmented)
                }
                Section("Motion preset") {
                    Picker("Motion", selection: $appearance.motion) {
                        ForEach(ButtonAppearance.Motion.allCases) { Text($0.rawValue.capitalized).tag($0) }
                    }.pickerStyle(.segmented)
                }
                Section("Preview") {
                    VStack(spacing: 12) {
                        KitoButton("Primary") {}.fullWidth()
                        KitoButton("Tonal") {}.variant(.tonal).fullWidth()
                        KitoButton("Outlined") {}.variant(.outlined).fullWidth()
                        KitoCartButton("Add to cart", animation: .rollingCart) {}.fullWidth()
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Appearance")
        }
    }
}
