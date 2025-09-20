import SwiftUI

struct ResidentsView: View {
    @StateObject private var residentUseCase = ResidentUseCase()
    @State private var showingAddResident = false
    @State private var selectedResident: Resident?
    @State private var showingResidentEditor = false
    @State private var searchText = ""
    
    var filteredResidents: [Resident] {
        if searchText.isEmpty {
            return residentUseCase.residents
        } else {
            return residentUseCase.residents.filter { resident in
                resident.name.localizedCaseInsensitiveContains(searchText) ||
                resident.email.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Residents 👥")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button("Add Resident") {
                            showingAddResident = true
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.75, green: 0.79, blue: 0.2).opacity(0.8))
                        )
                    }
                    
                    // Statistics
                    HStack(spacing: 16) {
                        StatCard(
                            title: "Active",
                            count: residentUseCase.getActiveResidents().count,
                            color: .green
                        )
                        
                        StatCard(
                            title: "Expiring",
                            count: residentUseCase.getExpiringResidents().count,
                            color: .orange
                        )
                        
                        RevenueStatCard(
                            title: "Revenue",
                            amount: residentUseCase.getTotalMonthlyRevenue(),
                            color: .blue
                        )
                    }
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.7))
                        
                        TextField("Search residents...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white.opacity(0.2))
                    )
                }
                .padding()
                
                // Residents List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredResidents) { resident in
                            ResidentCard(resident: resident) {
                                selectedResident = resident
                                showingResidentEditor = true
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .sheet(isPresented: $showingAddResident) {
            ResidentEditorView(resident: nil) { newResident in
                residentUseCase.addResident(newResident)
            }
        }
        .sheet(isPresented: $showingResidentEditor) {
            if let resident = selectedResident {
                ResidentEditorView(resident: resident) { updatedResident in
                    residentUseCase.updateResident(updatedResident)
                }
            } else {
                EmptyView()
            }
        }
        .onAppear {
            residentUseCase.loadResidents()
        }
    }
}

struct ResidentCard: View {
    let resident: Resident
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ColoredCard(color: statusColor(for: resident.status)) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(resident.name)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        StatusBadge(
                            text: resident.status.rawValue,
                            color: statusColor(for: resident.status)
                        )
                    }
                    
                    Text(resident.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(resident.contractType.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(.blue.opacity(0.2))
                            )
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Text("$\(resident.monthlyRate, specifier: "%.0f")/month")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    
                    if resident.daysUntilExpiry <= 30 && resident.daysUntilExpiry >= 0 {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.orange)
                            Text("Expires in \(resident.daysUntilExpiry) days")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func statusColor(for status: Resident.ResidentStatus) -> Color {
        switch status {
        case .active: return .green
        case .expiring: return .orange
        case .expired: return .red
        case .suspended: return .gray
        }
    }
}

struct ResidentEditorView: View {
    @State private var resident: Resident
    let onSave: (Resident) -> Void
    @Environment(\.dismiss) private var dismiss
    
    private let isNewResident: Bool
    
    init(resident: Resident?, onSave: @escaping (Resident) -> Void) {
        if let resident = resident {
            _resident = State(initialValue: resident)
            isNewResident = false
        } else {
            _resident = State(initialValue: Resident(
                name: "",
                email: "",
                phone: "",
                contractType: .monthly,
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
                monthlyRate: 200,
                status: .active,
                notes: ""
            ))
            isNewResident = true
        }
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    TextField("Name", text: $resident.name)
                    TextField("Email", text: $resident.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Phone", text: $resident.phone)
                        .keyboardType(.phonePad)
                }
                
                Section("Contract Details") {
                    Picker("Contract Type", selection: $resident.contractType) {
                        ForEach(Resident.ContractType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    DatePicker("Start Date", selection: $resident.startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $resident.endDate, displayedComponents: .date)
                    
                    HStack {
                        Text("Monthly Rate:")
                        Spacer()
                        TextField("Rate", value: $resident.monthlyRate, format: .currency(code: "USD"))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120)
                    }
                    
                    Picker("Status", selection: $resident.status) {
                        ForEach(Resident.ResidentStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }
                
                Section("Notes") {
                    TextField("Additional notes...", text: $resident.notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isNewResident ? "Add Resident" : "Edit Resident")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(resident)
                        dismiss()
                    }
                    .disabled(resident.name.isEmpty || resident.email.isEmpty)
                }
            }
        }
    }
}

struct RevenueStatCard: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text("$\(amount, specifier: "%.0f")")
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

#Preview {
    ResidentsView()
}
