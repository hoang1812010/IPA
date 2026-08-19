//
//  MainView.swift
//  IPAApp
//
//  Created on 2024.
//

import SwiftUI

struct MainView: View {
    @State private var selectedBundle: String = "com.dts.freefireth"
    @State private var activeFeature: String? = nil
    @State private var isProcessing = false
    @State private var statusMessage = ""
    @State private var showStatus = false
    
    let bundles = ["com.dts.freefireth", "com.dts.freefiremax"]
    
    // URLs cho từng chức năng - bạn cần thay thế bằng URL thực tế
    let featureURLs: [String: String] = [
        "nhe_tam": "https://download2297.mediafire.com/y8g6xu8dzm9g1MxwluU4TrcEBuCtTrLsHQV6y7qfvf_syMLA1FlkNTUw-_qzfHAD5GLTMY_jo3xzyfpwBfPmNevT-zoUlCYXX-rt-0ZM3b8gbIp2vi_3pk0WoLelL3X2ystqkHXkpIj5WtxRLGJmrHZqMVv-BTYFp3mhQB56XOVykIw/c95kmzxa0fjd0tz/cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs%7E3D",
        "proxy_body": "https://download2391.mediafire.com/ah3lib0uqnugbHDftsXjfJKo5RDRXyL1uf1VOwPv7trlJJoWOFug7pEuir-ddusvN344pDet047Rt1AFiEFTjBB0XoxUe59xhwTjIcbuatFfX8suIUjmjcyCOAIjGCsBpVCNp1ApBC5fj8Rx262sqsErzzhOx44MfK49O_zCESRDfoY/ykc22di703wc51f/cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs%7E3D",
        "proxy_neck": "https://download2389.mediafire.com/7kvcg74pn6lgnrV-OCglaJ1RnjSj9VOaNCf2mV7-9H00bNIwP-UjOHBUdOgxq9_HrMNFCk2N7WQvuGOgpCoahA7HElMs1iBEnED55cM37K81Vz9217GyZJbevp4WXfl8YH7XFQ6fg2vOsrluCR8QKUr8cF9AtzyuL4F_XT11VlU-3BU/c5hq8513ewb312s/cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs%7E3D",
        "proxy_drag": "https://download2391.mediafire.com/rutwuk3tob0gA_uGxk-8LYfV0Y4sedXSwgzjOY1j7cAQyEYuyCbIrFIyjk_4VKyYeqZ_mqwLZcX63RcYmcZS0-w7L4xb4PSuPXhzIXRvjuRdICAgphoSaFFOm7gEiSv6w--dPtFcRy2ZwqoMMp5zLltZcYlB4THt2XzZEwm6iQRcmbc/7ueocoouf759j22/cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs%7E3D"
    ]
    
    let features: [FeatureItem] = [
        FeatureItem(name: "Nhẹ Tâm", id: "nhe_tam", color: .blue),
        FeatureItem(name: "Proxy Body", id: "proxy_body", color: .green),
        FeatureItem(name: "Proxy Neck", id: "proxy_neck", color: .orange),
        FeatureItem(name: "Proxy Drag", id: "proxy_drag", color: .purple)
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        Text("IPA TOOL")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)
                    
                    // Bundle Selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("CHỌN BUNDLE")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                        
                        HStack(spacing: 12) {
                            ForEach(bundles, id: \.self) { bundle in
                                Button(action: {
                                    selectedBundle = bundle
                                    activeFeature = nil
                                }) {
                                    HStack {
                                        Image(systemName: selectedBundle == bundle ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 16))
                                        
                                        Text(bundle)
                                            .font(.system(size: 12, weight: .medium))
                                            .lineLimit(1)
                                    }
                                    .foregroundColor(selectedBundle == bundle ? .black : .white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        selectedBundle == bundle ?
                                            LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing) :
                                            Color.gray.opacity(0.2)
                                    )
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Features Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("CHỨC NĂNG")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                        
                        VStack(spacing: 12) {
                            ForEach(features) { feature in
                                FeatureButton(
                                    feature: feature,
                                    isActive: activeFeature == feature.id,
                                    isProcessing: isProcessing && activeFeature == feature.id,
                                    action: {
                                        activateFeature(feature)
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Status Display
                    if showStatus {
                        VStack(spacing: 10) {
                            HStack {
                                if isProcessing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                } else {
                                    Image(systemName: statusMessage.contains("thành công") || statusMessage.contains("Thành công") ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(statusMessage.contains("thành công") || statusMessage.contains("Thành công") ? .green : .red)
                                }
                                
                                Text(statusMessage)
                                    .font(.system(size: 13))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 20)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func activateFeature(_ feature: FeatureItem) {
        if activeFeature == feature.id {
            // Deactivate if already active
            activeFeature = nil
            statusMessage = ""
            showStatus = false
        } else {
            // Activate new feature
            activeFeature = feature.id
            isProcessing = true
            showStatus = true
            statusMessage = "Đang tải dữ liệu cho \(feature.name)..."
            
            // Get download URL for this feature
            guard let downloadURL = featureURLs[feature.id] else {
                isProcessing = false
                statusMessage = "Lỗi: Không tìm thấy URL cho chức năng này"
                return
            }
            
            // Download and replace file
            DownloadManager.shared.downloadAndReplaceFile(
                from: downloadURL,
                bundleIdentifier: selectedBundle,
                featureName: feature.name
            ) { result in
                DispatchQueue.main.async {
                    isProcessing = false
                    switch result {
                    case .success:
                        statusMessage = "\(feature.name) đã được kích hoạt thành công!"
                        // Auto-hide success message after 3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            if !isProcessing {
                                showStatus = false
                            }
                        }
                    case .failure(let error):
                        statusMessage = "Lỗi: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}

// MARK: - Feature Item Model
struct FeatureItem: Identifiable {
    let id = UUID()
    let name: String
    let featureId: String
    let color: Color
    
    init(name: String, id: String, color: Color) {
        self.name = name
        self.featureId = id
        self.color = color
    }
}

// MARK: - Feature Button Component
struct FeatureButton: View {
    let feature: FeatureItem
    let isActive: Bool
    let isProcessing: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                // Icon
                ZStack {
                    Circle()
                        .fill(feature.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: feature.color))
                            .scaleEffect(0.6)
                    } else {
                        Image(systemName: isActive ? "checkmark" : "arrow.down.circle")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(isActive ? .white : feature.color)
                    }
                }
                
                // Feature Name
                Text(feature.name)
                    .font(.system(size: 15, weight: isActive ? .semibold : .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Status Indicator
                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(
                Group {
                    if isActive {
                        LinearGradient(
                            gradient: Gradient(colors: [feature.color.opacity(0.8), feature.color]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        Color.gray.opacity(0.2)
                    }
                }
            )
            .cornerRadius(12)
            .shadow(color: isActive ? feature.color.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
        }
        .disabled(isProcessing)
    }
}

#Preview {
    MainView()
}
