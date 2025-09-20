import Foundation

struct AIInsight: Identifiable, Codable {
    let id = UUID()
    var content: String
    var type: InsightType
    var category: InsightCategory
    var createdAt: Date
    var isRead: Bool
    var actionable: Bool
    
    enum InsightType: String, CaseIterable, Codable {
        case tip = "Tip"
        case warning = "Warning"
        case opportunity = "Opportunity"
        case analysis = "Analysis"
    }
    
    enum InsightCategory: String, CaseIterable, Codable {
        case workspace = "Workspace"
        case finance = "Finance"
        case residents = "Residents"
        case schedule = "Schedule"
        case growth = "Growth"
        case general = "General"
    }
}
