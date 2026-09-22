//
//  SampleCatalog.swift
//  KitoButtonsExample
//
//  Created by Wycliff Njenga on 16/09/2026.
//  Copyright © 2026 Wycliff Njenga. All rights reserved.
//

import SwiftUI
import KitoButtons

enum SampleCatalog {
    static let all: [Sample] = commerce + cartAnimations + food + finance + booking + health + education + productivity + social + media + auth + settings + utility

    // MARK: Commerce

    static let commerce: [Sample] = commerceExtras + [
        Sample("Add to cart · rolling cart", "Label slides away, a cart rolls in, the product drops in, the cart rolls off.", category: .commerce, code: """
        KitoCartButton("Add to cart", animation: .rollingCart) {
            try await cart.add(product)
        }
        .addedTitle("Added")
        .fullWidth()
        """) {
            KitoCartButton("Add to cart", animation: .rollingCart) { try await work() }.fullWidth()
        },
        Sample("Add to cart · drop in", "The product falls into the cart, which squashes and bounces.", category: .commerce, code: """
        KitoCartButton("Add to cart", animation: .dropIn) {
            try await cart.add(product)
        }
        .fullWidth()
        """) {
            KitoCartButton("Add to cart", animation: .dropIn) { try await work() }.fullWidth()
        },
        Sample("Add to bag · morph to circle", "Squeezes into a circle with a spinner, a tick draws itself, expands back.", category: .commerce, code: """
        KitoCartButton("Add to bag", animation: .morphCircle) {
            try await bag.add(item)
        }
        .addedTitle("In your bag")
        .fullWidth()
        """) {
            KitoCartButton("Add to bag", animation: .morphCircle) { try await work() }.addedTitle("In your bag").fullWidth()
        },
        Sample("Buy now · fill sweep", "Success colour sweeps across, the tick draws itself.", category: .commerce, code: """
        KitoCartButton("Buy now · KES 8,900", animation: .fillSweep) {
            try await checkout.buyNow(product)
        }
        .addedTitle("Purchased")
        .size(.large)
        .fullWidth()
        """) {
            KitoCartButton("Buy now · KES 8,900", animation: .fillSweep) { try await work() }.addedTitle("Purchased").size(.large).fullWidth()
        },
        Sample("Add to cart · burst, bounce, flip", "Three more compact styles side by side.", category: .commerce, code: """
        KitoCartButton("Add", animation: .burst) { … }.size(.small).variant(.tonal)
        KitoCartButton("Add", animation: .bounceCart) { … }.size(.small)
        KitoCartButton("Add", animation: .flip) { … }.size(.small).variant(.outlined)
        """) {
            HStack(spacing: 12) {
                KitoCartButton("Add", animation: .burst) {}.size(.small).variant(.tonal)
                KitoCartButton("Add", animation: .bounceCart) {}.size(.small)
                KitoCartButton("Add", animation: .flip) {}.size(.small).variant(.outlined)
            }
        },
        Sample("Wishlist heart", "Icon-only button that morphs to a filled heart.", category: .commerce, code: """
        KitoButton(systemImage: "heart", accessibilityLabel: "Add to wishlist") {
            try await wishlist.add(product)
        }
        .showsResult()
        .resultIcons(success: "heart.fill")
        .variant(.tonal)
        """) {
            HStack(spacing: 12) {
                KitoButton(systemImage: "heart", accessibilityLabel: "Add to wishlist") { try await work(0.4) }
                    .showsResult().resultIcons(success: "heart.fill").variant(.tonal)
                KitoButton(systemImage: "heart", accessibilityLabel: "Add to wishlist") { try await work(0.4) }
                    .showsResult().resultIcons(success: "heart.fill").variant(.outlined)
                KitoButton(systemImage: "heart", accessibilityLabel: "Add to wishlist") { try await work(0.4) }
                    .showsResult().resultIcons(success: "heart.fill").variant(.ghost)
            }
        },
        Sample("Checkout", "Async primary action: spinner, then a tick and a new title.", category: .commerce, code: """
        KitoButton("Place order · KES 24,300", systemImage: "lock.fill") {
            try await checkout.placeOrder()
        }
        .showsResult()
        .successTitle("Order placed")
        .size(.large)
        .fullWidth()
        """) {
            KitoButton("Place order · KES 24,300", systemImage: "lock.fill") { try await work(1.2) }
                .showsResult().successTitle("Order placed").size(.large).fullWidth()
        },
        Sample("Apply coupon · failure", "A thrown error shakes the button and shows a cross.", category: .commerce, code: """
        KitoButton("Apply coupon") {
            try await coupons.apply(code)          // throws for an invalid code
        }
        .showsResult()
        .failureTitle("Invalid code")
        .variant(.outlined)
        """) {
            KitoButton("Apply coupon") { try await work(0.6, fail: true) }
                .showsResult().failureTitle("Invalid code").variant(.outlined)
        },
        Sample("Remove from cart", "Destructive role: red fill, trash icon.", category: .commerce, code: """
        KitoButton("Remove", systemImage: "trash") {
            cart.remove(item)
        }
        .role(.destructive)
        .size(.small)
        """) {
            KitoButton("Remove", systemImage: "trash") {}.role(.destructive).size(.small)
        },
    ]

    // MARK: Booking & travel

    static let booking: [Sample] = bookingExtras + [
        Sample("Book now", "Morph-to-circle with a booking title.", category: .booking, code: """
        KitoCartButton("Book now", animation: .morphCircle) {
            try await bookings.reserve(room, nights: 2)
        }
        .addedTitle("Booked")
        .fullWidth()
        """) {
            KitoCartButton("Book now", animation: .morphCircle) { try await work() }.addedTitle("Booked").fullWidth()
        },
        Sample("Reserve a table", "Flip animation revealing the confirmed state.", category: .booking, code: """
        KitoCartButton("Reserve a table", animation: .flip) {
            try await restaurant.reserve(guests: 2, at: date)
        }
        .addedTitle("Reserved · 7:30 PM")
        .fullWidth()
        """) {
            KitoCartButton("Reserve a table", animation: .flip) { try await work() }.addedTitle("Reserved · 7:30 PM").fullWidth()
        },
        Sample("Check in", "Burst animation for a one-tap check-in.", category: .booking, code: """
        KitoCartButton("Check in", animation: .burst) {
            try await flight.checkIn(passenger)
        }
        .addedTitle("Checked in")
        .variant(.tonal)
        .fullWidth()
        """) {
            KitoCartButton("Check in", animation: .burst) { try await work() }.addedTitle("Checked in").variant(.tonal).fullWidth()
        },
        Sample("Confirm ride", "Custom success glyph and title after the request succeeds.", category: .booking, code: """
        KitoButton("Confirm ride", systemImage: "car.fill") {
            try await rides.request(pickup, dropoff)
        }
        .showsResult()
        .resultIcons(success: "checkmark.circle.fill")
        .successTitle("Driver on the way")
        .fullWidth()
        """) {
            KitoButton("Confirm ride", systemImage: "car.fill") { try await work(1.0) }
                .showsResult().resultIcons(success: "checkmark.circle.fill").successTitle("Driver on the way").fullWidth()
        },
        Sample("Pay · manual phase", "Drive the phase yourself, e.g. from a payment SDK callback.", category: .booking, code: """
        @State private var phase: KitoButtonPhase = .idle

        KitoButton("Pay KES 1,200", systemImage: "creditcard") {
            phase = .loading
            mpesa.charge(amount) { result in
                phase = result.isSuccess ? .success : .failure
            }
        }
        .phase($phase)
        .successTitle("Paid")
        .failureTitle("Declined")
        .size(.large)
        .fullWidth()
        """) {
            ManualPhaseSample()
        },
        Sample("Select a seat", "Toggle between outlined and filled to show selection.", category: .booking, code: """
        @State private var selected: Set<String> = []

        ForEach(seats, id: \\.self) { seat in
            KitoButton(seat) { selected.toggle(seat) }
                .variant(selected.contains(seat) ? .primary : .outlined)
                .size(.small)
        }
        """) {
            SeatPickerSample()
        },
        Sample("Cancel booking", "Destructive async action with a confirmation title.", category: .booking, code: """
        KitoButton("Cancel booking") {
            try await bookings.cancel(id)
        }
        .role(.destructive)
        .showsResult()
        .successTitle("Cancelled")
        .fullWidth()
        """) {
            KitoButton("Cancel booking") { try await work() }.role(.destructive).showsResult().successTitle("Cancelled").fullWidth()
        },
    ]

    // MARK: Social

    static let social: [Sample] = socialExtras + [
        Sample("Follow", "Tonal button that becomes “Following” with a check glyph.", category: .social, code: """
        KitoButton("Follow", systemImage: "person.badge.plus") {
            try await api.follow(user)
        }
        .showsResult()
        .resultIcons(success: "person.fill.checkmark")
        .successTitle("Following")
        .variant(.tonal)
        .size(.small)
        """) {
            KitoButton("Follow", systemImage: "person.badge.plus") { try await work(0.5) }
                .showsResult().resultIcons(success: "person.fill.checkmark").successTitle("Following").variant(.tonal).size(.small)
        },
        Sample("Like, bookmark, share", "Icon-only buttons in three variants.", category: .social, code: """
        KitoButton(systemImage: "heart", accessibilityLabel: "Like") { … }
            .showsResult().resultIcons(success: "heart.fill").variant(.ghost)
        KitoButton(systemImage: "bookmark", accessibilityLabel: "Save") { … }
            .showsResult().resultIcons(success: "bookmark.fill").variant(.outlined)
        KitoButton(systemImage: "square.and.arrow.up", accessibilityLabel: "Share") { … }
            .variant(.tonal)
        """) {
            HStack(spacing: 12) {
                KitoButton(systemImage: "heart", accessibilityLabel: "Like") { try await work(0.3) }.showsResult().resultIcons(success: "heart.fill").variant(.ghost)
                KitoButton(systemImage: "bookmark", accessibilityLabel: "Save") { try await work(0.3) }.showsResult().resultIcons(success: "bookmark.fill").variant(.outlined)
                KitoButton(systemImage: "square.and.arrow.up", accessibilityLabel: "Share") {}.variant(.tonal)
            }
        },
        Sample("Subscribe", "Bell rings into a filled bell.", category: .social, code: """
        KitoButton("Subscribe", systemImage: "bell") {
            try await channel.subscribe()
        }
        .showsResult()
        .resultIcons(success: "bell.fill")
        .successTitle("Subscribed")
        """) {
            KitoButton("Subscribe", systemImage: "bell") { try await work(0.5) }
                .showsResult().resultIcons(success: "bell.fill").successTitle("Subscribed")
        },
        Sample("Send message", "Trailing icon and full width.", category: .social, code: """
        KitoButton("Send", systemImage: "paperplane.fill", iconPlacement: .trailing) {
            try await chat.send(draft)
        }
        .showsResult()
        .successTitle("Sent")
        .fullWidth()
        """) {
            KitoButton("Send", systemImage: "paperplane.fill", iconPlacement: .trailing) { try await work(0.5) }
                .showsResult().successTitle("Sent").fullWidth()
        },
    ]

    // MARK: Media & files

    static let media: [Sample] = mediaExtras + [
        Sample("Download", "Outlined action with a downloaded state.", category: .media, code: """
        KitoButton("Download", systemImage: "arrow.down.circle") {
            try await downloads.fetch(file)
        }
        .showsResult()
        .resultIcons(success: "checkmark.circle.fill")
        .successTitle("Downloaded")
        .variant(.outlined)
        """) {
            KitoButton("Download", systemImage: "arrow.down.circle") { try await work(1.4) }
                .showsResult().resultIcons(success: "checkmark.circle.fill").successTitle("Downloaded").variant(.outlined)
        },
        Sample("Upload photo", "Tonal button, long-running upload.", category: .media, code: """
        KitoButton("Upload photo", systemImage: "photo.on.rectangle") {
            try await storage.upload(image)
        }
        .showsResult()
        .successTitle("Uploaded")
        .variant(.tonal)
        .fullWidth()
        """) {
            KitoButton("Upload photo", systemImage: "photo.on.rectangle") { try await work(1.6) }
                .showsResult().successTitle("Uploaded").variant(.tonal).fullWidth()
        },
        Sample("Save changes", "The classic save button with a saved state.", category: .media, code: """
        KitoButton("Save changes", systemImage: "square.and.arrow.down") {
            try await document.save()
        }
        .showsResult()
        .successTitle("Saved")
        .fullWidth()
        """) {
            KitoButton("Save changes", systemImage: "square.and.arrow.down") { try await work(0.7) }
                .showsResult().successTitle("Saved").fullWidth()
        },
        Sample("Delete file", "Ghost destructive action for low-emphasis danger.", category: .media, code: """
        KitoButton("Delete file", systemImage: "trash") {
            try await files.delete(file)
        }
        .role(.destructive)
        .showsResult()
        .successTitle("Deleted")
        """) {
            KitoButton("Delete file", systemImage: "trash") { try await work(0.6) }.role(.destructive).showsResult().successTitle("Deleted")
        },
    ]

    // MARK: Auth & forms

    static let auth: [Sample] = authExtras + [
        Sample("Sign in", "Large primary call to action; disable it until the form is valid.", category: .auth, code: """
        KitoButton("Sign in") {
            try await auth.signIn(email, password)
        }
        .showsResult(success: false)          // navigate away instead of showing a tick
        .size(.large)
        .fullWidth()
        .disabled(!formIsValid)
        """) {
            KitoButton("Sign in") { try await work(1.0) }.showsResult(success: false).size(.large).fullWidth()
        },
        Sample("Continue with Apple / Google", "Brand buttons using the default black and an outlined variant.", category: .auth, code: """
        KitoButton("Continue with Apple", systemImage: "apple.logo") { … }
            .fullWidth()
        KitoButton("Continue with Google", systemImage: "globe") { … }
            .variant(.outlined)
            .fullWidth()
        """) {
            VStack(spacing: 12) {
                KitoButton("Continue with Apple", systemImage: "apple.logo") {}.fullWidth()
                KitoButton("Continue with Google", systemImage: "globe") {}.variant(.outlined).fullWidth()
            }
        },
        Sample("Resend code with countdown", "Link variant disabled while a timer runs.", category: .auth, code: """
        @State private var secondsLeft = 0

        KitoButton(secondsLeft > 0 ? "Resend in \\(secondsLeft)s" : "Resend code") {
            try await otp.resend()
            secondsLeft = 30           // tick down with a Timer
        }
        .variant(.link)
        .disabled(secondsLeft > 0)
        """) {
            ResendCodeSample()
        },
        Sample("Create account", "Full-width primary with an outlined secondary beneath.", category: .auth, code: """
        VStack(spacing: 12) {
            KitoButton("Create account") { try await auth.register(form) }
                .showsResult().successTitle("Welcome!").size(.large).fullWidth()
            KitoButton("I already have an account") { showSignIn = true }
                .variant(.ghost).fullWidth()
        }
        """) {
            VStack(spacing: 12) {
                KitoButton("Create account") { try await work(1.0) }.showsResult().successTitle("Welcome!").size(.large).fullWidth()
                KitoButton("I already have an account") {}.variant(.ghost).fullWidth()
            }
        },
        Sample("Log out", "Outlined destructive action.", category: .auth, code: """
        KitoButton("Log out", systemImage: "rectangle.portrait.and.arrow.right") {
            try await auth.signOut()
        }
        .role(.destructive)
        .variant(.outlined)
        .fullWidth()
        """) {
            KitoButton("Log out", systemImage: "rectangle.portrait.and.arrow.right") { try await work(0.5) }
                .role(.destructive).variant(.outlined).fullWidth()
        },
    ]

    // MARK: Utility & theming

    static let utility: [Sample] = [
        Sample("Copy to clipboard", "Ghost button that confirms with a tick.", category: .utility, code: """
        KitoButton("Copy link", systemImage: "doc.on.doc") {
            UIPasteboard.general.string = url.absoluteString
        }
        .showsResult()
        .successTitle("Copied")
        .variant(.ghost)
        """) {
            KitoButton("Copy link", systemImage: "doc.on.doc") { UIPasteboard.general.string = "https://github.com/wykeenjenga/KitoButtons" }
                .showsResult().successTitle("Copied").variant(.ghost)
        },
        Sample("Retry with failure", "Toggle to see the shake and cross, then retry.", category: .utility, code: """
        KitoButton("Sync now", systemImage: "arrow.triangle.2.circlepath") {
            try await sync.run()
        }
        .showsResult()
        .successTitle("Up to date")
        .failureTitle("Try again")
        .variant(.tonal)
        """) {
            RetrySample()
        },
        Sample("Variants", "Primary, tonal, outlined, ghost, destructive, link.", category: .utility, code: """
        KitoButton("Primary") {}
        KitoButton("Tonal") {}.variant(.tonal)
        KitoButton("Outlined") {}.variant(.outlined)
        KitoButton("Ghost") {}.variant(.ghost)
        KitoButton("Destructive") {}.variant(.destructive)
        KitoButton("Link") {}.variant(.link)
        """) {
            VStack(spacing: 10) {
                KitoButton("Primary") {}.fullWidth()
                KitoButton("Tonal") {}.variant(.tonal).fullWidth()
                KitoButton("Outlined") {}.variant(.outlined).fullWidth()
                KitoButton("Ghost") {}.variant(.ghost).fullWidth()
                KitoButton("Destructive") {}.variant(.destructive).fullWidth()
                KitoButton("Link") {}.variant(.link)
            }
        },
        Sample("Sizes", "Small, medium and large.", category: .utility, code: """
        KitoButton("Small") {}.size(.small)
        KitoButton("Medium") {}.size(.medium)
        KitoButton("Large") {}.size(.large)
        """) {
            HStack(spacing: 12) {
                KitoButton("Small") {}.size(.small)
                KitoButton("Medium") {}.size(.medium)
                KitoButton("Large") {}.size(.large)
            }
        },
        Sample("Loading & disabled", "Controlled spinner and the disabled look.", category: .utility, code: """
        KitoButton("Loading") {}.loading(true)
        KitoButton("Disabled") {}.disabled(true)
        """) {
            VStack(spacing: 12) {
                KitoButton("Loading") {}.loading(true).fullWidth()
                KitoButton("Disabled") {}.fullWidth().disabled(true)
            }
        },
        Sample("Native Button + Kito style", "Keep your existing Button, borrow the look.", category: .utility, code: """
        Button("Save") { save() }
            .buttonStyle(.kito(.outlined, size: .medium, fullWidth: true))
        """) {
            Button("Save") {}.buttonStyle(.kito(.outlined, size: .medium, fullWidth: true))
        },
        Sample("Pay button with trailing price", "Leading card icon, title, and a trailing price slot pushed to the far edge.", category: .utility, code: """
        KitoButton("Pay", systemImage: "creditcard") {
            try await checkout.pay()
        }
        .trailing { Text("KES 1,500").fontWeight(.semibold) }
        .contentAlignment(.spaceBetween)
        .accessibilityIdentifier("checkout.pay")
        .size(.large)
        .fullWidth()
        """) {
            KitoButton("Pay", systemImage: "creditcard") { try await work() }
                .trailing { Text("KES 1,500").fontWeight(.semibold) }
                .contentAlignment(.spaceBetween)
                .accessibilityIdentifier("checkout.pay")
                .size(.large)
                .fullWidth()
        },
        Sample("Country picker button", "A leading flag/code slot with a trailing chevron, both replacing the plain icon.", category: .utility, code: """
        KitoButton("Country") { showPicker = true }
            .leading { Text("🇰🇪") }
            .trailing { Image(systemName: "chevron.down") }
            .subtitle("Kenya, +254")
            .variant(.outlined)
        """) {
            KitoButton("Country") {}
                .leading { Text("🇰🇪") }
                .trailing { Image(systemName: "chevron.down") }
                .subtitle("Kenya, +254")
                .variant(.outlined)
        },
        Sample("Two-line button", "A title with a smaller subtitle line, still one button.", category: .utility, code: """
        KitoButton("Upgrade to Pro") { }
            .subtitle("KES 800 / month, cancel anytime")
            .variant(.tonal)
            .fullWidth()
        """) {
            KitoButton("Upgrade to Pro") {}
                .subtitle("KES 800 / month, cancel anytime")
                .variant(.tonal)
                .fullWidth()
        },
        Sample("Fly to a target", "Any view can be a target; the product arcs from the button.", category: .utility, code: """
        @StateObject var flights = KitoFlightController()

        KitoBadgeButton(systemImage: "cart", count: count) { }
            .bounces(on: flights.landings(on: "cart"))
            .kitoFlightAnchor("cart")

        KitoCartButton("Add", animation: .dropIn) { }
            .onAdded { count += 1 }
            .flies(to: "cart", with: flights) { Image(systemName: "shippingbox.fill") }

        // Wrap the screen: .kitoFlightLayer(flights)
        """) {
            FlightSample()
        },
        Sample("Per-button theme", "Override shape or colours for one button.", category: .utility, code: """
        KitoButton("Sharp corners") {}
            .kitoButtonTheme { $0.shape = .rectangle }
        KitoButton("Inverted") {}
            .kitoButtonTheme { $0.overrides[.primary] = KitoButtonColors(background: .white, foreground: .black, border: .black) }
        """) {
            VStack(spacing: 12) {
                KitoButton("Sharp corners") {}.fullWidth().kitoButtonTheme { $0.shape = .rectangle }
                KitoButton("Inverted") {}.fullWidth().kitoButtonTheme { $0.overrides[.primary] = KitoButtonColors(background: Color(.systemBackground), foreground: .primary, border: .primary) }
            }
        },
    ]
}

// MARK: - Stateful samples

private struct ManualPhaseSample: View {
    @State private var phase: KitoButtonPhase = .idle
    var body: some View {
        VStack(spacing: 14) {
            KitoButton("Pay KES 1,200", systemImage: "creditcard") {}
                .phase($phase).successTitle("Paid").failureTitle("Declined").size(.large).fullWidth()
            Picker("Phase", selection: $phase) {
                Text("Idle").tag(KitoButtonPhase.idle)
                Text("Loading").tag(KitoButtonPhase.loading)
                Text("Success").tag(KitoButtonPhase.success)
                Text("Failure").tag(KitoButtonPhase.failure)
            }
            .pickerStyle(.segmented)
        }
    }
}

private struct SeatPickerSample: View {
    @State private var selected: Set<String> = ["3B"]
    private let seats = ["3A", "3B", "3C", "3D"]
    var body: some View {
        HStack(spacing: 10) {
            ForEach(seats, id: \.self) { seat in
                KitoButton(seat) {
                    if selected.contains(seat) { selected.remove(seat) } else { selected.insert(seat) }
                }
                .variant(selected.contains(seat) ? .primary : .outlined)
                .size(.small)
            }
        }
    }
}

private struct ResendCodeSample: View {
    @State private var secondsLeft = 0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        KitoButton(secondsLeft > 0 ? "Resend in \(secondsLeft)s" : "Resend code") {
            try await work(0.4)
            secondsLeft = 10
        }
        .variant(.link)
        .disabled(secondsLeft > 0)
        .onReceive(timer) { _ in if secondsLeft > 0 { secondsLeft -= 1 } }
    }
}

private struct RetrySample: View {
    @State private var shouldFail = true
    var body: some View {
        VStack(spacing: 14) {
            KitoButton("Sync now", systemImage: "arrow.triangle.2.circlepath") { try await work(0.8, fail: shouldFail) }
                .showsResult().successTitle("Up to date").failureTitle("Try again").variant(.tonal).fullWidth()
            Toggle("Simulate failure", isOn: $shouldFail).font(.subheadline)
        }
    }
}

private struct FlightSample: View {
    @StateObject private var flights = KitoFlightController()
    @State private var count = 0
    var body: some View {
        VStack(spacing: 28) {
            HStack {
                Spacer()
                KitoBadgeButton(systemImage: "cart", count: count) { count = 0 }
                    .bounces(on: flights.landings(on: "cart"))
                    .kitoFlightAnchor("cart")
            }
            KitoCartButton("Add", animation: .dropIn) {}
                .onAdded { count += 1 }
                .flies(to: "cart", with: flights, size: CGSize(width: 36, height: 36), arcHeight: 60) {
                    Image(systemName: "shippingbox.fill").font(.title).foregroundStyle(.primary)
                }
        }
        .kitoFlightLayer(flights)
    }
}


// MARK: - Extra table-driven rows for the hand-written categories

extension SampleCatalog {
    static let commerceExtras: [Sample] = [
        Action(title: "Add to wishlist", subtitle: "Outlined save-for-later.", icon: "heart", successIcon: "heart.fill", successTitle: "Saved", variant: .outlined),
        Action(title: "Notify me", subtitle: "Back-in-stock alert.", icon: "bell", successIcon: "bell.fill", successTitle: "We'll notify you", variant: .tonal),
        Action(title: "Compare", subtitle: "Ghost action in a product grid.", icon: "rectangle.on.rectangle", successIcon: "checkmark", successTitle: "Added to compare", variant: .ghost, fullWidth: false),
        Action(title: "Redeem points", subtitle: "Loyalty redemption.", icon: "gift", successIcon: "checkmark.seal.fill", successTitle: "Redeemed", variant: .tonal),
        Action(title: "Start return", subtitle: "Outlined post-purchase action.", icon: "arrow.uturn.backward", successIcon: "checkmark", successTitle: "Return started", variant: .outlined),
        Action(title: "Track package", subtitle: "Small tonal in an order row.", icon: "shippingbox", successIcon: "location.fill", successTitle: "Tracking", variant: .tonal, size: .small, fullWidth: false),
    ].map { sample($0, category: .commerce) }

    static let bookingExtras: [Sample] = [
        Action(title: "Book flight", subtitle: "Large primary purchase.", icon: "airplane", successIcon: "checkmark.seal.fill", successTitle: "Booked · NBO → LHR", size: .large, duration: 1.4),
        Action(title: "Add to itinerary", subtitle: "Tonal planner action.", icon: "map", successIcon: "checkmark", successTitle: "Added", variant: .tonal),
        Action(title: "Request refund", subtitle: "Outlined support action.", icon: "arrow.uturn.left", successIcon: "checkmark", successTitle: "Requested", variant: .outlined),
        Action(title: "Upgrade seat", subtitle: "Upsell with confirmation.", icon: "arrow.up.circle", successIcon: "star.fill", successTitle: "Upgraded", variant: .tonal),
        Action(title: "Download boarding pass", subtitle: "Wallet pass download.", icon: "wallet.pass", successIcon: "checkmark", successTitle: "Added to Wallet"),
        Action(title: "Order room service", subtitle: "Hotel in-room action.", icon: "fork.knife", successIcon: "checkmark", successTitle: "Ordered", variant: .outlined),
    ].map { sample($0, category: .booking) }

    static let socialExtras: [Sample] = [
        Action(title: "Comment", subtitle: "Ghost reply action.", icon: "bubble.right", successIcon: "checkmark", successTitle: "Posted", variant: .ghost, fullWidth: false),
        Action(title: "Repost", subtitle: "Tonal share to your feed.", icon: "arrow.2.squarepath", successIcon: "checkmark", successTitle: "Reposted", variant: .tonal, size: .small, fullWidth: false),
        Action(title: "Invite friends", subtitle: "Growth action.", icon: "person.2.badge.plus", successIcon: "checkmark", successTitle: "Invites sent"),
        Action(title: "Report", subtitle: "Outlined moderation action.", icon: "flag", successIcon: "checkmark", successTitle: "Reported", variant: .outlined, fullWidth: false),
        Action(title: "Block user", subtitle: "Destructive moderation action.", icon: "hand.raised", successIcon: "checkmark", successTitle: "Blocked", destructive: true),
        Action(title: "Join group", subtitle: "Tonal membership action.", icon: "person.3", successIcon: "checkmark", successTitle: "Joined", variant: .tonal),
    ].map { sample($0, category: .social) }

    static let mediaExtras: [Sample] = [
        Action(title: "Add to playlist", subtitle: "Tonal library action.", icon: "text.badge.plus", successIcon: "checkmark", successTitle: "Added", variant: .tonal, fullWidth: false),
        Action(title: "Download episode", subtitle: "Offline download.", icon: "arrow.down.circle", successIcon: "checkmark.circle.fill", successTitle: "Downloaded", variant: .outlined, duration: 1.4),
        Action(title: "Subscribe to podcast", subtitle: "Primary follow.", icon: "dot.radiowaves.left.and.right", successIcon: "checkmark", successTitle: "Subscribed"),
        Action(title: "Rent movie", subtitle: "Purchase with price.", icon: "film", successIcon: "play.fill", successTitle: "Ready to play", size: .large),
        Action(title: "Cast to TV", subtitle: "Ghost device action.", icon: "tv", successIcon: "tv.fill", successTitle: "Casting", variant: .ghost, fullWidth: false),
        Action(title: "Export video", subtitle: "Long export.", icon: "square.and.arrow.up", successIcon: "checkmark", successTitle: "Exported", duration: 1.8),
    ].map { sample($0, category: .media) }

    static let authExtras: [Sample] = [
        Action(title: "Send magic link", subtitle: "Passwordless sign-in.", icon: "envelope", successIcon: "envelope.open.fill", successTitle: "Check your inbox"),
        Action(title: "Verify email", subtitle: "Tonal verification.", icon: "checkmark.seal", successIcon: "checkmark.seal.fill", successTitle: "Verified", variant: .tonal),
        Action(title: "Enable Face ID", subtitle: "Biometric opt-in.", icon: "faceid", successIcon: "checkmark", successTitle: "Enabled", variant: .outlined),
        Action(title: "Change password", subtitle: "Account security.", icon: "key", successIcon: "checkmark", successTitle: "Password updated"),
        Action(title: "Add phone number", subtitle: "Two-factor setup.", icon: "phone.badge.plus", successIcon: "checkmark", successTitle: "Added", variant: .tonal),
        Action(title: "Accept invitation", subtitle: "Team invite acceptance.", icon: "envelope.badge", successIcon: "checkmark", successTitle: "Joined team"),
    ].map { sample($0, category: .auth) }
}
