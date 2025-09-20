import Foundation

class AIInsightUseCase: ObservableObject {
    @Published var insights: [AIInsight] = []
    @Published var dailyTip: String = ""
    
    private let storageService = LocalStorageService()
    private let aiService = OpenAIService()
    
    init() {
        loadInsights()
        loadDailyTip()
    }
    
    func loadInsights() {
        insights = storageService.loadInsights()
    }
    
    func addInsight(_ insight: AIInsight) {
        insights.insert(insight, at: 0) // Add to beginning for newest first
        saveInsights()
    }
    
    func markInsightAsRead(_ insightId: UUID) {
        if let index = insights.firstIndex(where: { $0.id == insightId }) {
            insights[index].isRead = true
            saveInsights()
        }
    }
    
    func deleteInsight(_ insightId: UUID) {
        insights.removeAll { $0.id == insightId }
        saveInsights()
    }
    
    func getUnreadInsights() -> [AIInsight] {
        return insights.filter { !$0.isRead }
    }
    
    func getInsightsByCategory(_ category: AIInsight.InsightCategory) -> [AIInsight] {
        return insights.filter { $0.category == category }
    }
    
    func getInsightsByType(_ type: AIInsight.InsightType) -> [AIInsight] {
        return insights.filter { $0.type == type }
    }
    
    func getActionableInsights() -> [AIInsight] {
        return insights.filter { $0.actionable }
    }
    
    func generateDailyTip() async {
        do {
            let tip = try await aiService.generateDailyTip()
            await MainActor.run {
                dailyTip = tip
                saveDailyTip()
            }
        } catch {
            await MainActor.run {
                dailyTip = "Focus on creating a welcoming environment for your coworking members today!"
            }
        }
    }
    
    func generateInsightFromPrompt(_ prompt: String, category: AIInsight.InsightCategory) async {
        do {
            let content = try await aiService.generateInsight(prompt: prompt)
            let insight = AIInsight(
                content: content,
                type: .analysis,
                category: category,
                createdAt: Date(),
                isRead: false,
                actionable: true
            )
            
            await MainActor.run {
                addInsight(insight)
            }
        } catch {
            let errorInsight = AIInsight(
                content: "Unable to generate insight. Please check your internet connection and try again.",
                type: .warning,
                category: category,
                createdAt: Date(),
                isRead: false,
                actionable: false
            )
            
            await MainActor.run {
                addInsight(errorInsight)
            }
        }
    }
    
    private func loadDailyTip() {
        dailyTip = UserDefaults.standard.string(forKey: "daily_tip") ?? 
            "Welcome to your smart coworking assistant! Generate insights to optimize your space."
    }
    
    private func saveDailyTip() {
        UserDefaults.standard.set(dailyTip, forKey: "daily_tip")
    }
    
    private func saveInsights() {
        storageService.saveInsights(insights)
    }
}
