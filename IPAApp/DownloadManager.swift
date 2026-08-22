func findContainerUUID(for bundleID: String) -> String? {
    print("[DownloadManager] Đang tìm UUID cho: \(bundleID)")
    
    // Dùng kernel thay vì quét filesystem
    if let uuid = ExploitManager.findContainerUUID(for: bundleID) {
        return uuid
    }
    
    // Fallback: Quét filesystem (chỉ hoạt động nếu đã thoát sandbox)
    print("[DownloadManager] ⚠️ Kernel thất bại, thử quét filesystem...")
    
    let basePath = "/private/var/mobile/Containers/Data/Application/"
    let fileManager = FileManager.default
    
    guard let enumerator = fileManager.enumerator(atPath: basePath) else {
        print("[DownloadManager] ❌ Không liệt kê được \(basePath)")
        return nil
    }
    
    while let folderName = enumerator.nextObject() as? String {
        if folderName.contains("/") { continue }
        
        let metadataPlist = "\(basePath)\(folderName)/.com.apple.mobile_container_manager.metadata.plist"
        
        if fileManager.fileExists(atPath: metadataPlist) {
            if let data = fileManager.contents(atPath: metadataPlist),
               let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
               let mcID = plist["MCMMetadataIdentifier"] as? String,
               mcID == bundleID {
                print("[DownloadManager] ✅ Tìm thấy UUID qua filesystem: \(folderName)")
                return folderName
            }
        }
    }
    
    print("[DownloadManager] ❌ Không tìm thấy UUID cho \(bundleID)")
    return nil
}
