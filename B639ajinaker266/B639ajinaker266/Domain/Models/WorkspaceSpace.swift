import Foundation

struct WorkspaceSpace: Identifiable, Codable {
    let id = UUID()
    var number: Int
    var type: SpaceType
    var status: SpaceStatus
    var bookedBy: String?
    var bookedUntil: Date?
    var pricePerHour: Double
    
    enum SpaceType: String, CaseIterable, Codable {
        case hotDesk = "Hot Desk"
        case privateOffice = "Private Office"
        case meetingRoom = "Meeting Room"
        case phoneRoom = "Phone Room"
    }
    
    enum SpaceStatus: String, CaseIterable, Codable {
        case available = "Available"
        case booked = "Booked"
        case extended = "Extended"
        case maintenance = "Maintenance"
    }
}
