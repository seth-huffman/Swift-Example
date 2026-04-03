//
//  ResultsPage.swift
//  Apple
//

import SwiftUI

struct ResultsPage: View {
    let spirit: String
    let flavor: String
    let onBack: () -> Void

    @State private var expandedIndex: Int? = 0
    var cocktails: [Cocktail] { getCocktails(spirit: spirit, flavor: flavor) }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // Header
                ZStack {
                    Text("Your Matches")
                        .font(.custom("Nunito-ExtraBold", size: 26))
                        .foregroundColor(DS.text)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(DS.textMid)
                                .frame(width: 40, height: 40)
                                .background(DS.white)
                                .clipShape(Circle())
                                .cardShadow()
                        }
                        .buttonStyle(ScaleButtonStyle())
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)

                HStack(spacing: 8) {
                    Text(spirit)
                        .font(.custom("Nunito-ExtraBold", size: 13))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18).padding(.vertical, 7)
                        .background(DS.cyan)
                        .clipShape(Capsule())
                        .shadow(color: DS.cyan.opacity(0.35), radius: 6, x: 0, y: 3)

                    Text(flavor)
                        .font(.custom("Nunito-ExtraBold", size: 13))
                        .foregroundColor(DS.text)
                        .padding(.horizontal, 18).padding(.vertical, 7)
                        .background(DS.white)
                        .clipShape(Capsule())
                        .cardShadow()
                }
                .padding(.bottom, 24)

                // Cards
                VStack(spacing: 12) {
                    ForEach(Array(cocktails.enumerated()), id: \.element.id) { index, cocktail in
                        CocktailCard(
                            cocktail: cocktail,
                            isExpanded: expandedIndex == index,
                            onTap: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    expandedIndex = expandedIndex == index ? nil : index
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .background(DS.bg.ignoresSafeArea())
    }
}
