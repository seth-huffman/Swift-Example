import SwiftUI

struct SplashScreen: View {
    @State private var textOpacity = 0.0
    @State private var textScale = 0.4
    var onFinished: () -> Void

    var body: some View {
        ZStack {
            // MARK: - Solid High-Contrast Background
            DS.text
                .ignoresSafeArea()

            // MARK: - Neon Typography
            VStack(spacing: 0) {
                Text("Cocktail")
                    .font(.custom("Yellowtail", size: 130))
                    .foregroundColor(.white)
                    .shadow(color: DS.cyan.opacity(0.8), radius: 10, x: 0, y: 0)
                    .shadow(color: DS.cyan.opacity(0.4), radius: 30, x: 0, y: 0)
                    .frame(maxWidth: .infinity)
                
                Text("CREATOR")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .tracking(25)
                    .foregroundColor(DS.cyanMid)
                    .padding(.leading, 25)
            }
            .scaleEffect(textScale)
            .opacity(textOpacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0)) {
                textOpacity = 1.0
                textScale = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    onFinished()
                }
            }
        }
    }
}
