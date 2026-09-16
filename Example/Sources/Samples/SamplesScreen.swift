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
            .searchable(text: $query, prompt: "Search samples")
            .navigationTitle("KitoButtons")
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

                Text("Requires `import KitoButtons`. Colours follow your theme; this showcase uses the default black-and-white theme.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle(sample.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
