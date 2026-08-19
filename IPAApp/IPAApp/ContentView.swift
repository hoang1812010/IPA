//
//  ContentView.swift
//  IPAApp
//
//  Created on 2024.
//

import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var apiKey = ""
    
    var body: some View {
        Group {
            if isAuthenticated {
                MainView()
            } else {
                LoginView(apiKey: $apiKey, isAuthenticated: $isAuthenticated)
            }
        }
    }
}

#Preview {
    ContentView()
}
