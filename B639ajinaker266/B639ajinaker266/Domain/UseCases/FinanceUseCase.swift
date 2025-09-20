import Foundation

class FinanceUseCase: ObservableObject {
    @Published var records: [FinanceRecord] = []
    
    private let storageService = LocalStorageService()
    private let aiService = OpenAIService()
    
    init() {
        loadRecords()
    }
    
    func loadRecords() {
        records = storageService.loadFinanceRecords()
    }
    
    func addRecord(_ record: FinanceRecord) {
        records.append(record)
        saveRecords()
    }
    
    func updateRecord(_ record: FinanceRecord) {
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
            saveRecords()
        }
    }
    
    func deleteRecord(_ recordId: UUID) {
        records.removeAll { $0.id == recordId }
        saveRecords()
    }
    
    func getTotalIncome(for period: DateInterval? = nil) -> Double {
        let filteredRecords = period != nil ? 
            records.filter { period!.contains($0.date) } : records
        
        return filteredRecords
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    func getTotalExpenses(for period: DateInterval? = nil) -> Double {
        let filteredRecords = period != nil ? 
            records.filter { period!.contains($0.date) } : records
        
        return filteredRecords
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }
    
    func getNetProfit(for period: DateInterval? = nil) -> Double {
        return getTotalIncome(for: period) - getTotalExpenses(for: period)
    }
    
    func getRecordsByCategory(_ category: FinanceRecord.FinanceCategory) -> [FinanceRecord] {
        return records.filter { $0.category == category }
    }
    
    func getRecordsByType(_ type: FinanceRecord.TransactionType) -> [FinanceRecord] {
        return records.filter { $0.type == type }
    }
    
    func getOverduePayments() -> [FinanceRecord] {
        return records.filter { record in
            record.type == .income && 
            !record.isPaid && 
            record.date < Date()
        }
    }
    
    func getMonthlyRecords() -> [FinanceRecord] {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end ?? now
        
        return records.filter { record in
            record.date >= startOfMonth && record.date <= endOfMonth
        }
    }
    
    func getCategoryBreakdown() -> [FinanceRecord.FinanceCategory: Double] {
        var breakdown: [FinanceRecord.FinanceCategory: Double] = [:]
        
        for record in records {
            breakdown[record.category, default: 0] += record.amount
        }
        
        return breakdown
    }
    
    func getTopRevenueCategories() -> [(FinanceRecord.FinanceCategory, Double)] {
        let incomeRecords = records.filter { $0.type == .income }
        let categoryTotals = Dictionary(grouping: incomeRecords) { $0.category }
            .mapValues { records in records.reduce(0) { $0 + $1.amount } }
        
        return categoryTotals.sorted { $0.value > $1.value }
    }
    
    func generateAIInsight() async throws -> String {
        return try await aiService.generateFinanceInsight(records: records)
    }
    
    private func saveRecords() {
        storageService.saveFinanceRecords(records)
    }
}
