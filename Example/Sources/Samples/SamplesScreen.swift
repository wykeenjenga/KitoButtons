//
//  SamplesScreen.swift
//  KitoButtonsExample
//
//  Created by Wycliff Njenga on 16/09/2026.
//  Copyright © 2026 Wycliff Njenga. All rights reserved.
//

import SwiftUI

struct SamplesScreen: View {
    @State private var query = ""
    @State private var showsAbout = false

    private var filtered: [Sample] {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return SampleCatalog.all }
        return SampleCatalog.all.filter {
            $0.title.localizedCaseInsensitiveContains(q) || $0.subtitle.localizedCaseInsensitiveContains(q) || $0.category.rawValue.localizedCaseInsensitiveContains(q)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(SampleCategory.allCases) { category in
                    let items = filtered.filter { $0.category == category }
                    if !items.isEmpty {
                        Section {
                            ForEach(items) { sample in
                                NavigationLink(value: sample.id) {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(sample.title).font(.body.weight(.semibold))
                                        Text(sample.subtitle).font(.footnote).foregroundStyle(.secondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        } header: {
                            Label(category.rawValue, systemImage: category.symbol)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                                .textCase(nil)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $query, prompt: "Search \(SampleCatalog.all.count) samples")
            .navigationTitle("KitoButtons")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showsAbout = true } label: { Image(systemName: "info.circle") }
                        .accessibilityLabel("About")
                }
            }
            .sheet(isPresented: $showsAbout) { AboutScreen() }
            .overlay {
                if filtered.isEmpty {
                    ContentUnavailableCompat(query: query)
                }
            }
            .navigationDestination(for: UUID.self) { id in
                if let sample = SampleCatalog.all.first(where: { $0.id == id }) {
                    SampleDetailScreen(sample: sample)
                }
            }
        }
    }
}

struct SampleDetailScreen: View {
    let sample: Sample
    @State private var copied = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(sample.subtitle).font(.subheadline).foregroundStyle(.secondary)

                // Live preview
                VStack {
                    sample.view()
                        .frame(maxWidth: .infinity)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.primary.opacity(0.12), lineWidth: 1))

                // Code
                HStack {
                    Text("Code").font(.headline)
                    Spacer()
                    Button {
                        UIPasteboard.general.string = sample.code
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { copied = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                            withAnimation { copied = false }
                        }
                    } label: {
                        Label(copied ? "Copied" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Capsule().fill(copied ? Color.primary : Color.primary.opacity(0.08)))
                            .foregroundStyle(copied ? Color(.systemBackground) : Color.primary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(copied ? "Code copied" : "Copy code")
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(sample.code)
                        .font(.system(.footnote, design: .monospaced))
                        .textSelection(.enabled)
                        .padding(16)
                }
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.05)))

                Text("Requires `import KitoButtons`. Shape, colours and motion follow the theme you set in the Appearance tab; the default is a black capsule.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle(sample.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}


/// Empty search state (ContentUnavailableView needs iOS 17).
private struct ContentUnavailableCompat: View {
    let query: String
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass").font(.largeTitle).foregroundStyle(.secondary)
            Text("No samples for “\(query)”").font(.headline)
            Text("Try a use case (“booking”), a component (“badge”) or an animation (“flip”).")
                .font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .padding(32)
    }
}

struct AboutScreen: View {
    @Environment(\.dismiss) private var dismiss
    private var version: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        Image("AppIconPreview")
                            .resizable()
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("KitoButtons").font(.title3.weight(.semibold))
                            Text("Sample app · \(version)").font(.footnote).foregroundStyle(.secondary)
                            Text("\(SampleCatalog.all.count) samples across \(SampleCategory.allCases.count) categories").font(.footnote).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }
                Section("Package") {
                    Link(destination: URL(string: "https://github.com/wykeenjenga/KitoButtons")!) { Label("Source on GitHub", systemImage: "chevron.left.forwardslash.chevron.right") }
                    Link(destination: URL(string: "https://swiftpackageindex.com/wykeenjenga/KitoButtons")!) { Label("Swift Package Index", systemImage: "shippingbox") }
                    Link(destination: URL(string: "https://cocoapods.org/pods/KitoButtons")!) { Label("CocoaPods", systemImage: "cube") }
                    Link(destination: URL(string: "https://github.com/wykeenjenga/KitoFields")!) { Label("KitoFields · matching form inputs", systemImage: "character.cursor.ibeam") }
                }
                Section("Community") {
                    Link(destination: URL(string: "https://github.com/wykeenjenga/KitoButtons/issues/new/choose")!) { Label("Report a bug or request a feature", systemImage: "exclamationmark.bubble") }
                    Link(destination: URL(string: "https://github.com/wykeenjenga/KitoButtons/blob/main/CONTRIBUTING.md")!) { Label("Contributing guide", systemImage: "person.2") }
                    Link(destination: URL(string: "https://www.buymeacoffee.com/wycliffnjea")!) { Label("Buy me a coffee", systemImage: "cup.and.saucer") }
                }
                Section {
                    Text("Made by Wycliff Njenga in Nairobi. MIT licensed.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }
}
