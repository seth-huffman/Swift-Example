import SwiftUI

struct SplashScreen: View {
    @State private var textOpacity = 0.0
    @State private var textScale = 0.4
    var onFinished: () -> Void

    var body: some View {
        ZStack {
            // MARK: - Gradient Background (Light Blue to Dark Blue)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor(hex: "3DD9EB")),
                    Color(UIColor(hex: "1E8090"))
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // MARK: - Background Image with Low Opacity
            Image("bartender")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.1)

            // MARK: - Neon Typography
            VStack(spacing: 5) {
                Image("bartender-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .foregroundColor(.white)
                
                Text("Bartenders")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                
                Text("BEST FRIEND")
                    .font(.system(size: 12, weight: .medium))
                    .tracking(10)
                    .foregroundColor(DS.white)
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
