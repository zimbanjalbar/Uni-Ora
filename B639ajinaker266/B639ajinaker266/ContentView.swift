import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            WorkspaceMapView()
                .tabItem {
                    Image(systemName: "chair")
                    Text("Workspace")
                }
                .tag(0)
            
            ResidentsView()
                .tabItem {
                    Image(systemName: "person.2")
                    Text("Residents")
                }
                .tag(1)
            
            ScheduleView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Schedule")
                }
                .tag(2)
            
            FinanceView()
                .tabItem {
                    Image(systemName: "dollarsign.circle")
                    Text("Finance")
                }
                .tag(3)
            
            AssistantView()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("Assistant")
                }
                .tag(4)
            
            InspirationView()
                .tabItem {
                    Image(systemName: "lightbulb")
                    Text("Growth")
                }
                .tag(5)
        }
        .accentColor(Color(red: 0.75, green: 0.79, blue: 0.2))
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
