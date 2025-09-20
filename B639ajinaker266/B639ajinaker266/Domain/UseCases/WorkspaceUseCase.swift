import Foundation

class WorkspaceUseCase: ObservableObject {
    @Published var spaces: [WorkspaceSpace] = []
    @Published var totalSpaces: Int = 20
    
    private let storageService = LocalStorageService()
    private let aiService = OpenAIService()
    
    init() {
        loadSpaces()
        loadTotalSpaces()
    }
    
    func loadSpaces() {
        spaces = storageService.loadSpaces()
    }
    
    func loadTotalSpaces() {
        totalSpaces = storageService.loadTotalSpaces()
    }
    
    func updateTotalSpaces(_ count: Int) {
        totalSpaces = count
        storageService.saveTotalSpaces(count)
        
        // Adjust spaces array to match total count
        if spaces.count < count {
            // Add new spaces
            for i in (spaces.count + 1)...count {
                let newSpace = WorkspaceSpace(
                    number: i,
                    type: .hotDesk,
                    status: .available,
                    pricePerHour: 15.0
                )
                spaces.append(newSpace)
            }
        } else if spaces.count > count {
            // Remove excess spaces
            spaces = Array(spaces.prefix(count))
        }
        
        saveSpaces()
    }
    
    func updateSpace(_ space: WorkspaceSpace) {
        if let index = spaces.firstIndex(where: { $0.id == space.id }) {
            spaces[index] = space
            saveSpaces()
        }
    }
    
    func bookSpace(_ spaceId: UUID, bookedBy: String, until: Date) {
        if let index = spaces.firstIndex(where: { $0.id == spaceId }) {
            spaces[index].status = .booked
            spaces[index].bookedBy = bookedBy
            spaces[index].bookedUntil = until
            saveSpaces()
        }
    }
    
    func releaseSpace(_ spaceId: UUID) {
        if let index = spaces.firstIndex(where: { $0.id == spaceId }) {
            spaces[index].status = .available
            spaces[index].bookedBy = nil
            spaces[index].bookedUntil = nil
            saveSpaces()
        }
    }
    
    func extendBooking(_ spaceId: UUID, until: Date) {
        if let index = spaces.firstIndex(where: { $0.id == spaceId }) {
            spaces[index].status = .extended
            spaces[index].bookedUntil = until
            saveSpaces()
        }
    }
    
    func getAvailableSpaces() -> [WorkspaceSpace] {
        return spaces.filter { $0.status == .available }
    }
    
    func getBookedSpaces() -> [WorkspaceSpace] {
        return spaces.filter { $0.status == .booked || $0.status == .extended }
    }
    
    func getSpacesByType(_ type: WorkspaceSpace.SpaceType) -> [WorkspaceSpace] {
        return spaces.filter { $0.type == type }
    }
    
    func generateAIInsight() async throws -> String {
        return try await aiService.generateWorkspaceInsight(spaces: spaces)
    }
    
    private func saveSpaces() {
        storageService.saveSpaces(spaces)
    }
}
