//
//  ShopScreen.swift
//  KitoButtonsExample
//
//  Created by Wycliff Njenga on 16/09/2026.
//  Copyright © 2026 Wycliff Njenga. All rights reserved.
//

import SwiftUI
import KitoButtons

struct Product: Identifiable {
    let id = UUID()
    let name: String
    let price: Int
    let symbol: String
    let color: Color
}

/// Add-to-cart: the product image arcs into the cart icon, the badge bounces, the button morphs to a tick.
struct ShopScreen: View {
    @StateObject private var flights = KitoFlightController()
    @State private var cartCount = 0
    @State private var favourites = 0
    @EnvironmentObject private var appearance: ButtonAppearance

    private let products = [
        Product(name: "Trail runners", price: 8_900, symbol: "shoe.2.fill", color: .orange),
        Product(name: "Rain jacket", price: 12_500, symbol: "cloud.rain.fill", color: .blue),
        Product(name: "Camp stove", price: 4_300, symbol: "flame.fill", color: .red),
        Product(name: "Headlamp", price: 2_100, symbol: "lightbulb.fill", color: .yellow),
        Product(name: "Water bottle", price: 1_600, symbol: "drop.fill", color: .teal),
        Product(name: "Trekking poles", price: 6_800, symbol: "figure.hiking", color: .green),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(products) { product in
                        ProductRow(product: product, flights: flights, onAdd: { cartCount += 1 }, onFavourite: { favourites += 1 })
                    }
                }
                .padding()
            }
            .navigationTitle("Shop")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 4) {
                        KitoBadgeButton(systemImage: "heart", count: favourites) { favourites = 0 }
                            .badgeColor(.pink)
                            .bounces(on: flights.landings(on: "favourites"))
                            .kitoFlightAnchor("favourites")
                        KitoBadgeButton(systemImage: "cart", count: cartCount) { cartCount = 0 }
                            .bounces(on: flights.landings(on: "cart"))
                            .kitoFlightAnchor("cart")
                    }
                }
            }
        }
        .kitoFlightLayer(flights)
        .onAppear { flights.motion = appearance.motion.preset }
        .onChange(of: appearance.motion) { flights.motion = $0.preset }
    }
}

private struct ProductRow: View {
    let product: Product
    let flights: KitoFlightController
    let onAdd: () -> Void
    let onFavourite: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            thumbnail
                .frame(width: 64, height: 64)
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name).font(.headline)
                Text("KES \(product.price.formatted())").font(.subheadline).foregroundColor(.secondary)
            }
            Spacer()
            KitoButton(systemImage: "heart", accessibilityLabel: "Favourite") {
                try? await Task.sleep(nanoseconds: 300_000_000)
                onFavourite()
            }
            .showsResult()
            .resultIcons(success: "heart.fill")
            .variant(.ghost)
            .size(.small)
            .flies(to: "favourites", with: flights, size: CGSize(width: 24, height: 24), arcHeight: 80) {
                Image(systemName: "heart.fill").font(.title2).foregroundColor(.pink)
            }
            KitoButton("Add", systemImage: "cart.badge.plus") {
                try? await Task.sleep(nanoseconds: 500_000_000)
                onAdd()
            }
            .showsResult()
            .successTitle("Added")
            .size(.small)
            .flies(to: "cart", with: flights, size: CGSize(width: 56, height: 56), arcHeight: 140) {
                thumbnail
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }

    private var thumbnail: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(product.color.opacity(0.18))
            .overlay(Image(systemName: product.symbol).font(.title).foregroundColor(product.color))
    }
}
