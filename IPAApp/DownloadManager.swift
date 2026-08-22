import Foundation
import UIKit

class DownloadManager: NSObject, URLSessionDownloadDelegate {
    static let shared = DownloadManager()
    
    private var completionHandlers: [Int: (Bool, String?, Error?) -> Void] = [:]
    private var taskBundleIDs: [Int: String] = [:]
    private var taskFileNames: [Int: String] = [:]
    private var progressHandlers: [Int: ((Double) -> Void)] = [:]
    
    // MARK: - Public API
    
    /// Tải file và inject vào container app mục tiêu
    func downloadAndInject(urlString: String, bundleID: String, fileName: String, 
                          progressHandler: ((Double) -> Void)? = nil,
                          completion: @escaping (Bool, String?, Error?) -> Void) {
        print("[DownloadManager] 🚀 Bắt đầu download")
        print("[DownloadManager]   URL: \(urlString)")
        print("[DownloadManager]   Bundle ID: \(bundleID)")
        print("[DownloadManager]   File name: \(fileName)")
        
        guard let url = URL(string: urlString) else {
            completion(false, nil, NSError(domain: "InvalidURL", code: -1, 
                                         userInfo: [NSLocalizedDescriptionKey: "URL không hợp lệ"]))
            return
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: url)
        
        taskBundleIDs[task.taskIdentifier] = bundleID
        taskFileNames[task.taskIdentifier] = fileName
        completionHandlers[task.taskIdentifier] = completion
        if let progressHandler = progressHandler {
            progressHandlers[task.taskIdentifier] = progressHandler
        }
        
        task.resume()
    }
    
    /// Tìm UUID container cho một bundle ID cụ thể (dùng kernel exploit)
    func findContainerUUID(for bundleID: String) -> String? {
        print("[DownloadManager] 🔍 Đang tìm UUID cho: \(bundleID)")
        
        // Ưu tiên dùng kernel exploit để tìm container
        if let uuid = ExploitManager.findContainerUUID(for: bundleID) {
            print("[DownloadManager] ✅ Tìm thấy UUID qua kernel: \(uuid)")
            return uuid
        }
        
        // Fallback: Quét filesystem (chỉ hoạt động nếu đã thoát sandbox)
        print("[DownloadManager] ⚠️ Kernel thất bại, thử quét filesystem...")
        return findContainerUUIDViaFilesystem(for: bundleID)
    }
    
    /// Fallback: Tìm UUID bằng cách quét filesystem
    private func findContainerUUIDViaFilesystem(for bundleID: String) -> String? {
        let basePath = "/private/var/mobile/Containers/Data/Application/"
        let fileManager = FileManager.default
        
        guard let enumerator = fileManager.enumerator(atPath: basePath) else {
            print("[DownloadManager] ❌ Không liệt kê được \(basePath)")
            return nil
        }
        
        while let folderName = enumerator.nextObject() as? String {
            if folderName.contains("/") { continue }
            
            // Kiểm tra file metadata plist
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
            
            // Fallback: Kiểm tra Info.plist
            let infoPlist = "\(basePath)\(folderName)/Info.plist"
            if fileManager.fileExists(atPath: infoPlist) {
                if let data = fileManager.contents(atPath: infoPlist),
                   let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
                   let cfBundleID = plist["CFBundleIdentifier"] as? String,
                   cfBundleID == bundleID {
                    print("[DownloadManager] ✅ Tìm thấy UUID qua Info.plist: \(folderName)")
                    return folderName
                }
            }
        }
        
        print("[DownloadManager] ❌ Không tìm thấy UUID cho \(bundleID)")
        print("[DownloadManager] 💡 Đảm bảo:")
        print("   - App đã được mở ít nhất 1 lần")
        print("   - Bundle ID chính xác")
        return nil
    }
    
    /// Xây dựng đường dẫn inject cho Free Fire
    private func buildInjectionPath(uuid: String, fileName: String, bundleID: String) -> String {
        let basePath = "/private/var/mobile/Containers/Data/Application/\(uuid)"
        
        // Free Fire specific path
        if bundleID == "com.dts.freefireth" || bundleID == "com.dts.freefiremax" {
            return "\(basePath)/Documents/contentcache/Compulsory/ios/gameassetbundles/\(fileName)"
        }
        
        // Default path for other apps
        return "\(basePath)/Documents/\(fileName)"
    }
    
    // MARK: - URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, 
                   didFinishDownloadingTo location: URL) {
        let taskID = downloadTask.taskIdentifier
        
        guard let completion = completionHandlers[taskID],
              let bundleID = taskBundleIDs[taskID],
              let fileName = taskFileNames[taskID] else {
            print("[DownloadManager] ❌ Thiếu thông tin task")
            return
        }
        
        do {
            print("[DownloadManager] ✅ Download hoàn tất")
            
            // Di chuyển file đã tải về thư mục temp
            let tempDir = FileManager.default.temporaryDirectory
            let destinationURL = tempDir.appendingPathComponent("payload_\(UUID().uuidString).dat")
            
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            try FileManager.default.moveItem(at: location, to: destinationURL)
            print("[DownloadManager] File đã di chuyển đến: \(destinationURL.path)")
            
            // Tìm UUID container
            guard let uuid = findContainerUUID(for: bundleID) else {
                throw NSError(domain: "GameNotFound", code: -2, 
                            userInfo: [NSLocalizedDescriptionKey: "Không tìm thấy game. Vui lòng mở game ít nhất 1 lần trước khi inject."])
            }
            
            // Xây dựng đường dẫn mục tiêu
            let targetPath = buildInjectionPath(uuid: uuid, fileName: fileName, bundleID: bundleID)
            
            print("[DownloadManager] 📍 Đường dẫn mục tiêu: \(targetPath)")
            
            // Đảm bảo thư mục đích tồn tại
            let targetDir = (targetPath as NSString).deletingLastPathComponent
            if !FileManager.default.fileExists(atPath: targetDir) {
                try FileManager.default.createDirectory(atPath: targetDir, 
                                                       withIntermediateDirectories: true, 
                                                       attributes: nil)
                print("[DownloadManager] ✅ Đã tạo thư mục: \(targetDir)")
            }
            
            // Ghi file bằng ExploitManager
            print("[DownloadManager] 🚀 Bắt đầu inject...")
            let success = ExploitManager.writeFile(src: destinationURL.path, dst: targetPath)
            
            if success {
                print("[DownloadManager] ✅ Inject thành công!")
                print("[DownloadManager] 📊 File đã ghi vào: \(targetPath)")
                
                // Kiểm tra file đã ghi thật sự chưa
                if FileManager.default.fileExists(atPath: targetPath) {
                    let attrs = try FileManager.default.attributesOfItem(atPath: targetPath)
                    let fileSize = attrs[.size] as? Int64 ?? 0
                    print("[DownloadManager] 📏 Kích thước file: \(fileSize) bytes")
                    completion(true, "Inject thành công: \(targetPath) (\(fileSize) bytes)", nil)
                } else {
                    completion(true, "Inject hoàn tất (không thể xác minh file)", nil)
                }
            } else {
                throw NSError(domain: "ExploitFailed", code: -3, 
                            userInfo: [NSLocalizedDescriptionKey: "Exploit thất bại. Thiết bị hoặc phiên bản iOS không được hỗ trợ."])
            }
            
            // Dọn dẹp file temp
            try? FileManager.default.removeItem(at: destinationURL)
            print("[DownloadManager] 🧹 Đã dọn dẹp file tạm")
            
        } catch {
            print("[DownloadManager] ❌ Lỗi: \(error.localizedDescription)")
            completion(false, nil, error)
        }
        
        // Xóa handlers
        completionHandlers.removeValue(forKey: taskID)
        taskBundleIDs.removeValue(forKey: taskID)
        taskFileNames.removeValue(forKey: taskID)
        progressHandlers.removeValue(forKey: taskID)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, 
                   didWriteData bytesWritten: Int64, 
                   totalBytesWritten: Int64, 
                   totalBytesExpectedToWrite: Int64) {
        let taskID = downloadTask.taskIdentifier
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        
        progressHandlers[taskID]?(progress)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, 
                   didCompleteWithError error: Error?) {
        guard let error = error,
              let downloadTask = task as? URLSessionDownloadTask else {
            return
        }
        
        let taskID = downloadTask.taskIdentifier
        
        print("[DownloadManager] ❌ Download thất bại: \(error.localizedDescription)")
        
        if let completion = completionHandlers[taskID] {
            completion(false, nil, error)
        }
        
        // Xóa handlers
        completionHandlers.removeValue(forKey: taskID)
        taskBundleIDs.removeValue(forKey: taskID)
        taskFileNames.removeValue(forKey: taskID)
        progressHandlers.removeValue(forKey: taskID)
    }
}

// MARK: - Extension cho ViewController sử dụng

extension DownloadManager {
    /// Hàm tiện ích để inject từ ViewController
    func injectFeature(urlString: String, bundleID: String, fileName: String,
                      onProgress: ((Double) -> Void)? = nil,
                      onSuccess: ((String) -> Void)? = nil,
                      onError: ((Error) -> Void)? = nil) {
        
        downloadAndInject(urlString: urlString, bundleID: bundleID, fileName: fileName,
                         progressHandler: onProgress) { success, message, error in
            DispatchQueue.main.async {
                if success {
                    onSuccess?(message ?? "Thành công")
                } else if let error = error {
                    onError?(error)
                }
            }
        }
    }
}
