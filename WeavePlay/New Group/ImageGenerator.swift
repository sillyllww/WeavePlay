import Foundation
import UIKit

// 声明全局常量
let endpoint = "http://sd-abfda2--sd.fcv3.1073623476239213.cn-hangzhou.fc.devsapp.net"
let username = "sillyll"
let password = "123"

class ImageGenerator {
    private var retryCount = 0
    private let maxRetries = 10 // 最大重试次数
    private(set) var isGenerating: Bool = false
    
    func generateImage(initImage: String, prompt: String, denoisingStrength: Double, numSteps: Int, cfgScale: Double, negativePrompt: String, width: Int, height: Int, imageName: String, completion: @escaping (Result<URL, Error>) -> Void) {
        guard !isGenerating else {
            let error = NSError(domain: "ImageGeneratorError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image generation is already in progress"])
            completion(.failure(error))
            return
        }

        isGenerating = true
        // 拼接完整的 API 请求 URL
        let url = URL(string: "\(endpoint)/sdapi/v1/img2img")!
        print("Request URL: \(url.absoluteString)") // 打印 URL

        // 创建请求对象
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 300 // 设置超时时间为 300 秒

        // 设置鉴权
        let authString = "\(username):\(password)"
        if let authData = authString.data(using: .utf8) {
            let authValue = "Basic \(authData.base64EncodedString())"
            request.addValue(authValue, forHTTPHeaderField: "Authorization")
        }

        // 设置请求头
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let overrideSettings: [String: Any] = [
            "sd_model_checkpoint": "anything-v5-PrtRE.safetensors"
        ]

        // 设置请求体
        let json: [String: Any] = [
            "prompt": prompt,
            "negative_prompt": negativePrompt,
            "steps": numSteps,
            "cfg_scale": cfgScale,
            "width": width,
            "height": height,
            "denoising_strength": denoisingStrength,
            "init_images": [initImage],
            "override_settings": overrideSettings
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            request.httpBody = jsonData
        } catch {
            isGenerating = false
            completion(.failure(error))
            return
        }

        // 发送请求
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer {
                self.isGenerating = false
            }

            if let error = error {
                self.handleRetry(initImage: initImage, prompt: prompt, denoisingStrength: denoisingStrength, numSteps: numSteps, cfgScale: cfgScale, negativePrompt: negativePrompt, width: width, height: height, imageName: imageName, completion: completion, error: error)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data else {
                let error = NSError(domain: "ImageGeneratorError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response or data"])
                self.handleRetry(initImage: initImage, prompt: prompt, denoisingStrength: denoisingStrength, numSteps: numSteps, cfgScale: cfgScale, negativePrompt: negativePrompt, width: width, height: height, imageName: imageName, completion: completion, error: error)
                return
            }

            if httpResponse.statusCode == 200 {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let images = jsonResponse["images"] as? [String],
                       let imgBase64 = images.first,  // 只取第一个图像
                       let imgData = Data(base64Encoded: imgBase64),
                       let image = UIImage(data: imgData) {

                        if let savedURL = self.saveImageToDocumentsDirectory(image: image, fileName: imageName) {
                            completion(.success(savedURL))
                        } else {
                            let error = NSError(domain: "ImageGeneratorError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to save image"])
                            self.handleRetry(initImage: initImage, prompt: prompt, denoisingStrength: denoisingStrength, numSteps: numSteps, cfgScale: cfgScale, negativePrompt: negativePrompt, width: width, height: height, imageName: imageName, completion: completion, error: error)
                        }
                    } else {
                        let error = NSError(domain: "ImageGeneratorError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON response"])
                        self.handleRetry(initImage: initImage, prompt: prompt, denoisingStrength: denoisingStrength, numSteps: numSteps, cfgScale: cfgScale, negativePrompt: negativePrompt, width: width, height: height, imageName: imageName, completion: completion, error: error)
                    }
                } catch {
                    self.handleRetry(initImage: initImage, prompt: prompt, denoisingStrength: denoisingStrength, numSteps: numSteps, cfgScale: cfgScale, negativePrompt: negativePrompt, width: width, height: height, imageName: imageName, completion: completion, error: error)
                }
            } else {
                let error = NSError(domain: "ImageGeneratorError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Status: \(httpResponse.statusCode)"])
                self.handleRetry(initImage: initImage, prompt: prompt, denoisingStrength: denoisingStrength, numSteps: numSteps, cfgScale: cfgScale, negativePrompt: negativePrompt, width: width, height: height, imageName: imageName, completion: completion, error: error)
            }
        }

        task.resume()
    }




    private func handleRetry(initImage: String, prompt: String, denoisingStrength: Double, numSteps: Int, cfgScale: Double, negativePrompt: String, width: Int, height: Int, imageName: String, completion: @escaping (Result<URL, Error>) -> Void, error: Error) {
        if retryCount < maxRetries {
            retryCount += 1
            print("Retrying... (\(retryCount)/\(maxRetries))")
            // 调用 generateImage 函数进行重试
            generateImage(initImage: initImage, prompt: prompt, denoisingStrength: denoisingStrength, numSteps: numSteps, cfgScale: cfgScale, negativePrompt: negativePrompt, width: width, height: height, imageName: imageName, completion: completion)
        } else {
            completion(.failure(error))
        }
    }


    func removeBackground(imageUrl: URL,backgroundRemovedImage:String ,completion: @escaping (Result<URL, Error>) -> Void) {
        // 将图像数据转换为Base64
        guard let imageData = try? Data(contentsOf: imageUrl),
              let base64String = imageData.base64EncodedString(options: .lineLength64Characters) as String? else {
            let error = NSError(domain: "ImageGeneratorError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode image to Base64"])
            completion(.failure(error))
            return
        }
        
        // 拼接完整的 API 请求 URL
        let url = URL(string: "\(endpoint)/rembg")!
        
        // 创建请求对象
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 300 // 设置超时时间为 300 秒
        print(url)
        // 设置鉴权
        let authString = "\(username):\(password)"
        if let authData = authString.data(using: .utf8) {
            let authValue = "Basic \(authData.base64EncodedString())"
            request.addValue(authValue, forHTTPHeaderField: "Authorization")
        }
        
        // 设置请求头
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 设置请求体
        let json: [String: Any] = [
            "input_image": base64String,
            "model": "isnet-anime",
            "return_mask": false,
            "alpha_matting": false,
            "alpha_matting_foreground_threshold": 240,
            "alpha_matting_background_threshold": 5,
            "alpha_matting_erode_size": 5
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        // 发送请求
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data else {
                let error = NSError(domain: "ImageGeneratorError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response or data"])
                completion(.failure(error))
                return
            }
            
            if httpResponse.statusCode == 200 {
                do {
                    print(1)
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       
                       let outputImageBase64 = jsonResponse["image"] as? String {
                        
                        if let imgData = Data(base64Encoded: outputImageBase64),
                           let image = UIImage(data: imgData) {
                            
                            if let savedURL = self.saveImageToDocumentsDirectory(image: image, fileName:backgroundRemovedImage) {
                                completion(.success(savedURL))
                            } else {
                                let error = NSError(domain: "ImageGeneratorError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to save image"])
                                completion(.failure(error))
                            }
                        } else {
                            let error = NSError(domain: "ImageGeneratorError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode output image"])
                            completion(.failure(error))
                        }
                    } else {
                        let error = NSError(domain: "ImageGeneratorError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON response"])
                        completion(.failure(error))
                    }
                } catch {
                    completion(.failure(error))
                }
            } else {
                let error = NSError(domain: "ImageGeneratorError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Status: \(httpResponse.statusCode)"])
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func saveImageToDocumentsDirectory(image: UIImage, fileName: String) -> URL? {
        let fileManager = FileManager.default
        
        // 获取应用的Documents目录路径
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("无法获取Documents目录")
            return nil
        }
        
        // 生成文件路径
        let fileURL = documentsDirectory.appendingPathComponent("\(fileName).png")
        
        // 将UIImage转换为PNG格式的数据
        guard let imageData = image.pngData() else {
            print("无法转换UIImage为PNG格式的数据")
            return nil
        }
        
        do {
            // 将数据写入文件路径
            try imageData.write(to: fileURL)
            print("图片已保存到: \(fileURL.path)")
            return fileURL
        } catch {
            print("保存图片失败: \(error)")
            return nil
        }
    }
    
}
