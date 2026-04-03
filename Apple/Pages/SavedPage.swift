//
//  SavedPage.swift
//  Apple
//

import SwiftUI

struct SavedPage: View {
    var body: some View {
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
        .background(DS.bg.ignoresSafeArea())
    }
}


