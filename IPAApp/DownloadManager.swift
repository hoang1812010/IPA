import Foundation
import UIKit

@_silgen_name("kfp_write_file")
func kfp_write_file(_ src: UnsafePointer<CChar>, _ dst: UnsafePointer<CChar>) -> Int32

class DownloadManager: NSObject, URLSessionDownloadDelegate {
    static let shared = DownloadManager()
    private var completionHandlers: [Int: (Bool, String?, Error?) -> Void] = [:]
    private var taskBundleIDs: [Int: String] = [:]

    func findContainerUUID(for bundleID: String) -> String? {
        let basePath = "/private/var/mobile/Containers/Data/Application/"
        guard let enumerator = FileManager.default.enumerator(atPath: basePath) else { return nil }

        while let folderName = enumerator.nextObject() as? String {
            if folderName.contains("/") { continue }
            let plistPath = "\(basePath)\(folderName)/Info.plist"
            if FileManager.default.fileExists(atPath: plistPath) {
                if let plistData = FileManager.default.contents(atPath: plistPath),
                   let plist = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any],
                   let cfBundleID = plist["CFBundleIdentifier"] as? String {
                    if cfBundleID == bundleID {
                        return folderName
                    }
                }
            }
        }
        return nil
    }

    func downloadAndInject(urlString: String, bundleID: String, fileName: String, completion: @escaping (Bool, String?, Error?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(false, nil, NSError(domain: "InvalidURL", code: -1, userInfo: nil))
            return
        }
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: url)
        taskBundleIDs[task.taskIdentifier] = bundleID
        completionHandlers[task.taskIdentifier] = completion
        task.resume()
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let taskID = downloadTask.taskIdentifier
        guard let completion = completionHandlers[taskID],
              let bundleID = taskBundleIDs[taskID] else { return }

        do {
            let tempDir = FileManager.default.temporaryDirectory
            let destinationURL = tempDir.appendingPathComponent("payload_tmp.dat")
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.moveItem(at: location, to: destinationURL)

            // Tìm UUID của ứng dụng dựa trên bundleID đã chọn
            guard let uuid = findContainerUUID(for: bundleID) else {
                throw NSError(domain: "GameNotFound", code: -2, userInfo: [NSLocalizedDescriptionKey: "Game not found. Please open the game at least once."])
            }

            // Đường dẫn target được xây dựng động với UUID tìm được
            let targetPath = "/private/var/mobile/Containers/Data/Application/\(uuid)/Documents/contentcache/Compulsory/ios/gameassetbundles/cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs~3D"
            let sourcePath = destinationURL.path

            let success = ExploitManager.writeFile(src: sourcePath, dst: targetPath)
            if success {
                completion(true, "Successfully injected into: \(targetPath)", nil)
            } else {
                throw NSError(domain: "ExploitFailed", code: -3, userInfo: [NSLocalizedDescriptionKey: "Exploit failed. Device or iOS version not supported."])
            }
        } catch {
            completion(false, nil, error)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let taskID = task.taskIdentifier
        guard let completion = completionHandlers[taskID] else { return }
        if let error = error {
            completion(false, nil, error)
        }
        completionHandlers.removeValue(forKey: taskID)
        taskBundleIDs.removeValue(forKey: taskID)
    }
}
