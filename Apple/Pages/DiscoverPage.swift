//
//  DiscoverPage.swift
//  Apple
//

import SwiftUI

struct DiscoverPage: View {
    @Binding var selectedSpirit: String
    @Binding var selectedFlavor: String
    @Binding var showResults: Bool

    var body: some View {
        ZStack {
            if showResults {
                ResultsPage(
                    spirit: selectedSpirit,
                    flavor: selectedFlavor,
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.3)) { showResults = false }
                    }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                WheelSelectorView(
                    selectedSpirit: $selectedSpirit,
                    selectedFlavor: $selectedFlavor,
                    onCraft: {
                        withAnimation(.easeInOut(duration: 0.3)) { showResults = true }
                    }
                )
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
    }
}
