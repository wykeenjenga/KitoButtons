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

## Use on a plain SwiftUI Button

```swift
Button("Save") { save() }
    .buttonStyle(.kito(.outlined, size: .medium, fullWidth: true))
```

## Sample app

`Examples/KitShowcase` in the parent repository shows every variant, size and state side by side with a live theme switcher.
