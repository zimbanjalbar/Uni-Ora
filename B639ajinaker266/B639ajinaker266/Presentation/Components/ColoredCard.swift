import SwiftUI

struct ColoredCard<Content: View>: View {
    let color: Color
    let content: Content
    
    init(color: Color, @ViewBuilder content: () -> Content) {
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

struct StatusBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.2))
            )
            .foregroundColor(color)
    }
}

struct ActionButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(color)
                )
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            
            Text("AI is thinking...")
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.black.opacity(0.7)
                .ignoresSafeArea()
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        ColoredCard(color: .blue) {
            VStack(alignment: .leading) {
                Text("Sample Card")
                    .font(.headline)
                StatusBadge(text: "Active", color: .green)
                ActionButton(title: "Action", color: .blue) {
                    // Action
                }
            }
        }
        
        LoadingView()
    }
    .padding()
    .background(AnimatedBackground())
}
