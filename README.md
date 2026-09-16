# KitoButtons

A comprehensive, themeable SwiftUI button: six variants, three sizes, icons, loading state, full width, async actions, per-button theme overrides, and a native `ButtonStyle` you can drop onto any existing `Button`.

- iOS 15+ / macOS 12+, pure SwiftUI, no dependencies
- Author: **Wycliff Njenga**
- Licence: MIT

## Installation

```swift
.package(url: "https://github.com/wykeenjenga/KitoButtons.git", from: "1.0.0")
```

Then `import KitoButtons`.

## Quick start

```swift
KitoButton("Continue", systemImage: "arrow.right", iconPlacement: .trailing) {
    await submit()            // spinner shows and the button disables until this returns
}
.fullWidth()
.size(.large)
.disabled(!formIsValid)
```

## Variants and sizes

```swift
KitoButton("Primary") {}                     // solid brand fill (default)
KitoButton("Tonal") {}.variant(.tonal)       // soft tinted fill
KitoButton("Outlined") {}.variant(.outlined)
KitoButton("Ghost") {}.variant(.ghost)       // text only, tint on press
KitoButton("Delete") {}.variant(.destructive)
KitoButton("Learn more") {}.variant(.link)

.size(.small) / .size(.medium) / .size(.large)
```

## Icons

```swift
KitoButton("Add to cart", systemImage: "cart.badge.plus") {}
KitoButton("Next", systemImage: "arrow.right", iconPlacement: .trailing) {}
KitoButton("Pay", image: Image("mpesa")) {}
KitoButton(systemImage: "heart", accessibilityLabel: "Like") {}   // icon-only, square
```

## State

```swift
.loading(isSaving)       // controlled spinner; async actions manage this automatically
.disabled(true)          // dims via theme.disabledOpacity
.role(.destructive)      // semantic role, also switches to the destructive variant
.haptics(false)
```

## Theme

```swift
.kitoButtonTheme { theme in
    theme.tint = .indigo
    theme.onTint = .white
    theme.shape = .capsule                      // .rectangle / .roundedRectangle(cornerRadius:) / .capsule
    theme.borderWidth = 1.5
    theme.shadow = KitoButtonShadow()
    theme.pressedScale = 0.97
    theme.overrides[.primary] = KitoButtonColors(background: .black, foreground: .yellow)
}
```

Set it once at the root of your app and override per screen or per button.

## Phases: loading → tick / shake

Async actions drive a `KitoButtonPhase` automatically. Opt into result feedback and the icon morphs
from its idle glyph to a checkmark (or shakes with a cross when the action throws), then returns to idle.

```swift
KitoButton("Add to cart", systemImage: "cart.badge.plus") {
    try await cart.add(product)
}
.showsResult()                                    // success and failure feedback
.successTitle("Added")                            // optional title swap
.resultIcons(success: "cart.fill.badge.plus")     // optional glyphs

KitoButton("Pay") {}.phase($phase)                // or drive the phase yourself
```

## Fly to cart

```swift
@StateObject var flights = KitoFlightController()

NavigationStack { list }
    .kitoFlightLayer(flights)                     // hosts the in-flight items
    .toolbar {
        KitoBadgeButton(systemImage: "cart", count: cart.count) { showCart = true }
            .bounces(on: flights.landings(on: "cart"))
            .kitoFlightAnchor("cart")             // the target
    }

KitoButton("Add", systemImage: "cart.badge.plus") { try await cart.add(product) }
    .showsResult()
    .flies(to: "cart", with: flights) { Image(product.image) }   // arcs from the button to the cart
```

Any view can be a source or target with `.kitoFlightAnchor(id)`, and you can launch a flight from
code with `flights.fly(from: "product-1", to: "cart") { ... }`. `KitoArcEffect` is public if you
want the arc motion elsewhere.

## Motion presets

All timings live in `KitoButtonTheme.motion` (`KitoButtonMotion`), exposed as computed presets:

```swift
.kitoButtonTheme { $0.motion = .lively }          // .default / .lively / .subtle
.kitoButtonTheme { $0.motion.resultDuration = 2 } // or tune one curve
```

Helpers: `.kitoButtonBounce(trigger:)` pops a view when a value changes (badges), `.kitoButtonShake(trigger:)` shakes it.

## Use on a plain SwiftUI Button

```swift
Button("Save") { save() }
    .buttonStyle(.kito(.outlined, size: .medium, fullWidth: true))
```

## Example app

`Example/KitoButtonsExample.xcodeproj` (in this repository) has four tabs: a gallery of every variant, size and state; a **Shop** with add-to-cart flights, a bouncing cart badge and heart-to-favourites flights; **Phases** showing automatic and manual loading/success/failure; and a live appearance and motion switcher. Regenerate the project with `xcodegen generate` after editing `Example/project.yml`.
