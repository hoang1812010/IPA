import Foundation

class KeyValidator {
    static let shared = KeyValidator()
    
    private let apiURL = "https://key-server-api.dinhtienhoang1812010.workers.dev/api/client/validate"
    
    func validate(key: String, deviceId: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: apiURL) else {
            completion(false, "Invalid API URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let body: [String: Any] = [
            "key": key,
            "deviceId": deviceId
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(false, "Failed to encode request")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(false, "Network error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, "No data received from server")
                }
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                
                // Thử parse theo nhiều định dạng phổ biến
                var isValid = false
                var message: String? = nil
                
                if let success = json?["success"] as? Bool {
                    isValid = success
                } else if let valid = json?["valid"] as? Bool {
                    isValid = valid
                } else if let status = json?["status"] as? String {
                    isValid = (status.lowercased() == "success" || status.lowercased() == "valid")
                }
                
                message = (json?["message"] as? String) ?? (json?["msg"] as? String)
                
                DispatchQueue.main.async {
                    completion(isValid, message)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, "Server response invalid format")
                }
            }
        }
        
        task.resume()
    }
}
