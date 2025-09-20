import SwiftUI

struct AssistantView: View {
    @StateObject private var aiService = OpenAIService()
    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var isTyping = false
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Assistant 🤖")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Ask me anything about your coworking space")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    if aiService.isOffline {
                        HStack {
                            Image(systemName: "wifi.slash")
                                .foregroundColor(.orange)
                            Text("Reconnect to AI for new insights")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(.orange.opacity(0.2))
                        )
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Chat Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if messages.isEmpty {
                                WelcomeMessageView()
                            }
                            
                            ForEach(messages) { message in
                                ChatMessageView(message: message)
                                    .id(message.id)
                            }
                            
                            if isTyping {
                                TypingIndicatorView()
                                    .id("typing")
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: messages.count) { _ in
                        withAnimation {
                            if let lastId = messages.last?.id {
                                proxy.scrollTo(lastId, anchor: .bottom)
                            } else {
                                proxy.scrollTo("typing", anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: isTyping) { _ in
                        if isTyping {
                            withAnimation {
                                proxy.scrollTo("typing", anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input Area
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        TextField("Ask about your coworking space...", text: $inputText, axis: .vertical)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.white.opacity(0.9))
                            )
                            .lineLimit(1...4)
                            .onSubmit {
                                sendMessage()
                            }
                        
                        Button(action: sendMessage) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(Color(red: 0.75, green: 0.79, blue: 0.2))
                                )
                        }
                        .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || aiService.isLoading)
                    }
                    
                    // Quick Actions
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(quickActions, id: \.self) { action in
                                Button(action.title) {
                                    inputText = action.prompt
                                    sendMessage()
                                }
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(.white.opacity(0.2))
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
            
            if aiService.isLoading {
                LoadingView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    hideKeyboard()
                }
            }
        }
    }
    
    private let quickActions = [
        QuickAction(title: "Space Tips", prompt: "Give me tips to optimize my workspace layout"),
        QuickAction(title: "Revenue Ideas", prompt: "How can I increase revenue from my coworking space?"),
        QuickAction(title: "Member Retention", prompt: "What strategies help retain coworking members?"),
        QuickAction(title: "Marketing", prompt: "Suggest marketing ideas for my coworking space"),
        QuickAction(title: "Events", prompt: "What events should I host to attract more members?")
    ]
    
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty && !aiService.isLoading else { return }
        
        let userMessage = ChatMessage(content: text, isUser: true)
        messages.append(userMessage)
        inputText = ""
        isTyping = true
        
        Task {
            do {
                let response = try await aiService.generateInsight(prompt: text)
                await MainActor.run {
                    isTyping = false
                    let aiMessage = ChatMessage(content: response, isUser: false)
                    messages.append(aiMessage)
                }
            } catch {
                await MainActor.run {
                    isTyping = false
                    let errorMessage = ChatMessage(
                        content: "I'm having trouble connecting right now. Please check your internet connection and try again.",
                        isUser: false
                    )
                    messages.append(errorMessage)
                }
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp = Date()
}

struct QuickAction: Hashable {
    let title: String
    let prompt: String
}

struct ChatMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(red: 0.75, green: 0.79, blue: 0.2))
                        )
                        .foregroundColor(.white)
                    
                    Text(message.timestamp, formatter: timeFormatter)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(.white.opacity(0.2))
                            )
                        
                        Text(message.content)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(.white.opacity(0.9))
                            )
                            .foregroundColor(.black)
                    }
                    
                    Text(message.timestamp, formatter: timeFormatter)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.leading, 44)
                }
                
                Spacer()
            }
        }
    }
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

struct WelcomeMessageView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.7))
            
            Text("Welcome to your AI Assistant!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("I'm here to help you optimize your coworking space. Ask me about:")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 8) {
                WelcomeFeature(icon: "chart.line.uptrend.xyaxis", text: "Revenue optimization strategies")
                WelcomeFeature(icon: "person.2", text: "Member retention tips")
                WelcomeFeature(icon: "calendar", text: "Event planning ideas")
                WelcomeFeature(icon: "lightbulb", text: "Space improvement suggestions")
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct WelcomeFeature: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.75, green: 0.79, blue: 0.2))
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

struct TypingIndicatorView: View {
    @State private var animating = false
    
    var body: some View {
        HStack {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(.white.opacity(0.2))
                    )
                
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(.gray)
                            .frame(width: 8, height: 8)
                            .scaleEffect(animating ? 1.2 : 0.8)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                                value: animating
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.white.opacity(0.9))
                )
            }
            
            Spacer()
        }
        .onAppear {
            animating = true
        }
    }
}

#Preview {
    AssistantView()
}
