//
//  Theme.swift
//  time-zone-slider
//
//  Design tokens from the Claude Design "Organic" design system
//  (_ds/organic-…/styles.css in the Timezone Converter design project).
//

import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

enum Theme {
    static let bg = Color(hex: 0xF5EAD8)
    static let text = Color(hex: 0x201E1D)
    static let divider = Color(hex: 0x201E1D).opacity(0.16)

    static let neutral100 = Color(hex: 0xF9F4ED)
    static let neutral200 = Color(hex: 0xEEE7DB)
    static let neutral300 = Color(hex: 0xDCD3C4)
    static let neutral600 = Color(hex: 0x82796A)
    static let neutral700 = Color(hex: 0x645C50)
    static let neutral800 = Color(hex: 0x474238)
    static let neutral900 = Color(hex: 0x2E2B25)

    static let accent100 = Color(hex: 0xFFF2EB)
    static let accent200 = Color(hex: 0xFFE1D0)
    static let accent300 = Color(hex: 0xFFC6A5)
    static let accent500 = Color(hex: 0xD67F48)
    static let accent600 = Color(hex: 0xB2622D)
    static let accent700 = Color(hex: 0x8C491A)
    static let accent800 = Color(hex: 0x643312)

    static let accent2_200 = Color(hex: 0xE1EECC)
    static let accent2_800 = Color(hex: 0x3D472B)

    static let radiusLg: CGFloat = 28

    // The design uses Caprasimo (display serif) for headings and Figtree for
    // body text; without bundling the fonts, system serif/sans are the
    // closest match.
    static func heading(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .serif)
    }
}

struct BadgeStyle: ViewModifier {
    let background: Color
    let foreground: Color

    func body(content: Content) -> some View {
        content
            .font(.system(size: 10.5, weight: .semibold))
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
