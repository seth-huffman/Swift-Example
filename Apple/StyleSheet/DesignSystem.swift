//
//  DesignSystem.swift
//  Apple
//

import SwiftUI

// MARK: - Design Tokens

enum DS {
    // Colors
    static let cyan       = Color(hex: "3DD9EB")
    static let cyanLight  = Color(hex: "E8F9FC")
    static let cyanMid    = Color(hex: "A8EAF4")
    static let bg         = Color(hex: "F0F5F8")
    static let white      = Color.white
    static let text       = Color(hex: "1A2B3C")
    static let textMid    = Color(hex: "5A7080")
    static let textLight  = Color(hex: "9BB0BC")

    // Corner radii
    static let radiusPill: CGFloat  = 50
    static let radiusCard: CGFloat  = 24
    static let radiusInput: CGFloat = 14

    // Shadows
    static let shadowCyan = Color(hex: "3DD9EB").opacity(0.18)
    static let shadowDark = Color(hex: "1A2B3C").opacity(0.06)
}

// MARK: - Color Init from Hex

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var v: UInt64 = 0
        Scanner(string: h).scanHexInt64(&v)
        self.init(
            red:   Double((v >> 16) & 0xFF) / 255,
            green: Double((v >>  8) & 0xFF) / 255,
            blue:  Double( v        & 0xFF) / 255
        )
    }
}

extension UIColor {
    convenience init(hex: String) {
        let h = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var v: UInt64 = 0
        Scanner(string: h).scanHexInt64(&v)
        self.init(
            red:   CGFloat((v >> 16) & 0xFF) / 255,
            green: CGFloat((v >>  8) & 0xFF) / 255,
            blue:  CGFloat( v        & 0xFF) / 255,
            alpha: 1
        )
    }
}
