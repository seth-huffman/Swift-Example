//
//  ProfilePage.swift
//  Apple
//

import SwiftUI

struct ProfilePage: View {
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 32) {
                    // MARK: - Header Image
                    ZStack {
                        Circle()
                            .fill(DS.cyanLight)
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(DS.cyan)
                    }
                    .padding(.top, 60)
                    
                    // MARK: - Text Content
                    VStack(spacing: 12) {
                        Text("Welcome to Cocktail App")
                            .font(.custom("Nunito-Black", size: 24))
                            .foregroundColor(DS.text)
                        
                        Text("Sign in to save your favorite recipes, track your mixology stats, and sync across devices.")
                            .font(.custom("Nunito-Medium", size: 15))
                            .foregroundColor(DS.textMid)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 40)
                    }
                    
                    // MARK: - Sign In Actions
                    VStack(spacing: 16) {
                        // Apple Sign In
                        Button(action: { /* Logic for Apple Sign In */ }) {
                            HStack(spacing: 10) {
                                Image(systemName: "applelogo")
                                    .font(.system(size: 18))
                                Text("Continue with Apple")
                                    .font(.custom("Nunito-Bold", size: 16))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: DS.radiusInput))
                        }
                        
                        // Email Sign In
                        Button(action: { /* Logic for Email Sign In */ }) {
                            Text("Sign in with Email")
                                .font(.custom("Nunito-Bold", size: 16))
                                .foregroundColor(DS.text)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(DS.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DS.radiusInput)
                                        .stroke(DS.textLight.opacity(0.2), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: DS.radiusInput))
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // MARK: - Footer Links
                    HStack(spacing: 20) {
                        Button("Privacy Policy") { }
                        Text("•")
                        Button("Terms of Service") { }
                    }
                    .font(.custom("Nunito-SemiBold", size: 12))
                    .foregroundColor(DS.textLight)
                }
            }
        }
        .background(DS.bg.ignoresSafeArea())
    }
}
