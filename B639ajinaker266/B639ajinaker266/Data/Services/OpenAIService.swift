import Foundation

class OpenAIService: ObservableObject {
    private let apiKey = "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"
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    @Published var isLoading = false
    @Published var isOffline = false
    
    func generateInsight(prompt: String, context: String = "") async throws -> String {
        isLoading = true
        defer { isLoading = false }
        
        let fullPrompt = """
        You are a smart coworking space assistant. Provide concise, actionable insights for coworking space management.
        Context: \(context)
        Request: \(prompt)
        
        Respond with practical advice in 1-2 sentences. Be specific and actionable.
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a helpful coworking space management assistant."],
                ["role": "user", "content": fullPrompt]
            ],
            "max_tokens": 150,
            "temperature": 0.7
        ]
        
        guard let url = URL(string: baseURL) else {
            throw OpenAIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                isOffline = true
                throw OpenAIError.networkError
            }
            
            isOffline = false
            
            let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let choices = jsonResponse?["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                throw OpenAIError.invalidResponse
            }
            
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
            
        } catch {
            isOffline = true
            throw OpenAIError.networkError
        }
    }
    
    func generateWorkspaceInsight(spaces: [WorkspaceSpace]) async throws -> String {
        let availableSpaces = spaces.filter { $0.status == .available }.count
        let bookedSpaces = spaces.filter { $0.status == .booked }.count
        let context = "Available spaces: \(availableSpaces), Booked spaces: \(bookedSpaces), Total spaces: \(spaces.count)"
        
        return try await generateInsight(
            prompt: "Analyze workspace utilization and suggest optimization strategies",
            context: context
        )
    }
    
    func generateFinanceInsight(records: [FinanceRecord]) async throws -> String {
        let totalIncome = records.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let totalExpenses = records.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        let context = "Monthly income: $\(totalIncome), Monthly expenses: $\(totalExpenses), Profit: $\(totalIncome - totalExpenses)"
        
        return try await generateInsight(
            prompt: "Analyze financial performance and suggest revenue optimization",
            context: context
        )
    }
    
    func generateScheduleInsight(bookings: [ScheduleBooking]) async throws -> String {
        let upcomingBookings = bookings.filter { $0.startTime > Date() }.count
        let totalRevenue = bookings.reduce(0) { $0 + $1.cost }
        let context = "Upcoming bookings: \(upcomingBookings), Total booking revenue: $\(totalRevenue)"
        
        return try await generateInsight(
            prompt: "Analyze booking patterns and suggest scheduling optimizations",
            context: context
        )
    }
    
    func generateDailyTip() async throws -> String {
        return try await generateInsight(
            prompt: "Provide a daily tip for coworking space management and growth",
            context: "Focus on practical, actionable advice for space operators"
        )
    }
}

enum OpenAIError: Error, LocalizedError {
    case invalidURL
    case networkError
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .networkError:
            return "Network connection failed"
        case .invalidResponse:
            return "Invalid API response"
        }
    }
}
