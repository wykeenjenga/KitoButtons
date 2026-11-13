//
//  KitoButtonsLocalization.swift
//  KitoButtons
//
//  Created by Wycliff Njenga on 16/09/2026.
//  Copyright © 2026 Wycliff Njenga. All rights reserved.
//

import Foundation

/// Localization entry point for the few strings KitoButtons produces itself: default cart titles
/// and accessibility values. English, Swahili (`sw`) and French (`fr`) are bundled; set `provider`
/// to override or add languages from your app.
public enum KitoButtonsLocalization {
    /// Consulted before the bundled `Localizable.strings`; return nil to fall back.
    public static var provider: ((_ key: String, _ fallback: String) -> String?)?

    public static var bundle: Bundle { resolvedBundle }

    // Resolve the resource bundle defensively. The compiler-generated `Bundle.module` accessor calls
    // `fatalError` when it can't locate `KitoButtons_KitoButtons.bundle` (some app embedding setups
    // don't copy SPM resource bundles) — which crashed the app the moment a button entered a phase and
    // read its localized accessibility value. Search the same candidate locations, then fall back to
    // the framework bundle so `localizedString` just returns the English fallback instead of trapping.
    private static let resolvedBundle: Bundle = {
        let host = Bundle(for: BundleToken.self)
        #if SWIFT_PACKAGE
        let bundleName = "KitoButtons_KitoButtons"
        let candidates: [URL?] = [
            Bundle.main.resourceURL,
            host.resourceURL,
            Bundle.main.bundleURL,
            host.bundleURL,
            host.resourceURL?.deletingLastPathComponent(),
        ]
        for case let directory? in candidates {
            if let bundle = Bundle(url: directory.appendingPathComponent(bundleName + ".bundle")) { return bundle }
        }
        #else
        if let url = host.url(forResource: "KitoButtons", withExtension: "bundle"), let bundle = Bundle(url: url) { return bundle }
        #endif
        return host
    }()

    public static func string(_ key: String, _ fallback: String) -> String {
        if let custom = provider?(key, fallback) { return custom }
        return bundle.localizedString(forKey: key, value: fallback, table: nil)
    }

    public static func format(_ key: String, _ fallback: String, _ arguments: CVarArg...) -> String {
        String(format: string(key, fallback), locale: .current, arguments: arguments)
    }

    /// Keys defined for a language, for parity tests and custom providers.
    public static func keys(forLanguage code: String) -> Set<String> {
        guard let path = bundle.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: code),
              let dictionary = NSDictionary(contentsOfFile: path) as? [String: String] else { return [] }
        return Set(dictionary.keys)
    }
}

private final class BundleToken {}
