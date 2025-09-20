import Foundation

class ResidentUseCase: ObservableObject {
    @Published var residents: [Resident] = []
    
    private let storageService = LocalStorageService()
    private let aiService = OpenAIService()
    
    init() {
        loadResidents()
    }
    
    func loadResidents() {
        residents = storageService.loadResidents()
    }
    
    func addResident(_ resident: Resident) {
        residents.append(resident)
        saveResidents()
    }
    
    func updateResident(_ resident: Resident) {
        if let index = residents.firstIndex(where: { $0.id == resident.id }) {
            residents[index] = resident
            saveResidents()
        }
    }
    
    func deleteResident(_ residentId: UUID) {
        residents.removeAll { $0.id == residentId }
        saveResidents()
    }
    
    func getExpiringResidents(within days: Int = 30) -> [Resident] {
        return residents.filter { resident in
            resident.daysUntilExpiry <= days && resident.daysUntilExpiry >= 0
        }
    }
    
    func getActiveResidents() -> [Resident] {
        return residents.filter { $0.status == .active }
    }
    
    func getExpiredResidents() -> [Resident] {
        return residents.filter { $0.status == .expired || $0.daysUntilExpiry < 0 }
    }
    
    func getResidentsByContractType(_ type: Resident.ContractType) -> [Resident] {
        return residents.filter { $0.contractType == type }
    }
    
    func getTotalMonthlyRevenue() -> Double {
        return residents.filter { $0.status == .active }.reduce(0) { $0 + $1.monthlyRate }
    }
    
    func generateRenewalReminders() -> [Resident] {
        return getExpiringResidents(within: 7)
    }
    
    func generateAIInsight() async throws -> String {
        let expiringCount = getExpiringResidents().count
        let totalRevenue = getTotalMonthlyRevenue()
        let context = "Active residents: \(getActiveResidents().count), Expiring soon: \(expiringCount), Monthly revenue: $\(totalRevenue)"
        
        return try await aiService.generateInsight(
            prompt: "Analyze resident retention and suggest strategies for contract renewals",
            context: context
        )
    }
    
    private func saveResidents() {
        storageService.saveResidents(residents)
    }
}
