import Foundation
import UIKit

class DownloadManager: NSObject, URLSessionDownloadDelegate {
    static let shared = DownloadManager()
    
    private var completionHandlers: [Int: (Bool, String?, Error?) -> Void] = [:]
    private var taskBundleIDs: [Int: String] = [:]
    private var taskFileNames: [Int: String] = [:]
    
    // MARK: - Public API
    
    /// Download file and inject into target app container
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
    
    /// Find container UUID for a given bundle ID
    func findContainerUUID(for bundleID: String) -> String? {
        print("[DownloadManager] Finding container UUID for: \(bundleID)")
        
        let basePath = "/private/var/mobile/Containers/Data/Application/"
        let fileManager = FileManager.default
        
        guard let enumerator = fileManager.enumerator(atPath: basePath) else {
            print("[DownloadManager] ❌ Cannot enumerate \(basePath)")
            return nil
        }
        
        while let folderName = enumerator.nextObject() as? String {
            if folderName.contains("/") { continue }
            
            // Check .com.apple.mobile_container_manager.metadata.plist
            let metadataPlist = "\(basePath)\(folderName)/.com.apple.mobile_container_manager.metadata.plist"
            
            if fileManager.fileExists(atPath: metadataPlist) {
                if let data = fileManager.contents(atPath: metadataPlist),
                   let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
                   let mcID = plist["MCMMetadataIdentifier"] as? String,
                   mcID == bundleID {
                    print("[DownloadManager] ✅ Found UUID: \(folderName)")
                    return folderName
                }
            }
        }
        
        print("[DownloadManager] ❌ UUID not found for \(bundleID)")
        return nil
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
            
            // Move downloaded file to temp directory
            let tempDir = FileManager.default.temporaryDirectory
            let destinationURL = tempDir.appendingPathComponent("payload_\(UUID().uuidString).dat")
            
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            try FileManager.default.moveItem(at: location, to: destinationURL)
            print("[DownloadManager] File moved to: \(destinationURL.path)")
            
            // Find container UUID
            guard let uuid = findContainerUUID(for: bundleID) else {
                throw NSError(domain: "GameNotFound", code: -2, 
                            userInfo: [NSLocalizedDescriptionKey: "Game not found. Please open the game at least once."])
            }
            
            // Build target path
            let targetPath = "/private/var/mobile/Containers/Data/Application/\(uuid)/Documents/contentcache/Compulsory/ios/gameassetbundles/\(fileName)"
            
            print("[DownloadManager] Target path: \(targetPath)")
            
            // Write file using ExploitManager
            let success = ExploitManager.writeFile(src: destinationURL.path, dst: targetPath)
            
            if success {
                print("[DownloadManager] ✅ Injection successful")
                completion(true, "Successfully injected into: \(targetPath)", nil)
            } else {
                throw NSError(domain: "ExploitFailed", code: -3, 
                            userInfo: [NSLocalizedDescriptionKey: "Exploit failed. Device or iOS version not supported."])
            }
            
            // Cleanup temp file
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
