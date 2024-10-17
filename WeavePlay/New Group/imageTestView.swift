import SwiftUI//这是1.0.7
import UIKit
import Foundation
struct sdView: View {
    @State private var image: Image? = nil
    @State private var isDownloading = false
    @State private var prompt: String = "girl"
    @State private var generatedImageurl: URL? = nil
    @State private var isLoading: Bool = false
    @State private var isUploading: Bool = false
    let bucketName = "fc-sd-62aafe39g"
    let endpoint = "oss-cn-hangzhou.aliyuncs.com"
    let objectKey = "charaImage/01.jpeg"
    let objectname = "charaImage/haha/02.png"
    let generator = ImageGenerator()
    
    var body: some View {
        VStack {
            HStack {
                TextField("Enter prompt", text: $prompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: generateImages) {
                    Text("Generate")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(isLoading || prompt.isEmpty)
            }
            
            if isLoading {
                ProgressView("Generating images...")
                    .padding()
            } else {
                ScrollView {
                    ZStack{
                        Spacer()
                            .background(.main)
                            .frame(width: 100,height: 100)
                        VStack {
                            if let imageUrl = generatedImageurl {
                                
                                if let uiImage = UIImage(contentsOfFile: imageUrl.path) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: 100, maxHeight: 100)
                                }
                            }
                        }
                    }

                }
            }
            VStack {
                        Button(action: {
                            downloadImage()
                        }) {
                            Text("Download Image")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(isDownloading)
                        
                        if isDownloading || isUploading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            image?
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                        }
                    }
                    .padding()
        }
        .padding()
    }
    

    private func downloadImage() {
        isDownloading = true
        
        let url = URL(string: "https://\(bucketName).\(endpoint)/\(objectKey)")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Download failed: \(error)")
                } else if let data = data, let uiImage = UIImage(data: data) {
                    self.image = Image(uiImage: uiImage)
                }
                self.isDownloading = false
            }
        }
        
        task.resume()
    }
    private func uploadImage(fileURL: URL) {
        isUploading = true
        let url = URL(string: "https://\(bucketName).\(endpoint)/\(objectname)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.uploadTask(with: request, fromFile: fileURL) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Upload failed: \(error)")
                } else {
                    print("Upload succeeded")
                }
                self.isUploading = false
            }
        }
        
        task.resume()
    }

    private func generateImages() {
        isLoading = true
        
        generator.generateImage(
            initImage: "https://img.zcool.cn/community/0140786040772811013ef90fafe315.jpg@2o.jpg",
            prompt: prompt,
            denoisingStrength: 0.45,
            numSteps: 30,
            cfgScale: 7,
            negativePrompt: "",
            width: 300,
            height: 800,
            imageName: "hah"
        ) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let imageURL):
                    self.generatedImageurl = imageURL
                    
                    // 调用 removeBackground 函数
                    self.generator.removeBackground(imageUrl: imageURL, backgroundRemovedImage: "1") { removeResult in
                        DispatchQueue.main.async {
                            switch removeResult {
                            case .success(let processedImageURL):
                                // 将处理后的图像 URL 赋值给 generatedImageurl
                                self.generatedImageurl = processedImageURL
                                print("Background removed successfully.")
                                
                                // 在这里调用 uploadImage
                                self.uploadImage(fileURL: processedImageURL)
                                
                            case .failure(let error):
                                print("Failed to remove background: \(error)")
                            }
                        }
                    }
                    
                case .failure(let error):
                    print("Failed to generate images: \(error)")
                }
            }
        }
    }




}

struct sdView_Previews: PreviewProvider {
    static var previews: some View {
        sdView()
    }
}
