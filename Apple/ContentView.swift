//
//  ContentView.swift
//  Apple
//
//  Created by SETH HUFFMAN on 3/31/26.
//

import SwiftUI

struct ContentView: View {
    @State private var activeTab: AppTab = .discover
    @State private var showResults = false
    @State private var selectedSpirit = "Whiskey"
    @State private var selectedFlavor = "Smokey"

    var body: some View {
        ZStack(alignment: .bottom) {
            DS.bg.ignoresSafeArea()

            // MARK: - Page Content
            Group {
                switch activeTab {
                case .discover:
                    DiscoverPage(
                        selectedSpirit: $selectedSpirit,
                        selectedFlavor: $selectedFlavor,
                        showResults: $showResults
                    )
                case .favorites:
                    SavedPage()
                case .game:
                    CocktailDashView()
                case .profile:
                    ProfilePage()
                }
            }
            .padding(.bottom, 80)

            // MARK: - Footer
            Footer(activeTab: $activeTab)
        }
        .ignoresSafeArea(edges: .bottom)
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
