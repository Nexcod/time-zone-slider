//
//  Theme.swift
//  time-zone-slider
//
//  Design tokens from the Claude Design "Organic" design system
//  (_ds/organic-…/styles.css in the Timezone Converter design project).
//  Dark values are not in the source system — they mirror the light tonal
//  ramps around the same warm ink/cream anchors.
//

import SwiftUI
import UIKit

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(uiColor: UIColor(hex: hex))
    }

    /// Resolves to `light` or `dark` depending on the current appearance.
    static func adaptive(_ light: UInt32, _ dark: UInt32) -> Color {
        Color(uiColor: UIColor { trait in
            UIColor(hex: trait.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

enum Theme {
    static let bg = Color.adaptive(0xF5EAD8, 0x201E1D)
    static let text = Color.adaptive(0x201E1D, 0xF5EAD8)
    static let divider = Color.adaptive(0x201E1D, 0xF5EAD8).opacity(0.16)

    static let neutral100 = Color.adaptive(0xF9F4ED, 0x2E2B25)
    static let neutral200 = Color.adaptive(0xEEE7DB, 0x3A362E)
    static let neutral300 = Color.adaptive(0xDCD3C4, 0x474238)
    static let neutral600 = Color.adaptive(0x82796A, 0xA19786)
    static let neutral700 = Color.adaptive(0x645C50, 0xC0B6A5)
    static let neutral800 = Color.adaptive(0x474238, 0xDCD3C4)

    /// Ink used for shadows — stays dark in both appearances.
    static let ink = Color(hex: 0x2E2B25)

    static let accent = Color.adaptive(0xC67139, 0xD67F48)
    static let accent100 = Color.adaptive(0xFFF2EB, 0x402310)
    static let accent200 = Color.adaptive(0xFFE1D0, 0x643312)
    static let accent300 = Color.adaptive(0xFFC6A5, 0x8C491A)
    static let accent500 = Color(hex: 0xD67F48)
    static let accent600 = Color.adaptive(0xB2622D, 0xF6A06B)
    static let accent700 = Color.adaptive(0x8C491A, 0xFFC6A5)
    static let accent800 = Color.adaptive(0x643312, 0xFFE1D0)

    static let accent2_200 = Color.adaptive(0xE1EECC, 0x3D472B)
    static let accent2_800 = Color.adaptive(0x3D472B, 0xE1EECC)

    static let radiusLg: CGFloat = 28

    // Semantic text styles scale with Dynamic Type. The design uses Caprasimo
    // (display serif) for headings; system serif bold is the closest match
    // without bundling the font.
    static func heading(_ style: Font.TextStyle) -> Font {
        .system(style, design: .serif).weight(.bold)
    }
}

struct BadgeStyle: ViewModifier {
    let background: Color
    let foreground: Color

    func body(content: Content) -> some View {
        content
            .font(.caption2.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .foregroundStyle(foreground)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(background, in: Capsule())
    }
}

extension View {
    func badge(background: Color, foreground: Color) -> some View {
        modifier(BadgeStyle(background: background, foreground: foreground))
    }
}
