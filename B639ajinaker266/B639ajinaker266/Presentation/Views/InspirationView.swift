import SwiftUI

struct InspirationView: View {
    @StateObject private var insightUseCase = AIInsightUseCase()
    @State private var currentTipIndex = 0
    @State private var showingAllInsights = false
    
    private let staticTips = [
        InspirationTip(
            title: "Create Community Spaces",
            content: "Design areas that encourage interaction - communal kitchens, lounge areas, and collaboration zones help build a strong community.",
            category: "Space Design",
            icon: "person.2"
        ),
        InspirationTip(
            title: "Flexible Membership Plans",
            content: "Offer various membership tiers - from day passes to dedicated desks. This attracts different types of professionals and maximizes revenue.",
            category: "Business Model",
            icon: "creditcard"
        ),
        InspirationTip(
            title: "Host Regular Events",
            content: "Organize networking events, workshops, and social gatherings. Events build community and attract potential new members.",
            category: "Community Building",
            icon: "calendar"
        ),
        InspirationTip(
            title: "Invest in Good WiFi",
            content: "Reliable, fast internet is non-negotiable. Consider redundant connections and ensure coverage throughout your space.",
            category: "Infrastructure",
            icon: "wifi"
        ),
        InspirationTip(
            title: "Create Quiet Zones",
            content: "Balance collaborative spaces with quiet areas for focused work. Phone booths and silent zones are highly valued by members.",
            category: "Space Design",
            icon: "speaker.slash"
        ),
        InspirationTip(
            title: "Member Feedback System",
            content: "Regularly collect and act on member feedback. Happy members become your best marketing tool through word-of-mouth.",
            category: "Member Experience",
            icon: "heart"
        )
    ]
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Inspiration & Growth 🚀")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button("All Insights") {
                                showingAllInsights = true
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.75, green: 0.79, blue: 0.2).opacity(0.8))
                            )
                        }
                        
                        Text("Daily tips and insights to grow your coworking space")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal)
                    
                    // Daily AI Tip
                    if !insightUseCase.dailyTip.isEmpty {
                        ColoredCard(color: Color(red: 0.75, green: 0.79, blue: 0.2)) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "brain.head.profile")
                                        .foregroundColor(Color(red: 0.75, green: 0.79, blue: 0.2))
                                    
                                    Text("AI Daily Tip")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                    
                                    Button("Refresh") {
                                        refreshDailyTip()
                                    }
                                    .font(.caption)
                                    .foregroundColor(Color(red: 0.75, green: 0.79, blue: 0.2))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .stroke(Color(red: 0.75, green: 0.79, blue: 0.2), lineWidth: 1)
                                    )
                                }
                                
                                Text(insightUseCase.dailyTip)
                                    .font(.subheadline)
                                    .lineLimit(nil)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Featured Tip Carousel
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Growth Tips")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                ForEach(0..<staticTips.count, id: \.self) { index in
                                    Circle()
                                        .fill(index == currentTipIndex ? .white : .white.opacity(0.3))
                                        .frame(width: 8, height: 8)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        TabView(selection: $currentTipIndex) {
                            ForEach(Array(staticTips.enumerated()), id: \.offset) { index, tip in
                                TipCard(tip: tip)
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(height: 200)
                    }
                    
                    
                    // Recent AI Insights
                    if !insightUseCase.insights.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent AI Insights")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            LazyVStack(spacing: 12) {
                                ForEach(Array(insightUseCase.insights.prefix(3))) { insight in
                                    AIInsightCard(insight: insight) {
                                        insightUseCase.markInsightAsRead(insight.id)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .sheet(isPresented: $showingAllInsights) {
            AllInsightsView(insightUseCase: insightUseCase)
        }
        .onAppear {
            insightUseCase.loadInsights()
            if insightUseCase.dailyTip.isEmpty || shouldRefreshDailyTip() {
                refreshDailyTip()
            }
        }
    }
    
    private func refreshDailyTip() {
        Task {
            await insightUseCase.generateDailyTip()
        }
    }
    
    private func shouldRefreshDailyTip() -> Bool {
        // Check if we should refresh the daily tip (e.g., once per day)
        let lastRefresh = UserDefaults.standard.object(forKey: "last_tip_refresh") as? Date ?? Date.distantPast
        return Calendar.current.isDate(Date(), inSameDayAs: lastRefresh) == false
    }
}

struct InspirationTip {
    let title: String
    let content: String
    let category: String
    let icon: String
}

struct TipCard: View {
    let tip: InspirationTip
    
    var body: some View {
        ColoredCard(color: categoryColor(for: tip.category)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: tip.icon)
                        .font(.title2)
                        .foregroundColor(categoryColor(for: tip.category))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(tip.category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(tip.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                }
                
                Text(tip.content)
                    .font(.subheadline)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal)
    }
    
    private func categoryColor(for category: String) -> Color {
        switch category {
        case "Space Design": return .blue
        case "Business Model": return .green
        case "Community Building": return .orange
        case "Infrastructure": return .purple
        case "Member Experience": return .pink
        default: return .gray
        }
    }
}


struct AIInsightCard: View {
    let insight: AIInsight
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ColoredCard(color: typeColor(for: insight.type)) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        StatusBadge(
                            text: insight.type.rawValue,
                            color: typeColor(for: insight.type)
                        )
                        
                        Spacer()
                        
                        if !insight.isRead {
                            Circle()
                                .fill(.red)
                                .frame(width: 8, height: 8)
                        }
                        
                        Text(insight.createdAt, formatter: relativeDateFormatter)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(insight.content)
                        .font(.subheadline)
                        .lineLimit(3)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func typeColor(for type: AIInsight.InsightType) -> Color {
        switch type {
        case .tip: return .blue
        case .warning: return .orange
        case .opportunity: return .green
        case .analysis: return .purple
        }
    }
    
    private let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
}

struct AllInsightsView: View {
    @ObservedObject var insightUseCase: AIInsightUseCase
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedBackground()
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(insightUseCase.insights) { insight in
                            AIInsightCard(insight: insight) {
                                insightUseCase.markInsightAsRead(insight.id)
                            }
                        }
                        
                        if insightUseCase.insights.isEmpty {
                            EmptyStateView(
                                icon: "lightbulb",
                                title: "No insights yet",
                                subtitle: "AI insights will appear here as you use the app"
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("All Insights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    InspirationView()
}
