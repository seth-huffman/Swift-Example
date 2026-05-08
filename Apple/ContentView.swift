import SwiftUI

struct ContentView: View {
    // 1. Add state to track if splash screen is finished
    @State private var isSplashFinished = false
    
    @State private var activeTab: AppTab = .discover
    @State private var showResults = false
    @State private var selectedSpirit = "Whiskey"
    @State private var selectedFlavor = "Smokey"
    @State private var savedCocktails: [Cocktail] = []

    var body: some View {
        Group {
            if !isSplashFinished {
                // 2. Show the splash screen first
                SplashScreen {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isSplashFinished = true
                    }
                }
            } else {
                // 3. Your original content with the Footer bar
                ZStack(alignment: .bottom) {
                    DS.bg.ignoresSafeArea()

                    // MARK: - Page Content
                    Group {
                        switch activeTab {
                        case .discover:
                            DiscoverPage(
                                selectedSpirit: $selectedSpirit,
                                selectedFlavor: $selectedFlavor,
                                showResults: $showResults,
                                savedCocktails: $savedCocktails
                            )
                        case .favorites:
                            SavedPage(savedCocktails: $savedCocktails)
                        case .create:
                            CreateRecipePage() // Add this line
                        case .game:
                            CocktailDashView()
                        case .profile:
                            ProfilePage()
                        }
                    }
                    .padding(.bottom, 80)
                    .transition(.opacity) // Smooth entry after splash

                    // MARK: - Footer (Restored)
                    Footer(activeTab: $activeTab)
                }
                .ignoresSafeArea(edges: .bottom)
                .preferredColorScheme(.light)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
