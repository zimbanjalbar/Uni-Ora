import Foundation

class ScheduleUseCase: ObservableObject {
    @Published var bookings: [ScheduleBooking] = []
    
    private let storageService = LocalStorageService()
    private let aiService = OpenAIService()
    
    init() {
        loadBookings()
    }
    
    func loadBookings() {
        bookings = storageService.loadBookings()
    }
    
    func addBooking(_ booking: ScheduleBooking) {
        bookings.append(booking)
        saveBookings()
    }
    
    func updateBooking(_ booking: ScheduleBooking) {
        if let index = bookings.firstIndex(where: { $0.id == booking.id }) {
            bookings[index] = booking
            saveBookings()
        }
    }
    
    func deleteBooking(_ bookingId: UUID) {
        bookings.removeAll { $0.id == bookingId }
        saveBookings()
    }
    
    func getBookingsForDate(_ date: Date) -> [ScheduleBooking] {
        let calendar = Calendar.current
        return bookings.filter { booking in
            calendar.isDate(booking.startTime, inSameDayAs: date)
        }
    }
    
    func getUpcomingBookings() -> [ScheduleBooking] {
        return bookings.filter { $0.startTime > Date() && $0.status == .confirmed }
            .sorted { $0.startTime < $1.startTime }
    }
    
    func getTodaysBookings() -> [ScheduleBooking] {
        return getBookingsForDate(Date())
    }
    
    func getBookingConflicts(for newBooking: ScheduleBooking) -> [ScheduleBooking] {
        return bookings.filter { existingBooking in
            existingBooking.spaceId == newBooking.spaceId &&
            existingBooking.id != newBooking.id &&
            existingBooking.status == .confirmed &&
            (newBooking.startTime < existingBooking.endTime && newBooking.endTime > existingBooking.startTime)
        }
    }
    
    func isSpaceAvailable(spaceId: UUID, startTime: Date, endTime: Date) -> Bool {
        let tempBooking = ScheduleBooking(
            title: "",
            spaceId: spaceId,
            spaceName: "",
            startTime: startTime,
            endTime: endTime,
            bookedBy: "",
            attendees: 0,
            notes: "",
            status: .confirmed,
            cost: 0
        )
        return getBookingConflicts(for: tempBooking).isEmpty
    }
    
    func getTotalBookingRevenue(for period: DateInterval) -> Double {
        return bookings.filter { booking in
            period.contains(booking.startTime)
        }.reduce(0) { $0 + $1.cost }
    }
    
    func getPopularTimeSlots() -> [Int] {
        let hourCounts = Dictionary(grouping: bookings) { booking in
            Calendar.current.component(.hour, from: booking.startTime)
        }.mapValues { $0.count }
        
        return hourCounts.sorted { $0.value > $1.value }.prefix(3).map { $0.key }
    }
    
    func generateAIInsight() async throws -> String {
        return try await aiService.generateScheduleInsight(bookings: bookings)
    }
    
    private func saveBookings() {
        storageService.saveBookings(bookings)
    }
}
