import Foundation

struct Resident: Identifiable, Codable {
    let id = UUID()
    var name: String
    var email: String
    var phone: String
    var contractType: ContractType
    var startDate: Date
    var endDate: Date
    var monthlyRate: Double
    var status: ResidentStatus
    var notes: String
    
    enum ContractType: String, CaseIterable, Codable {
        case monthly = "Monthly"
        case quarterly = "Quarterly"
        case yearly = "Yearly"
        case dayPass = "Day Pass"
    }
    
    enum ResidentStatus: String, CaseIterable, Codable {
        case active = "Active"
        case expiring = "Expiring Soon"
        case expired = "Expired"
        case suspended = "Suspended"
    }
    
    var daysUntilExpiry: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0
    }
}
