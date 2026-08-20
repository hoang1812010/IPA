//
//  DownloadManager.swift
//  IPAApp
//
//  Created on 2024.
//

import Foundation
import UIKit

class DownloadManager {
    static let shared = DownloadManager()
    
    private init() {}
    
    /// Tải file từ URL và ghi đè lên file target
    func downloadAndReplaceFile(from url: String, bundleIdentifier: String, featureName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let downloadURL = URL(string: url) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let session = URLSession(configuration: .default)
        let task = session.downloadTask(with: downloadURL) { tempLocalURL, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let tempLocalURL = tempLocalURL else {
                completion(.failure(URLError(.cannotFindHost)))
                return
            }
            
            // Di chuyển file đến thư mục tạm trong app
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileName = downloadURL.lastPathComponent.isEmpty ? "downloaded_file" : downloadURL.lastPathComponent
            let finalURL = documentsURL.appendingPathComponent(fileName)
            
            do {
                // Xóa file cũ nếu tồn tại
                if fileManager.fileExists(atPath: finalURL.path) {
                    try fileManager.removeItem(at: finalURL)
                }
                
                try fileManager.moveItem(at: tempLocalURL, to: finalURL)
                
                // Bây giờ thực hiện ghi đè file target sử dụng kernel exploit
                self.replaceTargetFile(with: finalURL, bundleIdentifier: bundleIdentifier) { result in
                    // Xóa file tạm sau khi hoàn thành
                    try? fileManager.removeItem(at: finalURL)
                    completion(result)
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    /// Ghi đè file target với file đã tải sử dụng kernel exploit
    private func replaceTargetFile(with sourceURL: URL, bundleIdentifier: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Đường dẫn target cố định theo yêu cầu
        // /private/var/mobile/Containers/Data/Application/<bundle>/Library/Caches/cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs~3D
        let targetPath = "/private/var/mobile/Containers/Data/Application/\(bundleIdentifier)/Library/Caches/cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs~3D"
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let fileManager = FileManager.default
                
                // Kiểm tra file nguồn có tồn tại không
                guard fileManager.fileExists(atPath: sourceURL.path) else {
                    completion(.failure(NSError(domain: "DownloadManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Không tìm thấy file đã tải xuống"])))
                    return
                }
                
                // Đọc dữ liệu từ file nguồn
                let fileData = try Data(contentsOf: sourceURL)
                
                print("Đã đọc \(fileData.count) bytes từ file nguồn")
                print("Sẽ ghi đè vào: \(targetPath)")
                
                // TODO: Tích hợp kernel exploit từ repository để ghi đè file protected
                // Hiện tại chỉ là placeholder - cần tích hợp code từ kexploit/
                
                // Các bước cần thực hiện:
                // 1. Sử dụng kernel exploit để vượt qua sandbox
                // 2. Sử dụng vnode manipulation để ghi đè file target
                // 3. Tham khảo code trong thư mục kexploit/ và exploit/
                
                /*
                 * Ví dụ tích hợp (cần implement):
                 * 
                 * // Từ kexploit/vnode.m
                 * vnode_overwrite(targetPath, fileData.bytes, fileData.count)
                 * 
                 * // Hoặc sử dụng sandbox_escape.m
                 * sandbox_escape_and_write(targetPath, fileData)
                 */
                
                // Placeholder hiện tại - sẽ thành công giả lập
                // Bạn cần thay thế bằng code exploit thực tế từ repo
                print("[PLACEHOLDER] Sẽ sử dụng kernel exploit để ghi đè file")
                print("[PLACEHOLDER] Target: \(targetPath)")
                print("[PLACEHOLDER] Data size: \(fileData.count) bytes")
                
                // Giả lập thành công cho mục đích demo
                // Replace this with actual exploit call:
                // let success = vnode_overwrite(targetPath, fileData.bytes, fileData.count)
                let success = true // Placeholder
                
                if success {
                    completion(.success(()))
                } else {
                    completion(.failure(NSError(domain: "DownloadManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Không thể ghi đè file target"])))
                }
                
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Device Info Helper
extension UIDevice {
    var uniqueDeviceIdentifier: String {
        return self.identifierForVendor?.uuidString ?? "unknown"
    }
}

// MARK: - Key Validation
class KeyValidator {
    static let shared = KeyValidator()
    
    // Server URL - Trỏ tới Cloudflare Worker
    var serverURL: String = "https://key-server-api.dinhtienhoang1812010.workers.dev/api/client/validate"
    
    private init() {}
    
    func validate(key: String, deviceId: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: serverURL) else {
            completion(false, "Invalid server URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["key": key, "udid": deviceId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, "Lỗi kết nối: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                completion(false, "Không nhận được phản hồi từ server")
                return
            }
            
            do {
                // Parse JSON response từ Cloudflare API (dùng trường "success")
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let isSuccess = json["success"] as? Bool {
                    
                    if isSuccess {
                        completion(true, nil)
                    } else {
                        let message = json["message"] as? String ?? "Key không hợp lệ"
                        completion(false, message)
                    }
                } else {
                    completion(false, "Dữ liệu trả về không đúng định dạng")
                }
            } catch {
                completion(false, "Lỗi parse phản hồi: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
}
