import SwiftUI

struct WorkspaceMapView: View {
    @StateObject private var workspaceUseCase = WorkspaceUseCase()
    @StateObject private var aiService = OpenAIService()
    @State private var showingSpaceEditor = false
    @State private var selectedSpace: WorkspaceSpace?
    @State private var showingTotalSpacesEditor = false
    @State private var aiInsight = ""
    @State private var showingAIInsight = false
    
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Workspace Map 🪑")
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
                        
                        HStack {
                            Text("Total Spaces: \(workspaceUseCase.totalSpaces)")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Button("Edit") {
                                showingTotalSpacesEditor = true
                            }
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .stroke(.white.opacity(0.5), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Statistics Cards
                    HStack(spacing: 16) {
                        StatCard(
                            title: "Available",
                            count: workspaceUseCase.getAvailableSpaces().count,
                            color: .green
                        )
                        
                        StatCard(
                            title: "Booked",
                            count: workspaceUseCase.getBookedSpaces().count,
                            color: .orange
                        )
                        
                        StatCard(
                            title: "Total",
                            count: workspaceUseCase.spaces.count,
                            color: .blue
                        )
                    }
                    .padding(.horizontal)
                    
                    // Spaces Grid
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(workspaceUseCase.spaces) { space in
                            SpaceCard(space: space) {
                                selectedSpace = space
                                showingSpaceEditor = true
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            
            if aiService.isLoading {
                LoadingView()
            }
        }
        .sheet(isPresented: $showingSpaceEditor) {
            if let space = selectedSpace {
                SpaceEditorView(space: space) { updatedSpace in
                    workspaceUseCase.updateSpace(updatedSpace)
                }
            } else {
                EmptyView()
            }
        }
        .sheet(isPresented: $showingTotalSpacesEditor) {
            TotalSpacesEditorView(totalSpaces: workspaceUseCase.totalSpaces) { newTotal in
                workspaceUseCase.updateTotalSpaces(newTotal)
            }
        }
        .alert("AI Insight", isPresented: $showingAIInsight) {
            Button("OK") { }
        } message: {
            Text(aiInsight)
        }
        .onAppear {
            workspaceUseCase.loadSpaces()
        }
    }
    
    private func generateAIInsight() {
        Task {
            do {
                let insight = try await workspaceUseCase.generateAIInsight()
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

struct StatCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(count)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

struct SpaceCard: View {
    let space: WorkspaceSpace
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("#\(space.number)")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    StatusBadge(
                        text: space.status.rawValue,
                        color: statusColor(for: space.status)
                    )
                }
                
                Text(space.type.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let bookedBy = space.bookedBy {
                    Text("Booked by: \(bookedBy)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("$\(space.pricePerHour, specifier: "%.0f")/hr")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func statusColor(for status: WorkspaceSpace.SpaceStatus) -> Color {
        switch status {
        case .available: return .green
        case .booked: return .orange
        case .extended: return .red
        case .maintenance: return .gray
        }
    }
}

struct SpaceEditorView: View {
    @State private var space: WorkspaceSpace
    let onSave: (WorkspaceSpace) -> Void
    @Environment(\.dismiss) private var dismiss
    
    init(space: WorkspaceSpace, onSave: @escaping (WorkspaceSpace) -> Void) {
        _space = State(initialValue: space)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Space Details") {
                    HStack {
                        Text("Number:")
                        Spacer()
                        Text("#\(space.number)")
                            .fontWeight(.semibold)
                    }
                    
                    Picker("Type", selection: $space.type) {
                        ForEach(WorkspaceSpace.SpaceType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    Picker("Status", selection: $space.status) {
                        ForEach(WorkspaceSpace.SpaceStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    
                    HStack {
                        Text("Price per hour:")
                        Spacer()
                        TextField("Price", value: $space.pricePerHour, format: .currency(code: "USD"))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 100)
                    }
                }
                
                if space.status == .booked || space.status == .extended {
                    Section("Booking Details") {
                        TextField("Booked by", text: Binding(
                            get: { space.bookedBy ?? "" },
                            set: { space.bookedBy = $0.isEmpty ? nil : $0 }
                        ))
                        
                        DatePicker("Booked until", 
                                 selection: Binding(
                                    get: { space.bookedUntil ?? Date() },
                                    set: { space.bookedUntil = $0 }
                                 ),
                                 displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle("Edit Space")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(space)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TotalSpacesEditorView: View {
    @State private var totalSpaces: Int
    let onSave: (Int) -> Void
    @Environment(\.dismiss) private var dismiss
    
    init(totalSpaces: Int, onSave: @escaping (Int) -> Void) {
        _totalSpaces = State(initialValue: totalSpaces)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Total Spaces") {
                    Stepper("Total: \(totalSpaces)", value: $totalSpaces, in: 1...100)
                    
                    Text("Adjusting this will add or remove spaces from your workspace.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Edit Total Spaces")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(totalSpaces)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    WorkspaceMapView()
}
