import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var apiKey = ""
    
    var body: some View {
        Group {
            if isAuthenticated {
                MainView(apiKey: apiKey)
            } else {
                LoginView(apiKey: $apiKey, isAuthenticated: $isAuthenticated)
            }
        }
    }
}
