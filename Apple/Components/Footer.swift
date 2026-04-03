//
//  Footer.swift
//  Apple
//

import SwiftUI

// MARK: - Tab Enum

enum AppTab: Int, CaseIterable {
    case discover, favorites, create, game, profile // Added .create

    var icon: String {
        switch self {
        case .discover:  return "sparkles"
        case .favorites: return "heart.fill"
        case .create:    return "plus.circle.fill" // Icon for create
        case .game:      return "gamecontroller.fill"
        case .profile:   return "person.fill"
        }
    }

    var label: String {
        switch self {
        case .discover:  return "Discover"
        case .favorites: return "Saved"
        case .create:    return "Create" // Label for create
        case .game:      return "Game"
        case .profile:   return "Profile"
        }
    }
}

// MARK: - Footer

struct Footer: View {
    @Binding var activeTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                FooterButton(tab: tab, isActive: activeTab == tab) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        activeTab = tab
                    }
                }
            }
        }
        .frame(maxWidth: 300)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(DS.cyanMid.opacity(0.45), lineWidth: 1)
                )
                .shadow(color: DS.shadowCyan, radius: 18, x: 0, y: 6)
                .shadow(color: DS.shadowDark, radius: 4,  x: 0, y: 2)
        )
        .padding(.horizontal, 28)
        .padding(.bottom, 28)
    }
}

// MARK: - Footer Button

struct FooterButton: View {
    let tab: AppTab
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    if isActive {
                        Capsule()
                            .fill(DS.cyan)
                            .frame(width: 46, height: 30)
                            .shadow(color: DS.shadowCyan, radius: 8, x: 0, y: 3)
                            .transition(.scale.combined(with: .opacity))
                    }

                    Image(systemName: tab.icon)
                        .font(.system(size: 16, weight: isActive ? .bold : .regular))
                        .foregroundColor(isActive ? .white : DS.textLight)
                        .frame(width: 46, height: 30)
                }

                Text(tab.label)
                    .font(.custom("Nunito-Bold", size: 10))
                    .foregroundColor(isActive ? DS.cyan : DS.textLight)
                    .tracking(0.3)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
