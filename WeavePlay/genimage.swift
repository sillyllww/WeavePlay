////
////  genimage.swift
////  WeavePlay
////
////  Created by 李龙 on 2024/7/19.
////
//
//import SwiftUI
//
//struct genimage: View {
//
//    @State private var prompt: String = ""
//    @State private var image: Image? = nil
//    @State private var isDownloaded = false
//    @State private var taskId:String = "1721457474102262"
//    @State private var imageUrl: String?
//    @State private var progress: String?
//    @State private var customId: String?
//    @State private var genprogress:Int = 0
//    let diantu = ""
//    var body: some View {
//        ZStack{
//            VStack {
//                if let image = image {
//                    image
//
//                } else {
//                    Text("Downloading image...")
//                }
//            }
//            VStack {
//                TextField("car", text: $prompt)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding()
//                Text("\(genprogress)")
//                Button("生成图片") {
//                    genpicture(prompt: prompt)
//                }
//                .padding()
//            }
//            .padding()
//        }
//    }
//    
//    
//    func genpicture(prompt: String){
//        submitImagineRequest(prompt: prompt) { result in
//            switch result {
//            case .success(let response):
//                if response.code == 1, let result = response.result {
//                    self.taskId = result
//                    print(taskId)
//                    genprogress = 5
//                    // 检查任务进度
//                    checkTaskProgress(taskId: taskId) { imageUrl, progress, customId in
//                        if let customId = customId {
//                            genprogress = 50
//                            // 执行放大操作
//                            executeUpscaleAction(customId: customId, taskId: taskId) { result in
//                                switch result {
//                                case .success(let newTaskId):
//                                    if let newTaskId = newTaskId {
//                                        genprogress = 60
//                                        // 再次检查任务进度
//                                        checkTaskProgress(taskId: newTaskId) { imageUrl, progress, _ in
//                                            if progress == "100%" {
//                                                genprogress = 80
//                                                self.imageUrl = imageUrl
//                                                downloadAndDisplayImage()
//                                            }
//                                        }
//                                    } else {
//                                        print("No new task ID returned.")
//                                    }
//                                case .failure(let error):
//                                    print("Error: \(error.localizedDescription)")
//                                }
//                            }
//                        } else {
//                            print("Custom ID not found.")
//                        }
//                    }
//                } else {
//                    print("Failed to generate image: \(response.description)")
//                }
//            case .failure(let error):
//                print("Error: \(error.localizedDescription)")
//            }
//        }
//    }
//    func downloadAndDisplayImage() {
//        let imageUrl = URL(string: imageUrl!)!
//        let saveUrl = getDocumentsDirectory().appendingPathComponent("\(taskId).png")
//        let proxyHost = "64.176.47.144"
//        let proxyPort = 3128
//        let proxyUser: String? = "user"  // 如果没有身份验证，设为nil
//        let proxyPassword: String? = "163500"
//
//        downloadImageUsingProxy(from: imageUrl, saveTo: saveUrl, proxyHost: proxyHost, proxyPort: proxyPort, proxyUser: proxyUser, proxyPassword: proxyPassword) { success in
//                DispatchQueue.main.async {
//                    if success {
//                        if let uiImage = UIImage(contentsOfFile: saveUrl.path) {
//                            self.image = Image(uiImage: uiImage)
//                            genprogress = 100
//                        } else {
//                            self.image = nil
//                        }
//                    } else {
//                        self.image = nil
//                    }
//                }
//            }
//        }
//}
//
//#Preview {
//    genimage()
//}
