import SwiftUI
import UIKit

struct LoginView: View {
    @Binding var apiKey: String
    @Binding var isAuthenticated: Bool
    
    @State private var deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "NODE:0x8A7F4C"
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    // Impeccable Colors
    let bgColor = Color(red: 0.02, green: 0.02, blue: 0.03)
    let surfaceColor = Color.white.opacity(0.03)
    let borderColor = Color.white.opacity(0.06)
    let accentCyan = Color(red: 0.0, green: 0.95, blue: 1.0)
    let accentCyanDim = Color(red: 0.0, green: 0.95, blue: 1.0).opacity(0.15)
    let textSecondary = Color(red: 142/255, green: 142/255, blue: 147/255) // #8E8E93
    
    var body: some View {
        ZStack {
            // Background
            bgColor.ignoresSafeArea()
            
            // Ambient Glow (Top Left)
            Circle()
                .fill(accentCyanDim)
                .blur(radius: 80)
                .frame(width: 300, height: 300)
                .position(x: 50, y: 50)
            
            VStack(spacing: 32) {
                Spacer()
                
                // Logo Section
                VStack(spacing: 12) {
                    if let uiImage = UIImage(named: "iconapp") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: accentCyan.opacity(0.4), radius: 15)
                    } else {
                        // Fallback icon
                        Image(systemName: "shield.righthalf.filled")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(accentCyan)
                            .shadow(color: accentCyan.opacity(0.4), radius: 15)
                    }
                    
                    Text("Cheat VN")
                        .font(.system(size: 32, weight: .heavy, design: .default))
                        .foregroundColor(.white)
                    
                    Text("CỔNG BẢO MẬT HỆ THỐNG")
                        .font(.system(size: 12, weight: .semibold, design: .default))
                        .foregroundColor(textSecondary)
                        .tracking(2) // Equivalent to letter-spacing
                }
                .padding(.bottom, 16)
                
                // Inputs Section
                VStack(alignment: .leading, spacing: 24) {
                    // Device ID Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("MÃ THIẾT BỊ (UDID)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(textSecondary)
                            .tracking(1)
                        
                        HStack {
                            Text(deviceId)
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                                .foregroundColor(accentCyan)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Spacer()
                            Button(action: {
                                UIPasteboard.general.string = deviceId
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(textSecondary)
                            }
                        }
                        .padding()
                        .background(surfaceColor)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(borderColor, lineWidth: 1))
                        .cornerRadius(16)
                    }
                    
                    // License Key
                    VStack(alignment: .leading, spacing: 8) {
                        Text("MÃ KÍCH HOẠT (KEY)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(textSecondary)
                            .tracking(1)
                        
                        TextField("Nhập mã kích hoạt của bạn...", text: $apiKey)
                            .font(.system(size: 15, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                            .padding()
                            .background(surfaceColor)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(apiKey.isEmpty ? borderColor : accentCyan.opacity(0.5), lineWidth: 1))
                            .cornerRadius(16)
                            .autocapitalization(.allCharacters)
                            .disableAutocorrection(true)
                    }
                }
                .padding(.horizontal, 24)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                // Submit Button
                Button(action: activateKey) {
                    Text(isLoading ? "ĐANG XÁC THỰC..." : "KÍCH HOẠT HỆ THỐNG")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [accentCyan, Color(red: 0.3, green: 0.67, blue: 1.0)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: accentCyan.opacity(0.2), radius: 10, y: 5)
                }
                .disabled(isLoading || apiKey.isEmpty)
                .opacity((isLoading || apiKey.isEmpty) ? 0.7 : 1.0)
                .padding(.horizontal, 24)
                .padding(.top, 8)
                
                Spacer()
            }
        }
    }
    
    private func activateKey() {
        isLoading = true
        errorMessage = ""
        
        KeyValidator.shared.validate(key: apiKey, deviceId: deviceId) { isValid, message in
            DispatchQueue.main.async {
                isLoading = false
                if isValid {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        isAuthenticated = true
                    }
                } else {
                    errorMessage = message ?? "Mã kích hoạt không hợp lệ"
                }
            }
        }
    }
}
