import Foundation

class LocalStorageService: ObservableObject {
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Workspace Spaces
    func saveSpaces(_ spaces: [WorkspaceSpace]) {
        if let encoded = try? JSONEncoder().encode(spaces) {
            userDefaults.set(encoded, forKey: "workspace_spaces")
        }
    }
    
    func loadSpaces() -> [WorkspaceSpace] {
        guard let data = userDefaults.data(forKey: "workspace_spaces"),
              let spaces = try? JSONDecoder().decode([WorkspaceSpace].self, from: data) else {
            return createDefaultSpaces()
        }
        return spaces
    }
    
    private func createDefaultSpaces() -> [WorkspaceSpace] {
        var spaces: [WorkspaceSpace] = []
        
        // Hot desks
        for i in 1...10 {
            spaces.append(WorkspaceSpace(
                number: i,
                type: .hotDesk,
                status: .available,
                pricePerHour: 15.0
            ))
        }
        
        // Private offices
        for i in 11...15 {
            spaces.append(WorkspaceSpace(
                number: i,
                type: .privateOffice,
                status: .available,
                pricePerHour: 35.0
            ))
        }
        
        // Meeting rooms
        for i in 16...20 {
            spaces.append(WorkspaceSpace(
                number: i,
                type: .meetingRoom,
                status: .available,
                pricePerHour: 25.0
            ))
        }
        
        saveSpaces(spaces)
        return spaces
    }
    
    // MARK: - Residents
    func saveResidents(_ residents: [Resident]) {
        if let encoded = try? JSONEncoder().encode(residents) {
            userDefaults.set(encoded, forKey: "residents")
        }
    }
    
    func loadResidents() -> [Resident] {
        guard let data = userDefaults.data(forKey: "residents"),
              let residents = try? JSONDecoder().decode([Resident].self, from: data) else {
            return []
        }
        return residents
    }
    
    // MARK: - Schedule Bookings
    func saveBookings(_ bookings: [ScheduleBooking]) {
        if let encoded = try? JSONEncoder().encode(bookings) {
            userDefaults.set(encoded, forKey: "schedule_bookings")
        }
    }
    
    func loadBookings() -> [ScheduleBooking] {
        guard let data = userDefaults.data(forKey: "schedule_bookings"),
              let bookings = try? JSONDecoder().decode([ScheduleBooking].self, from: data) else {
            return []
        }
        return bookings
    }
    
    // MARK: - Finance Records
    func saveFinanceRecords(_ records: [FinanceRecord]) {
        if let encoded = try? JSONEncoder().encode(records) {
            userDefaults.set(encoded, forKey: "finance_records")
        }
    }
    
    func loadFinanceRecords() -> [FinanceRecord] {
        guard let data = userDefaults.data(forKey: "finance_records"),
              let records = try? JSONDecoder().decode([FinanceRecord].self, from: data) else {
            return []
        }
        return records
    }
    
    // MARK: - AI Insights
    func saveInsights(_ insights: [AIInsight]) {
        if let encoded = try? JSONEncoder().encode(insights) {
            userDefaults.set(encoded, forKey: "ai_insights")
        }
    }
    
    func loadInsights() -> [AIInsight] {
        guard let data = userDefaults.data(forKey: "ai_insights"),
              let insights = try? JSONDecoder().decode([AIInsight].self, from: data) else {
            return []
        }
        return insights
    }
    
    // MARK: - App Settings
    func saveTotalSpaces(_ count: Int) {
        userDefaults.set(count, forKey: "total_spaces")
    }
    
    func loadTotalSpaces() -> Int {
        let count = userDefaults.integer(forKey: "total_spaces")
        return count > 0 ? count : 20
    }
}
