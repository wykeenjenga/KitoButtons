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

/// Live-adjustable theme shared by every screen.
final class ButtonAppearance: ObservableObject {
    enum Shape: String, CaseIterable, Identifiable {
        case rounded, capsule, rectangle
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

    @Published var shape: Shape = .rounded
    @Published var motion: Motion = .default
    @Published var tint: Color = .indigo
    @Published var showsShadow = false

    var theme: KitoButtonTheme {
        var theme = KitoButtonTheme()
        theme.shape = shape.buttonShape
        theme.tint = tint
        theme.motion = motion.preset
        theme.shadow = showsShadow ? KitoButtonShadow() : nil
        return theme
    }
}

struct ContentView: View {
    @StateObject private var appearance = ButtonAppearance()

    var body: some View {
        TabView {
            GalleryScreen().tabItem { Label("Gallery", systemImage: "square.grid.2x2") }
            ShopScreen().tabItem { Label("Shop", systemImage: "cart") }
            CartAnimationsScreen().tabItem { Label("Cart FX", systemImage: "sparkles") }
            PhasesScreen().tabItem { Label("Phases", systemImage: "arrow.triangle.2.circlepath") }
            AppearanceScreen().tabItem { Label("Appearance", systemImage: "paintpalette") }
        }
        .environmentObject(appearance)
        .kitoButtonTheme(appearance.theme)
        .tint(appearance.tint)
    }
}

struct AppearanceScreen: View {
    @EnvironmentObject private var appearance: ButtonAppearance

    var body: some View {
        NavigationStack {
            Form {
                Section("Shape") {
                    Picker("Shape", selection: $appearance.shape) {
                        ForEach(ButtonAppearance.Shape.allCases) { Text($0.rawValue.capitalized).tag($0) }
                    }.pickerStyle(.segmented)
                    Toggle("Drop shadow", isOn: $appearance.showsShadow)
                }
                Section("Motion preset") {
                    Picker("Motion", selection: $appearance.motion) {
                        ForEach(ButtonAppearance.Motion.allCases) { Text($0.rawValue.capitalized).tag($0) }
                    }.pickerStyle(.segmented)
                }
                Section("Tint") {
                    ColorPicker("Accent color", selection: $appearance.tint, supportsOpacity: false)
                }
                Section("Preview") {
                    KitoButton("Primary") {}.fullWidth()
                    KitoButton("Tonal") {}.variant(.tonal).fullWidth()
                    KitoButton("Outlined") {}.variant(.outlined).fullWidth()
                }
            }
            .navigationTitle("Appearance")
        }
    }
}
