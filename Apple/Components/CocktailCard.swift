//
//  CocktailCard.swift
//  Apple
//

import SwiftUI

// MARK: - Cocktail Card

struct CocktailCard: View {
    let cocktail: Cocktail
    let isExpanded: Bool
    let isSaved: Bool
    let onTap: () -> Void
    let onHeartTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header row
            HStack(alignment: .center, spacing: 12) {
                Button(action: onTap) {
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(cocktail.name)
                                .font(.custom("Nunito-ExtraBold", size: 16))
                                .foregroundColor(DS.text)
                            Text(cocktail.type.uppercased())
                                .font(.custom("Nunito-Bold", size: 11))
                                .foregroundColor(DS.textLight)
                                .tracking(1)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20).padding(.vertical, 18)
                }
                .buttonStyle(.plain)
                
                // Heart button
                Button(action: onHeartTap) {
                    ZStack {
                        Circle()
                            .fill(isSaved ? DS.cyan : DS.cyanLight)
                            .frame(width: 30, height: 30)
                        Image(systemName: isSaved ? "heart.fill" : "heart")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(isSaved ? .white : DS.cyan)
                            .scaleEffect(isSaved ? 1.1 : 1.0)
                    }
                }
                .buttonStyle(.plain)
                
                // Expand toggle button
                Button(action: onTap) {
                    ZStack {
                        Circle()
                            .fill(isExpanded ? DS.cyan : DS.cyanLight)
                            .frame(width: 30, height: 30)
                        Text("+")
                            .font(.system(size: 18, weight: .light))
                            .foregroundColor(isExpanded ? .white : DS.cyan)
                            .rotationEffect(.degrees(isExpanded ? 45 : 0))
                    }
                    .animation(.spring(response: 0.3), value: isExpanded)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 20)
            }
            .padding(.vertical, 18)

            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    Divider()
                        .background(DS.cyanLight)
                        .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 6) {
                        SectionLabel("Ingredients")
                        ForEach(cocktail.ingredients, id: \.self) { item in
                            HStack(alignment: .top, spacing: 10) {
                                Circle().fill(DS.cyan)
                                    .frame(width: 7, height: 7)
                                    .padding(.top, 6)
                                Text(item)
                                    .font(.custom("Nunito-SemiBold", size: 13))
                                    .foregroundColor(DS.textMid)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.horizontal, 20).padding(.top, 14)

                    VStack(alignment: .leading, spacing: 6) {
                        SectionLabel("Method")
                        ForEach(Array(cocktail.steps.enumerated()), id: \.offset) { i, step in
                            HStack(alignment: .top, spacing: 10) {
                                ZStack {
                                    Circle().fill(DS.cyan).frame(width: 20, height: 20)
                                    Text("\(i + 1)")
                                        .font(.custom("Nunito-Black", size: 10))
                                        .foregroundColor(.white)
                                }
                                .padding(.top, 3)
                                Text(step)
                                    .font(.custom("Nunito-SemiBold", size: 13))
                                    .foregroundColor(DS.textMid)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineSpacing(3)
                            }
                        }
                    }
                    .padding(.horizontal, 20).padding(.top, 4).padding(.bottom, 20)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(DS.white)
        .clipShape(RoundedRectangle(cornerRadius: DS.radiusCard, style: .continuous))
        .cardShadow(prominent: isExpanded)
    }
}
