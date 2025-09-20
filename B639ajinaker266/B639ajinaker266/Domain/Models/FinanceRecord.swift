import Foundation

struct FinanceRecord: Identifiable, Codable {
    let id = UUID()
    var title: String
    var amount: Double
    var type: TransactionType
    var category: FinanceCategory
    var date: Date
    var description: String
    var relatedResidentId: UUID?
    var relatedSpaceId: UUID?
    var isPaid: Bool
    
    enum TransactionType: String, CaseIterable, Codable {
        case income = "Income"
        case expense = "Expense"
    }
    
    enum FinanceCategory: String, CaseIterable, Codable {
        case membership = "Membership"
        case dayPass = "Day Pass"
        case meetingRoom = "Meeting Room"
        case utilities = "Utilities"
        case maintenance = "Maintenance"
        case marketing = "Marketing"
        case supplies = "Supplies"
        case other = "Other"
    }
}
