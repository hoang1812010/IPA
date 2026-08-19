//
//  LoginView.swift
//  IPAApp
//
//  Created on 2024.
//

import SwiftUI
import UIKit

struct LoginView: View {
    @Binding var apiKey: String
    @Binding var isAuthenticated: Bool
    @State private var deviceId = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // App Icon/Logo
                VStack(spacing: 15) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("IPA TOOL")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Professional Tool")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Device ID Display
                VStack(alignment: .leading, spacing: 10) {
                    Text("Device ID")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text(deviceId)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.green)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                
                // API Key Input
                VStack(alignment: .leading, spacing: 10) {
                    Text("Activation Key")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    TextField("Enter your key...", text: $apiKey)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .keyboardType(.asciiCapable)
                }
                .padding(.horizontal, 30)
                
                // Error Message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                }
                
                // Activate Button
                Button(action: activateKey) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        
                        Text(isLoading ? "Activating..." : "ACTIVATE")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .disabled(isLoading || apiKey.isEmpty)
                .opacity(isLoading || apiKey.isEmpty ? 0.6 : 1.0)
                .padding(.horizontal, 30)
                
                Spacer()
                Spacer()
            }
        }
        .onAppear {
            deviceId = getDeviceID()
        }
    }
    
    private func getDeviceID() -> String {
        let device = UIDevice.current
        return device.identifierForVendor?.uuidString ?? "Unknown"
    }
    
    private func activateKey() {
        isLoading = true
        errorMessage = ""
        
        // Gọi server validation
        KeyValidator.shared.validate(key: apiKey, deviceId: deviceId) { isValid, message in
            DispatchQueue.main.async {
                isLoading = false
                if isValid {
                    isAuthenticated = true
                } else {
                    errorMessage = message ?? "Invalid activation key"
                }
            }
        }
    }
}

#Preview {
    LoginView(apiKey: .constant(""), isAuthenticated: .constant(false))
}
