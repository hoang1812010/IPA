import Foundation

class DownloadManager: NSObject, URLSessionDownloadDelegate {
    static let shared = DownloadManager()
    
    private var completionHandlers: [Int: (Bool, String?, Error?) -> Void] = [:]
    private var taskBundleIDs: [Int: String] = [:]
    private var taskFileNames: [Int: String] = [:]
    
    // MARK: - Public API
    
    func downloadAndInject(urlString: String, bundleID: String, fileName: String, completion: @escaping (Bool, String?, Error?) -> Void) {
        print("[DownloadManager] Starting download")
        print("[DownloadManager]   URL: \(urlString)")
        print("[DownloadManager]   Bundle ID: \(bundleID)")
        print("[DownloadManager]   File name: \(fileName)")
        
        guard let url = URL(string: urlString) else {
            completion(false, nil, NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: url)
        
        taskBundleIDs[task.taskIdentifier] = bundleID
        taskFileNames[task.taskIdentifier] = fileName
        completionHandlers[task.taskIdentifier] = completion
        
        task.resume()
    }
    
    /// Tìm container UUID bằng MCM API (giống 3105)
    func findContainerUUID(for bundleID: String) -> String? {
        print("[DownloadManager] 🔍 Tìm container cho: \(bundleID)")
        
        // Dùng MCM API
        var error: NSString?
        guard let containerPath = MCMActivateContainerPath(1, bundleID, false, &error) as String? else {
            print("[DownloadManager] ❌ MCM thất bại: \(error?.description ?? "unknown")")
            print("[DownloadManager] 💡 Kiểm tra:")
            print("   - App đã được mở ít nhất 1 lần?")
            print("   - Bundle ID đúng?")
            print("   - Sign với Enterprise cert có entitlement 'com.apple.private.housearrest'?")
            return nil
        }
        
        print("[DownloadManager] ✅ MCM trả về: \(containerPath)")
        
        // Trích xuất UUID từ path
        let components = containerPath.components(separatedBy: "/")
        guard let appIndex = components.firstIndex(of: "Application"),
              appIndex + 1 < components.count else {
            print("[DownloadManager] ❌ Không trích xuất được UUID")
            return nil
        }
        
        let uuid = components[appIndex + 1]
        print("[DownloadManager] ✅ UUID: \(uuid)")
        return uuid
    }
    
    // MARK: - URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let taskID = downloadTask.taskIdentifier
        
        guard let completion = completionHandlers[taskID],
              let bundleID = taskBundleIDs[taskID],
              let fileName = taskFileNames[taskID] else {
            return
        }
        
        do {
            print("[DownloadManager] Download completed")
            
            let tempDir = FileManager.default.temporaryDirectory
            let destinationURL = tempDir.appendingPathComponent("payload_\(UUID().uuidString).dat")
            
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            try FileManager.default.moveItem(at: location, to: destinationURL)
            print("[DownloadManager] File moved to: \(destinationURL.path)")
            
            guard let uuid = findContainerUUID(for: bundleID) else {
                throw NSError(domain: "GameNotFound", code: -2, 
                            userInfo: [NSLocalizedDescriptionKey: "Game not found. Please open the game at least once."])
            }
            
            let targetPath = "/private/var/mobile/Containers/Data/Application/\(uuid)/Documents/contentcache/Compulsory/ios/gameassetbundles/\(fileName)"
            
            print("[DownloadManager] Target path: \(targetPath)")
            
            let success = ExploitManager.writeFile(src: destinationURL.path, dst: targetPath)
            
            if success {
                print("[DownloadManager] ✅ Injection successful")
                completion(true, "Successfully injected into: \(targetPath)", nil)
            } else {
                throw NSError(domain: "ExploitFailed", code: -3, 
                            userInfo: [NSLocalizedDescriptionKey: "Exploit failed. Device or iOS version not supported."])
            }
            
            try? FileManager.default.removeItem(at: destinationURL)
            
        } catch {
            print("[DownloadManager] ❌ Error: \(error)")
            completion(false, nil, error)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let taskID = task.taskIdentifier
        
        guard let completion = completionHandlers[taskID] else { return }
        
        if let error = error {
            print("[DownloadManager] ❌ Download failed: \(error)")
            completion(false, nil, error)
        }
        
        completionHandlers.removeValue(forKey: taskID)
        taskBundleIDs.removeValue(forKey: taskID)
        taskFileNames.removeValue(forKey: taskID)
    }
}
