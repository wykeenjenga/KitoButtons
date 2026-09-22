//
//  KitoAccessibilitySupport.swift
//  KitoButtons
//
//  Created by Wycliff Njenga on 22/09/2026.
//  Copyright © 2026 Wycliff Njenga. All rights reserved.
//

import SwiftUI

extension View {
    /// Applies `.accessibilityIdentifier` only when `id` is set, so a nil override renders
    /// identically to a view with no identifier at all.
    @ViewBuilder func kitoAccessibilityIdentifier(_ id: String?) -> some View {
        if let id {
            self.accessibilityIdentifier(id)
        } else {
            self
        }
    }

    /// Applies `.accessibilityHint` only when `hint` is set.
    @ViewBuilder func kitoAccessibilityHint(_ hint: String?) -> some View {
        if let hint {
            self.accessibilityHint(hint)
        } else {
            self
        }
    }
}
