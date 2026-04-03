//
//  Components.swift
//  Apple
//

import SwiftUI

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Card Shadow Modifier

struct CardShadow: ViewModifier {
    var prominent: Bool = false
    func body(content: Content) -> some View {
        content
            .shadow(color: DS.shadowCyan, radius: prominent ? 14 : 10, x: 0, y: prominent ? 6 : 4)
            .shadow(color: DS.shadowDark, radius: prominent ? 4  : 3,  x: 0, y: prominent ? 2 : 1)
    }
}

extension View {
    func cardShadow(prominent: Bool = false) -> some View {
        modifier(CardShadow(prominent: prominent))
    }
}

// MARK: - Section Label

struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text.uppercased())
            .font(.custom("Nunito-Black", size: 10))
            .foregroundColor(DS.cyan)
            .tracking(1.4)
            .padding(.top, 10).padding(.bottom, 2)
    }
}
