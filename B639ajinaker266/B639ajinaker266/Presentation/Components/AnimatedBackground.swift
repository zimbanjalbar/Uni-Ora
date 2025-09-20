import SwiftUI

struct AnimatedBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Base gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.46, blue: 0.82), // Cool blue
                    Color(red: 0.27, green: 0.35, blue: 0.39)  // Slate gray
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Floating icons
            ForEach(0..<6, id: \.self) { index in
                FloatingIcon(
                    systemName: iconNames[index % iconNames.count],
                    delay: Double(index) * 0.5,
                    animate: animate
                )
            }
        }
        .onAppear {
            animate = true
        }
    }
    
    private let iconNames = ["laptopcomputer", "desktopcomputer", "cup.and.saucer", "wifi", "person.2", "building.2"]
}

struct FloatingIcon: View {
    let systemName: String
    let delay: Double
    let animate: Bool
    
    @State private var yOffset: CGFloat = 0
    @State private var opacity: Double = 0.3
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 30, weight: .light))
            .foregroundColor(.white.opacity(opacity))
            .offset(y: yOffset)
            .position(
                x: CGFloat.random(in: 50...350),
                y: CGFloat.random(in: 100...700)
            )
            .onAppear {
                if animate {
                    withAnimation(
                        .easeInOut(duration: 3.0)
                        .repeatForever(autoreverses: true)
                        .delay(delay)
                    ) {
                        yOffset = CGFloat.random(in: -30...30)
                        opacity = Double.random(in: 0.1...0.4)
                    }
                }
            }
    }
}

#Preview {
    AnimatedBackground()
}
