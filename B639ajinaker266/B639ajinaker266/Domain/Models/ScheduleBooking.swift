import Foundation

struct ScheduleBooking: Identifiable, Codable {
    let id = UUID()
    var title: String
    var spaceId: UUID
    var spaceName: String
    var startTime: Date
    var endTime: Date
    var bookedBy: String
    var attendees: Int
    var notes: String
    var status: BookingStatus
    var cost: Double
    
    enum BookingStatus: String, CaseIterable, Codable {
        case confirmed = "Confirmed"
        case pending = "Pending"
        case cancelled = "Cancelled"
        case completed = "Completed"
    }
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    var durationHours: Double {
        duration / 3600
    }
}
