//
//  SavedPage.swift
//  Apple
//

import SwiftUI

struct SavedPage: View {
    @Binding var savedCocktails: [Cocktail]
    @State private var expandedIndex: Int? = nil
    
    var body: some View {
        ZStack {
            if savedCocktails.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(DS.cyanLight)
                            .frame(width: 80, height: 80)
                        Image(systemName: "heart.fill")
                            .font(.system(size: 32))
                            .foregroundColor(DS.cyan)
                    }
                    Text("No saved cocktails yet")
                        .font(.custom("Nunito-ExtraBold", size: 20))
                        .foregroundColor(DS.text)
                    Text("Tap the heart on any cocktail\nto save it here.")
                        .font(.custom("Nunito-Medium", size: 14))
                        .foregroundColor(DS.textMid)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        Text("Saved Cocktails")
                            .font(.custom("Nunito-ExtraBold", size: 26))
                            .foregroundColor(DS.text)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 20)
                        
                        // Cards
                        VStack(spacing: 12) {
                            ForEach(Array(savedCocktails.enumerated()), id: \.element.id) { index, cocktail in
                                CocktailCard(
                                    cocktail: cocktail,
                                    isExpanded: expandedIndex == index,
                                    isSaved: true,
                                    onTap: {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                            expandedIndex = expandedIndex == index ? nil : index
                                        }
                                    },
                                    onHeartTap: {
                                        if let removeIndex = savedCocktails.firstIndex(where: { $0.id == cocktail.id }) {
                                            savedCocktails.remove(at: removeIndex)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .background(DS.bg.ignoresSafeArea())
    }
}


