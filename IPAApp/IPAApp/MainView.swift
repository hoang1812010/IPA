import SwiftUI

struct MainView: View {
    var apiKey: String
    
    @State private var selectedBundle: String = "com.dts.freefireth"
    @State private var activeFeature: String? = nil
    
    @State private var isProcessing = false
    @State private var statusMessage = "Hệ thống sẵn sàng. Đang chờ lệnh..."
    
    // Original App Data
    let featureURLs: [String: String] = [
        "Nhẹ Tâm": "https://download2297.mediafire.com/y8g6xu8dzm9g1MxwluU4TrcEBuCtTrLsHQV6y7qfvf_syMLA1FlkNTUw-_qzfHAD5GLTMY_jo3xzyfpwBfPmNevT-zoUlCYXX-rt-0ZM3b8gbIp2vi_3pk0WoLelL3X2ystqkHXkpIj5WtxRLGJmrHZqMVv-BTYFp3mhQB56XOVykIw/c95kmzxa0fjd0tz/cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs%7E3D",
        "Proxy Body": "https://download2391.mediafire.com/ah3lib0uqnugbHDftsXjfJKo5RDRXyL1uf1VOwPv7trlJJoWOFug7pEuir-ddusvN344pDet047Rt1AFiEFTjBB0XoxUe59xhwTjIcbuatFfX8suIUjmjcyCOAIjGCsBpVCNp1ApBC5fj8Rx262sqsErzzhOx44MfK49O_zCESRDfoY/ykc22di703wc51f/cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs%7E3D",
        "Proxy Neck": "https://download2389.mediafire.com/7kvcg74pn6lgnrV-OCglaJ1RnjSj9VOaNCf2mV7-9H00bNIwP-UjOHBUdOgxq9_HrMNFCk2N7WQvuGOgpCoahA7HElMs1iBEnED55cM37K81Vz9217GyZJbevp4WXfl8YH7XFQ6fg2vOsrluCR8QKUr8cF9AtzyuL4F_XT11VlU-3BU/c5hq8513ewb312s/cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs%7E3D",
        "Proxy Drag": "https://download2391.mediafire.com/rutwuk3tob0gA_uGxk-8LYfV0Y4sedXSwgzjOY1j7cAQyEYuyCbIrFIyjk_4VKyYeqZ_mqwLZcX63RcYmcZS0-w7L4xb4PSuPXhzIXRvjuRdICAgphoSaFFOm7gEiSv6w--dPtFcRy2ZwqoMMp5zLltZcYlB4THt2XzZEwm6iQRcmbc/7ueocoouf759j22/cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs%7E3D"
    ]
    
    let features = ["Nhẹ Tâm", "Proxy Body", "Proxy Neck", "Proxy Drag"]
    let featureIcons = ["wind", "figure.walk", "scope", "hand.point.up.left.fill"]
    
    // Colors
    let bgColor = Color(red: 0.02, green: 0.02, blue: 0.03)
    let surfaceColor = Color.white.opacity(0.03)
    let surfaceHover = Color.white.opacity(0.06)
    let borderColor = Color.white.opacity(0.06)
    let accentCyan = Color(red: 0.0, green: 0.95, blue: 1.0)
    let statusGreen = Color(red: 0.2, green: 0.78, blue: 0.35)
    let textSecondary = Color(red: 142/255, green: 142/255, blue: 147/255)
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Scrollable Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Header
                        HStack {
                            HStack(spacing: 8) {
                                if let uiImage = UIImage(named: "iconapp") {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 24, height: 24)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                        .shadow(color: accentCyan.opacity(0.3), radius: 4)
                                }
                                Text("Cheat VN")
                                    .font(.system(size: 20, weight: .heavy))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(statusGreen)
                                    .frame(width: 6, height: 6)
                                    .shadow(color: statusGreen, radius: 4)
                                Text("AN TOÀN")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(statusGreen)
                                    .tracking(1)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(statusGreen.opacity(0.1))
                            .overlay(RoundedRectangle(cornerRadius: 100).stroke(statusGreen.opacity(0.2), lineWidth: 1))
                            .cornerRadius(100)
                        }
                        .padding(.top, 16)
                        
                        // License Info Card
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("MÃ KÍCH HOẠT")
                                    .font(.system(size: 10, weight: .heavy))
                                    .foregroundColor(accentCyan)
                                    .tracking(1)
                                Text(apiKey.isEmpty ? "XXXX-XXXX" : apiKey)
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 6) {
                                Text("THỜI GIAN CÒN LẠI")
                                    .font(.system(size: 10, weight: .heavy))
                                    .foregroundColor(textSecondary)
                                    .tracking(1)
                                HStack(spacing: 6) {
                                    Image(systemName: "clock")
                                        .foregroundColor(statusGreen)
                                        .font(.system(size: 12, weight: .bold))
                                    Text("6d 23h 59m")
                                        .font(.system(size: 14, weight: .heavy))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(16)
                        .background(accentCyan.opacity(0.05))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(accentCyan.opacity(0.2), lineWidth: 1))
                        .cornerRadius(16)
                        .shadow(color: accentCyan.opacity(0.05), radius: 15)
                        
                        // TARGET BUNDLE
                        VStack(alignment: .leading, spacing: 16) {
                            Text("CHỌN PHIÊN BẢN GAME")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(textSecondary)
                                .tracking(1)
                            
                            VStack(spacing: 16) {
                                BundleCardView(
                                    title: "Free Fire (Thường)",
                                    imageName: "freefireth",
                                    isSelected: selectedBundle == "com.dts.freefireth"
                                ) {
                                    switchBundle("com.dts.freefireth")
                                }
                                
                                BundleCardView(
                                    title: "Free Fire MAX",
                                    imageName: "freefiremax",
                                    isSelected: selectedBundle == "com.dts.freefiremax"
                                ) {
                                    switchBundle("com.dts.freefiremax")
                                }
                            }
                        }
                        
                        // INJECTION PAYLOADS
                        VStack(alignment: .leading, spacing: 16) {
                            Text("DANH SÁCH CHỨC NĂNG")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(textSecondary)
                                .tracking(1)
                            
                            VStack(spacing: 16) {
                                ForEach(0..<features.count, id: \.self) { index in
                                    let feature = features[index]
                                    let icon = featureIcons[index]
                                    let isActive = (activeFeature == feature)
                                    
                                    ModuleCardView(
                                        title: feature,
                                        iconSystemName: icon,
                                        isActive: isActive
                                    ) {
                                        toggleFeature(feature)
                                    }
                                }
                            }
                        }
                        
                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 24)
                }
                
                // Sticky Console
                HStack(spacing: 8) {
                    Text(">")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(statusMessage.contains("THÀNH CÔNG") ? statusGreen : accentCyan)
                    
                    Text(statusMessage)
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .foregroundColor(statusMessage.contains("THÀNH CÔNG") ? .white : textSecondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Spacer()
                    
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: accentCyan))
                            .scaleEffect(0.7)
                    }
                }
                .padding(16)
                .background(Color.black.opacity(0.4))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.03), lineWidth: 1))
                .cornerRadius(16)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .padding(.top, 8)
            }
        }
    }
    
    // Actions
    func switchBundle(_ bundle: String) {
        selectedBundle = bundle
        statusMessage = "Đã chuyển đổi mục tiêu sang: \(bundle == "com.dts.freefireth" ? "Free Fire Thường" : "Free Fire MAX")"
    }
    
    func toggleFeature(_ feature: String) {
        if activeFeature == feature {
            // Turn off
            activeFeature = nil
            statusMessage = "Đã tắt tất cả các chức năng."
        } else {
            // Turn on
            isProcessing = true
            statusMessage = "Đang khởi tạo chức năng: \(feature)..."
            
            // Simulate injection delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                isProcessing = false
                activeFeature = feature
                statusMessage = "THÀNH CÔNG: Đã bật \(feature)."
                
                // Actually trigger the DownloadManager here if needed
                if let url = featureURLs[feature] {
                    DownloadManager.shared.downloadAndReplaceFile(
                        from: url,
                        bundleID: selectedBundle,
                        filename: "cache_res"
                    )
                }
            }
        }
    }
}

// Subviews for Cards
struct BundleCardView: View {
    let title: String
    let imageName: String
    let isSelected: Bool
    let action: () -> Void
    
    let accentCyan = Color(red: 0.0, green: 0.95, blue: 1.0)
    let surfaceColor = Color.white.opacity(0.03)
    let borderColor = Color.white.opacity(0.06)
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                if let uiImage = UIImage(named: imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .opacity(isSelected ? 1.0 : 0.5)
                        .shadow(color: isSelected ? accentCyan.opacity(0.3) : .clear, radius: 10)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 44, height: 44)
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isSelected ? .white : Color(red: 142/255, green: 142/255, blue: 147/255))
                
                Spacer()
                
                // Radio Button
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? accentCyan : Color.gray, lineWidth: 2)
                        .frame(width: 22, height: 22)
                    
                    if isSelected {
                        Circle()
                            .fill(accentCyan)
                            .frame(width: 12, height: 12)
                            .shadow(color: accentCyan, radius: 4)
                    }
                }
            }
            .padding(16)
            .background(isSelected ?
                        LinearGradient(gradient: Gradient(colors: [accentCyan.opacity(0.05), .clear]), startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(gradient: Gradient(colors: [surfaceColor, surfaceColor]), startPoint: .leading, endPoint: .trailing))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(isSelected ? accentCyan.opacity(0.3) : borderColor, lineWidth: 1))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ModuleCardView: View {
    let title: String
    let iconSystemName: String
    let isActive: Bool
    let action: () -> Void
    
    let accentCyan = Color(red: 0.0, green: 0.95, blue: 1.0)
    let surfaceColor = Color.white.opacity(0.03)
    let borderColor = Color.white.opacity(0.06)
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isActive ? accentCyan.opacity(0.1) : .clear)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: iconSystemName)
                        .font(.system(size: 20))
                        .foregroundColor(isActive ? accentCyan : Color.gray)
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isActive ? .white : Color(red: 142/255, green: 142/255, blue: 147/255))
                
                Spacer()
                
                // Toggle Switch
                ZStack(alignment: isActive ? .trailing : .leading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isActive ? accentCyan : Color.white.opacity(0.1))
                        .frame(width: 44, height: 24)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .padding(2)
                        .shadow(color: Color.black.opacity(0.2), radius: 2)
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
            }
            .padding(16)
            .background(isActive ?
                        LinearGradient(gradient: Gradient(colors: [accentCyan.opacity(0.05), .clear]), startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(gradient: Gradient(colors: [surfaceColor, surfaceColor]), startPoint: .leading, endPoint: .trailing))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(isActive ? accentCyan.opacity(0.3) : borderColor, lineWidth: 1))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
