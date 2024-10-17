//import Foundation
//#if canImport(FoundationNetworking)
//import FoundationNetworking
//#endif
//
//// MARK: - ApifoxModel
//struct ApifoxModel: Codable {
//    let accountFilter: AccountFilter?
//    let base64Array: [String]?
//    let botType: BotType?
//    let notifyHook: String?
//    let prompt: String
//    let state: String?
//}
//
//// MARK: - AccountFilter
//struct AccountFilter: Codable {
//    let instanceId: String?
//    let modes: [Mode]?
//    let remix: Bool?
//    let remixAutoConsidered: Bool?
//}
//
//enum Mode: String, Codable {
//    case fast
//    case relax
//    case turbo
//}
//
//enum BotType: String, Codable {
//    case midJourney = "MID_JOURNEY"
//    case nijiJourney = "NIJI_JOURNEY"
//}
//
//// MARK: - Response Model
//struct ApiResponse: Codable {
//    let code: Int
//    let description: String
//    let properties: [String: AnyCodable]?
//    let result: String?
//}
//
//struct ActionRequest: Codable {
//    let customId: String
//    let taskId: String
//    let notifyHook: String?
//    let state: String?
//}
//
//struct ActionResponse: Codable {
//    let code: Int
//    let description: String
//    let properties: [String: AnyCodable]?
//    let result: String?
//}
//
//struct TaskStatusRequest: Codable {
//    let id: String
//}
//
//struct TaskStatusResponse: Codable {
//    let imageUrl: String?
//    let progress: String?
//    let buttons: [ActionButton]?
//}
//
//struct ActionButton: Codable {
//    let customId: String?
//}
//
//struct AnyCodable: Codable {
//    let value: Any
//
//    init(_ value: Any) {
//        self.value = value
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        if let value = try? container.decode(Bool.self) {
//            self.value = value
//        } else if let value = try? container.decode(Int.self) {
//            self.value = value
//        } else if let value = try? container.decode(Double.self) {
//            self.value = value
//        } else if let value = try? container.decode(String.self) {
//            self.value = value
//        } else if let value = try? container.decode([AnyCodable].self) {
//            self.value = value.map { $0.value }
//        } else if let value = try? container.decode([String: AnyCodable].self) {
//            self.value = value.mapValues { $0.value }
//        } else {
//            self.value = NSNull() // Handle null values
//        }
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        if let value = self.value as? Bool {
//            try container.encode(value)
//        } else if let value = self.value as? Int {
//            try container.encode(value)
//        } else if let value = self.value as? Double {
//            try container.encode(value)
//        } else if let value = self.value as? String {
//            try container.encode(value)
//        } else if let value = self.value as? [AnyCodable] {
//            try container.encode(value)
//        } else if let value = self.value as? [String: AnyCodable] {
//            try container.encode(value)
//        } else {
//            try container.encodeNil() // Handle null values
//        }
//    }
//}
////生成图片
//func submitImagineRequest(prompt: String, completion: @escaping (Result<ApiResponse, Error>) -> Void) {
//    let parameters = ApifoxModel(
//        accountFilter: AccountFilter(instanceId: "string", modes: [.relax], remix: true, remixAutoConsidered: true),
//        base64Array: [],
//        botType: .midJourney,
//        notifyHook: "string",
//        prompt: prompt,
//        state: "string"
//    )
//
//    guard let url = URL(string: "https://api.mjdjourney.cn/mj/submit/imagine") else { return }
//    
//    var request = URLRequest(url: url, timeoutInterval: Double.infinity)
//    request.addValue("Apifox/1.0.0 (https://apifox.com)", forHTTPHeaderField: "User-Agent")
//    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//    request.addValue("Bearer sk-HlCAlN9LDbK5a3aw5f63017eFc7f4a0dA82a290bE67a8d96", forHTTPHeaderField: "Authorization")  // 直接添加API密钥
//    request.httpMethod = "POST"
//
//    do {
//        let postData = try JSONEncoder().encode(parameters)
//        request.httpBody = postData
//    } catch {
//        completion(.failure(error))
//        return
//    }
//
//    let task = URLSession.shared.dataTask(with: request) { data, response, error in
//        if let error = error {
//            completion(.failure(error))
//            return
//        }
//        guard let data = data else {
//            let error = NSError(domain: "dataTask", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
//            completion(.failure(error))
//            return
//        }
//        do {
//            let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
//            completion(.success(apiResponse))
//        } catch {
//            completion(.failure(error))
//        }
//    }
//
//    task.resume()
//}
////https://api.mjdjourney.cn/mj/task//fetch
////导出图片地址
//func fetchTaskStatus(taskId: String, completion: @escaping (Result<(String?, String?, String?), Error>) -> Void) {
//    guard let url = URL(string: "https://api.mjdjourney.cn/mj/task/\(taskId)/fetch") else { return }
//    
//    var request = URLRequest(url: url, timeoutInterval: Double.infinity)
//    request.addValue("Apifox/1.0.0 (https://apifox.com)", forHTTPHeaderField: "User-Agent")
//    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//    request.addValue("Bearer sk-HlCAlN9LDbK5a3aw5f63017eFc7f4a0dA82a290bE67a8d96", forHTTPHeaderField: "Authorization")
//    request.httpMethod = "GET"
//    
//      let task = URLSession.shared.dataTask(with: request) { data, response, error in
//          if let error = error {
//              completion(.failure(error))
//              return
//          }
//          guard let data = data else {
//              let error = NSError(domain: "dataTask", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
//              completion(.failure(error))
//              return
//          }
//          
//          // Print the raw data to debug
//
//          
//          do {
//              let taskStatusResponse = try JSONDecoder().decode(TaskStatusResponse.self, from: data)
//              let imageUrl = taskStatusResponse.imageUrl
//              let progress = taskStatusResponse.progress
//              let customId = taskStatusResponse.buttons?.first?.customId
//              completion(.success((imageUrl, progress, customId)))
//          } catch {
//              completion(.failure(error))
//          }
//      }
//
//      task.resume()
//  }
//
//func executeUpscaleAction(customId: String, taskId: String, completion: @escaping (Result<String?, Error>) -> Void) {
//    guard let url = URL(string: "https://api.mjdjourney.cn/mj/submit/action") else { return }
//    var request = URLRequest(url: url, timeoutInterval: Double.infinity)
//    
//    let parameters = ActionRequest(customId: customId, taskId: taskId, notifyHook: nil, state: nil)
//    request.addValue("Apifox/1.0.0 (https://apifox.com)", forHTTPHeaderField: "User-Agent")
//    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//    request.addValue("Bearer sk-HlCAlN9LDbK5a3aw5f63017eFc7f4a0dA82a290bE67a8d96", forHTTPHeaderField: "Authorization")
//    request.httpMethod = "POST"
//
//    do {
//            let postData = try JSONEncoder().encode(parameters)
//            request.httpBody = postData
//        } catch {
//            completion(.failure(error))
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            guard let data = data else {
//                let error = NSError(domain: "dataTask", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
//                completion(.failure(error))
//                return
//            }
//            
//            // Print the raw data to debug
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("Raw JSON response: \(jsonString)")
//            }
//            
//            do {
//                let actionResponse = try JSONDecoder().decode(ActionResponse.self, from: data)
//                let result = actionResponse.result
//                completion(.success(result))
//            } catch {
//                completion(.failure(error))
//            }
//        }
//
//        task.resume()
//    }
//
//
//
//
//
//
//// URLSession delegate to ignore SSL errors (use for testing only)
//class URLSessionPinningDelegate: NSObject, URLSessionDelegate {
//    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        // 使用证书进行验证
//        if let serverTrust = challenge.protectionSpace.serverTrust {
//            let credential = URLCredential(trust: serverTrust)
//            completionHandler(.useCredential, credential)
//        } else {
//            completionHandler(.performDefaultHandling, nil)
//        }
//    }
//}
//
//func getDocumentsDirectory() -> URL {
//    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//    return paths[0]
//}
//
//func downloadImageUsingProxy(from url: URL, saveTo destination: URL, proxyHost: String, proxyPort: Int, proxyUser: String?, proxyPassword: String?, retryCount: Int = 200, completion: @escaping (Bool) -> Void) {
//    let configuration = URLSessionConfiguration.default
//        let proxyConfiguration: [AnyHashable : Any] = [
//            "HTTPSEnable": 1,
//            "HTTPSProxy": "64.176.47.144",
//            "HTTPSPort": 3128
//        ]
//    
//    if let proxyUser = proxyUser, let proxyPassword = proxyPassword {
//        let proxyAuth = "\(proxyUser):\(proxyPassword)".data(using: .utf8)!.base64EncodedString()
//        configuration.httpAdditionalHeaders = [
//            "Proxy-Authorization": "Basic \(proxyAuth)"
//        ]
//    }
//    
//    configuration.connectionProxyDictionary = proxyConfiguration
//    
//    let session = URLSession(configuration: configuration, delegate: URLSessionPinningDelegate(), delegateQueue: nil)
//     
//     let task = session.downloadTask(with: url) { (tempLocalUrl, response, error) in
//         if let tempLocalUrl = tempLocalUrl, error == nil {
//             do {
//                 if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
//                     try FileManager.default.moveItem(at: tempLocalUrl, to: destination)
//                     print("Image successfully downloaded to \(destination.path)")
//                     completion(true)
//                 } else {
//                     print("Invalid response: \(String(describing: response))")
//                     completion(false)
//                 }
//             } catch {
//                 print("Error saving file: \(error)")
//                 completion(false)
//             }
//         } else {
//             print("Download error: \(String(describing: error))")
//             if retryCount > 0 {
//                 print("Retrying in 5 seconds...")
//                 DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
//                     downloadImageUsingProxy(from: url, saveTo: destination, proxyHost: proxyHost, proxyPort: proxyPort, proxyUser: proxyUser, proxyPassword: proxyPassword, retryCount: retryCount - 1, completion: completion)
//                 }
//             } else {
//                 if let error = error as NSError? {
//                     print("Error Domain: \(error.domain), Code: \(error.code)")
//                     if let userInfo = error.userInfo as? [String: Any] {
//                         for (key, value) in userInfo {
//                             print("\(key): \(value)")
//                         }
//                     }
//                 }
//                 completion(false)
//             }
//         }
//     }
//     
//     task.resume()
// }
////循环检查程序是否完成
//func checkTaskProgress(taskId: String, completion: @escaping (String?, String?, String?) -> Void) {
//    fetchTaskStatus(taskId: taskId) { result in
//        switch result {
//        case .success(let (imageUrl, progress, customId)):
//            if progress == "100%" {
//                completion(imageUrl, progress, customId)
//            } else {
//                DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
//                    checkTaskProgress(taskId: taskId, completion: completion)
//                    print(progress ?? "0%")
//                }
//            }
//        case .failure(let error):
//            print("Error: \(error.localizedDescription)")
//            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
//                checkTaskProgress(taskId: taskId, completion: completion)
//            }
//        }
//    }
//}
