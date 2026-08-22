import Foundation

/// MHAController - MobileHouseArrest Controller
/// Sử dụng cơ chế MHA-C2 để mount container của app khác
class MHAController {
    static let shared = MHAController()
    
    private var mountedContainers: [String: String] = [:]
    
    // MARK: - Public API
    
    /// Mount container của app đích và trả về đường dẫn
    func mountContainer(for bundleID: String) -> String? {
        print("[MHA] Mounting container for: \(bundleID)")
        
        // Check cache
        if let cachedPath = mountedContainers[bundleID] {
            print("[MHA] Using cached path: \(cachedPath)")
            return cachedPath
        }
        
        // Tìm UUID container
        guard let uuid = findContainerUUID(for: bundleID) else {
            print("[MHA] ❌ Cannot find container UUID for \(bundleID)")
            return nil
        }
        
        // Build path
        let containerPath = "/private/var/mobile/Containers/Data/Application/\(uuid)"
        
        // Verify path exists
        if FileManager.default.fileExists(atPath: containerPath) {
            print("[MHA] ✅ Container mounted at: \(containerPath)")
            mountedContainers[bundleID] = containerPath
            return containerPath
        } else {
            print("[MHA] ❌ Container path does not exist: \(containerPath)")
            return nil
        }
    }
    
    /// Copy file từ app vào container đã mount
    func writeFileToContainer(containerPath: String, srcPath: String, dstRelativePath: String) -> Bool {
        print("[MHA] Writing file to container")
        print("[MHA]   Source: \(srcPath)")
        print("[MHA]   Destination: \(containerPath)/\(dstRelativePath)")
        
        let fileManager = FileManager.default
        
        // Build full destination path
        let dstFullPath = (containerPath as NSString).appendingPathComponent(dstRelativePath)
        let dstDirectory = (dstFullPath as NSString).deletingLastPathComponent
        
        do {
            // Create destination directory if needed
            if !fileManager.fileExists(atPath: dstDirectory) {
                print("[MHA] Creating directory: \(dstDirectory)")
                try fileManager.createDirectory(atPath: dstDirectory, withIntermediateDirectories: true)
            }
            
            // Remove existing file if exists
            if fileManager.fileExists(atPath: dstFullPath) {
                print("[MHA] Removing existing file: \(dstFullPath)")
                try fileManager.removeItem(atPath: dstFullPath)
            }
            
            // Copy file
            print("[MHA] Copying file...")
            try fileManager.copyItem(atPath: srcPath, toPath: dstFullPath)
            
            print("[MHA] ✅ File written successfully")
            return true
            
        } catch {
            print("[MHA] ❌ Failed to write file: \(error)")
            return false
        }
    }
    
    /// Unmount all containers
    func unmountAll() {
        mountedContainers.removeAll()
        print("[MHA] All containers unmounted")
    }
    
    // MARK: - Private Methods
    
    /// Tìm UUID container của app dựa trên bundle ID
    private func findContainerUUID(for bundleID: String) -> String? {
        let basePath = "/private/var/mobile/Containers/Data/Application/"
        let fileManager = FileManager.default
        
        guard let enumerator = fileManager.enumerator(atPath: basePath) else {
            print("[MHA] Cannot enumerate \(basePath)")
            return nil
        }
        
        while let folderName = enumerator.nextObject() as? String {
            if folderName.contains("/") { continue }
            
            let plistPath = "\(basePath)\(folderName)/.com.apple.mobile_container_manager.metadata.plist"
            
            if fileManager.fileExists(atPath: plistPath) {
                if let plistData = fileManager.contents(atPath: plistPath),
                   let plist = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any],
                   let mcBundleID = plist["MCMMetadataIdentifier"] as? String {
                    
                    if mcBundleID == bundleID {
                        print("[MHA] Found container UUID: \(folderName) for \(bundleID)")
                        return folderName
                    }
                }
            }
            
            // Fallback: check Info.plist
            let infoPlistPath = "\(basePath)\(folderName)/Info.plist"
            if fileManager.fileExists(atPath: infoPlistPath) {
                if let plistData = fileManager.contents(atPath: infoPlistPath),
                   let plist = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any],
                   let cfBundleID = plist["CFBundleIdentifier"] as? String {
                    
                    if cfBundleID == bundleID {
                        print("[MHA] Found container UUID (Info.plist): \(folderName) for \(bundleID)")
                        return folderName
                    }
                }
            }
        }
        
        return nil
    }
}
