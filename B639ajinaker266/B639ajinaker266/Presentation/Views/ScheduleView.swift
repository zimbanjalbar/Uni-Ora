import SwiftUI

struct ScheduleView: View {
    @StateObject private var scheduleUseCase = ScheduleUseCase()
    @StateObject private var aiService = OpenAIService()
    @State private var selectedDate = Date()
    @State private var showingAddBooking = false
    @State private var selectedBooking: ScheduleBooking?
    @State private var showingBookingEditor = false
    @State private var aiInsight = ""
    @State private var showingAIInsight = false
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Schedule 📅")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button("AI Insight") {
                            generateAIInsight()
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.75, green: 0.79, blue: 0.2).opacity(0.8))
                        )
                    }
                    
                    // Date Picker
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white.opacity(0.2))
                                .padding(.horizontal, -16)
                                .padding(.vertical, -8)
                        )
                    
                    // Quick Stats
                    HStack(spacing: 16) {
                        StatCard(
                            title: "Today",
                            count: scheduleUseCase.getTodaysBookings().count,
                            color: .green
                        )
                        
                        StatCard(
                            title: "Upcoming",
                            count: scheduleUseCase.getUpcomingBookings().count,
                            color: .blue
                        )
                        
                        RevenueStatCard(
                            title: "Revenue",
                            amount: todayRevenue,
                            color: .orange
                        )
                    }
                }
                .padding()
                
                // Bookings List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        HStack {
                            Text("Bookings for \(selectedDate, formatter: dateFormatter)")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button("Add Booking") {
                                showingAddBooking = true
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
                        .padding(.horizontal)
                        
                        ForEach(bookingsForSelectedDate) { booking in
                            BookingCard(booking: booking) {
                                selectedBooking = booking
                                showingBookingEditor = true
                            }
                        }
                        
                        if bookingsForSelectedDate.isEmpty {
                            EmptyStateView(
                                icon: "calendar",
                                title: "No bookings",
                                subtitle: "No bookings scheduled for this date"
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            if aiService.isLoading {
                LoadingView()
            }
        }
        .sheet(isPresented: $showingAddBooking) {
            BookingEditorView(booking: nil, selectedDate: selectedDate) { newBooking in
                scheduleUseCase.addBooking(newBooking)
            }
        }
        .sheet(isPresented: $showingBookingEditor) {
            if let booking = selectedBooking {
                BookingEditorView(booking: booking, selectedDate: selectedDate) { updatedBooking in
                    scheduleUseCase.updateBooking(updatedBooking)
                }
            } else {
                EmptyView()
            }
        }
        .alert("AI Insight", isPresented: $showingAIInsight) {
            Button("OK") { }
        } message: {
            Text(aiInsight)
        }
        .onAppear {
            scheduleUseCase.loadBookings()
        }
    }
    
    private var bookingsForSelectedDate: [ScheduleBooking] {
        scheduleUseCase.getBookingsForDate(selectedDate)
            .sorted { $0.startTime < $1.startTime }
    }
    
    private var todayRevenue: Double {
        let today = Date()
        let startOfDay = Calendar.current.startOfDay(for: today)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? today
        let interval = DateInterval(start: startOfDay, end: endOfDay)
        return scheduleUseCase.getTotalBookingRevenue(for: interval)
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private func generateAIInsight() {
        Task {
            do {
                let insight = try await scheduleUseCase.generateAIInsight()
                await MainActor.run {
                    aiInsight = insight
                    showingAIInsight = true
                }
            } catch {
                await MainActor.run {
                    aiInsight = "Unable to generate insight. Please check your connection."
                    showingAIInsight = true
                }
            }
        }
    }
}

struct BookingCard: View {
    let booking: ScheduleBooking
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ColoredCard(color: statusColor(for: booking.status)) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(booking.title)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        StatusBadge(
                            text: booking.status.rawValue,
                            color: statusColor(for: booking.status)
                        )
                    }
                    
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(.secondary)
                        Text(booking.spaceName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                        Text("\(booking.startTime, formatter: timeFormatter) - \(booking.endTime, formatter: timeFormatter)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.secondary)
                        Text(booking.bookedBy)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("$\(booking.cost, specifier: "%.0f")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    
                    if booking.attendees > 1 {
                        HStack {
                            Image(systemName: "person.2")
                                .foregroundColor(.blue)
                            Text("\(booking.attendees) attendees")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func statusColor(for status: ScheduleBooking.BookingStatus) -> Color {
        switch status {
        case .confirmed: return .green
        case .pending: return .orange
        case .cancelled: return .red
        case .completed: return .blue
        }
    }
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

struct BookingEditorView: View {
    @State private var booking: ScheduleBooking
    let selectedDate: Date
    let onSave: (ScheduleBooking) -> Void
    @Environment(\.dismiss) private var dismiss
    
    private let isNewBooking: Bool
    
    init(booking: ScheduleBooking?, selectedDate: Date, onSave: @escaping (ScheduleBooking) -> Void) {
        self.selectedDate = selectedDate
        if let booking = booking {
            _booking = State(initialValue: booking)
            isNewBooking = false
        } else {
            let startTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: selectedDate) ?? selectedDate
            let endTime = Calendar.current.date(byAdding: .hour, value: 1, to: startTime) ?? startTime
            
            _booking = State(initialValue: ScheduleBooking(
                title: "",
                spaceId: UUID(),
                spaceName: "Meeting Room 1",
                startTime: startTime,
                endTime: endTime,
                bookedBy: "",
                attendees: 1,
                notes: "",
                status: .confirmed,
                cost: 25.0
            ))
            isNewBooking = true
        }
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Booking Details") {
                    TextField("Title", text: $booking.title)
                    TextField("Space Name", text: $booking.spaceName)
                    TextField("Booked By", text: $booking.bookedBy)
                    
                    Stepper("Attendees: \(booking.attendees)", value: $booking.attendees, in: 1...20)
                    
                    Picker("Status", selection: $booking.status) {
                        ForEach(ScheduleBooking.BookingStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }
                
                Section("Time & Cost") {
                    DatePicker("Start Time", selection: $booking.startTime, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("End Time", selection: $booking.endTime, displayedComponents: [.date, .hourAndMinute])
                    
                    HStack {
                        Text("Cost:")
                        Spacer()
                        TextField("Cost", value: $booking.cost, format: .currency(code: "USD"))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120)
                    }
                    
                    Text("Duration: \(booking.durationHours, specifier: "%.1f") hours")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Notes") {
                    TextField("Additional notes...", text: $booking.notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isNewBooking ? "Add Booking" : "Edit Booking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(booking)
                        dismiss()
                    }
                    .disabled(booking.title.isEmpty || booking.bookedBy.isEmpty)
                }
            }
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.5))
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ScheduleView()
}
