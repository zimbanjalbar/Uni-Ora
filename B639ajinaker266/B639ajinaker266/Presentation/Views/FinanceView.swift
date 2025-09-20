import SwiftUI

struct FinanceView: View {
    @StateObject private var financeUseCase = FinanceUseCase()
    @StateObject private var aiService = OpenAIService()
    @State private var showingAddRecord = false
    @State private var selectedRecord: FinanceRecord?
    @State private var showingRecordEditor = false
    @State private var selectedPeriod: TimePeriod = .thisMonth
    @State private var aiInsight = ""
    @State private var showingAIInsight = false
    
    enum TimePeriod: String, CaseIterable {
        case thisMonth = "This Month"
        case lastMonth = "Last Month"
        case thisYear = "This Year"
        case all = "All Time"
    }
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            ScrollView {
                VStack(spacing: 20) {
                    FinanceHeaderView(
                        selectedPeriod: $selectedPeriod,
                        generateAIInsight: generateAIInsight
                    )
                    
                    FinanceOverviewSection(
                        totalIncome: totalIncome,
                        totalExpenses: totalExpenses,
                        netProfit: netProfit
                    )
                    
                    if !categoryBreakdown.isEmpty {
                        CategoryBreakdownSection(categoryBreakdown: categoryBreakdown)
                    }
                    
                    RecentTransactionsSection(
                        recentRecords: recentRecords,
                        showingAddRecord: $showingAddRecord,
                        onRecordTap: { record in
                            selectedRecord = record
                            showingRecordEditor = true
                        }
                    )
                }
                .padding(.vertical)
            }
            
            if aiService.isLoading {
                LoadingView()
            }
        }
        .sheet(isPresented: $showingAddRecord) {
            FinanceRecordEditorView(record: nil) { newRecord in
                financeUseCase.addRecord(newRecord)
            }
        }
        .sheet(isPresented: $showingRecordEditor) {
            if let record = selectedRecord {
                FinanceRecordEditorView(record: record) { updatedRecord in
                    financeUseCase.updateRecord(updatedRecord)
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
            financeUseCase.loadRecords()
        }
    }
    
    private var dateInterval: DateInterval? {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .thisMonth:
            return calendar.dateInterval(of: .month, for: now)
        case .lastMonth:
            let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return calendar.dateInterval(of: .month, for: lastMonth)
        case .thisYear:
            return calendar.dateInterval(of: .year, for: now)
        case .all:
            return nil
        }
    }
    
    private var totalIncome: Double {
        financeUseCase.getTotalIncome(for: dateInterval)
    }
    
    private var totalExpenses: Double {
        financeUseCase.getTotalExpenses(for: dateInterval)
    }
    
    private var netProfit: Double {
        financeUseCase.getNetProfit(for: dateInterval)
    }
    
    private var categoryBreakdown: [(FinanceRecord.FinanceCategory, Double)] {
        financeUseCase.getTopRevenueCategories()
    }
    
    private var recentRecords: [FinanceRecord] {
        let filteredRecords = dateInterval != nil ? 
            financeUseCase.records.filter { dateInterval!.contains($0.date) } : 
            financeUseCase.records
        
        return Array(filteredRecords.sorted { $0.date > $1.date }.prefix(10))
    }
    
    private func generateAIInsight() {
        Task {
            do {
                let insight = try await financeUseCase.generateAIInsight()
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

struct FinanceStatCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Text("$\(amount, specifier: "%.0f")")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
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

struct FinanceRecordCard: View {
    let record: FinanceRecord
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ColoredCard(color: record.type == .income ? .green : .red) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(record.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("\(record.type == .income ? "+" : "-")$\(record.amount, specifier: "%.2f")")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(record.type == .income ? .green : .red)
                    }
                    
                    HStack {
                        StatusBadge(
                            text: record.category.rawValue,
                            color: .blue
                        )
                        
                        Spacer()
                        
                        Text(record.date, formatter: dateFormatter)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if !record.description.isEmpty {
                        Text(record.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    if record.type == .income && !record.isPaid {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                            Text("Payment Pending")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

struct FinanceRecordEditorView: View {
    @State private var record: FinanceRecord
    let onSave: (FinanceRecord) -> Void
    @Environment(\.dismiss) private var dismiss
    
    private let isNewRecord: Bool
    
    init(record: FinanceRecord?, onSave: @escaping (FinanceRecord) -> Void) {
        if let record = record {
            _record = State(initialValue: record)
            isNewRecord = false
        } else {
            _record = State(initialValue: FinanceRecord(
                title: "",
                amount: 0,
                type: .income,
                category: .membership,
                date: Date(),
                description: "",
                isPaid: true
            ))
            isNewRecord = true
        }
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Transaction Details") {
                    TextField("Title", text: $record.title)
                    
                    HStack {
                        Text("Amount:")
                        Spacer()
                        TextField("Amount", value: $record.amount, format: .currency(code: "USD"))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120)
                    }
                    
                    Picker("Type", selection: $record.type) {
                        ForEach(FinanceRecord.TransactionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    Picker("Category", selection: $record.category) {
                        ForEach(FinanceRecord.FinanceCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    DatePicker("Date", selection: $record.date, displayedComponents: [.date])
                    
                    if record.type == .income {
                        Toggle("Payment Received", isOn: $record.isPaid)
                    }
                }
                
                Section("Description") {
                    TextField("Additional details...", text: $record.description, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isNewRecord ? "Add Record" : "Edit Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(record)
                        dismiss()
                    }
                    .disabled(record.title.isEmpty || record.amount <= 0)
                }
            }
        }
    }
}

struct FinanceHeaderView: View {
    @Binding var selectedPeriod: FinanceView.TimePeriod
    let generateAIInsight: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Finance 💵")
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
            
            Picker("Period", selection: $selectedPeriod) {
                ForEach(FinanceView.TimePeriod.allCases, id: \.self) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .background(.white.opacity(0.2))
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }
}

struct FinanceOverviewSection: View {
    let totalIncome: Double
    let totalExpenses: Double
    let netProfit: Double
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                FinanceStatCard(
                    title: "Income",
                    amount: totalIncome,
                    color: .green,
                    icon: "arrow.up.circle"
                )
                
                FinanceStatCard(
                    title: "Expenses",
                    amount: totalExpenses,
                    color: .red,
                    icon: "arrow.down.circle"
                )
            }
            
            ColoredCard(color: netProfit >= 0 ? .green : .red) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Net Profit")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("$\(netProfit, specifier: "%.2f")")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(netProfit >= 0 ? .green : .red)
                    }
                    
                    Spacer()
                    
                    Image(systemName: netProfit >= 0 ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis")
                        .font(.system(size: 32))
                        .foregroundColor(netProfit >= 0 ? .green : .red)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct CategoryBreakdownSection: View {
    let categoryBreakdown: [(FinanceRecord.FinanceCategory, Double)]
    
    var body: some View {
        ColoredCard(color: .blue) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Category Breakdown")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                ForEach(Array(categoryBreakdown.prefix(5)), id: \.0) { category, amount in
                    HStack {
                        Text(category.rawValue)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("$\(amount, specifier: "%.0f")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct RecentTransactionsSection: View {
    let recentRecords: [FinanceRecord]
    @Binding var showingAddRecord: Bool
    let onRecordTap: (FinanceRecord) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Add Record") {
                    showingAddRecord = true
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
            
            LazyVStack(spacing: 8) {
                ForEach(recentRecords) { record in
                    FinanceRecordCard(record: record) {
                        onRecordTap(record)
                    }
                }
                
                if recentRecords.isEmpty {
                    EmptyStateView(
                        icon: "dollarsign.circle",
                        title: "No transactions",
                        subtitle: "Add your first financial record"
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    FinanceView()
}
