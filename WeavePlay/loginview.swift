//
//  loginview.swift
//  WeavePlay
//
//  Created by 李龙 on 2024/9/2.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var authManager = AuthManager()
    @EnvironmentObject var globalSettings: GlobalSettings
    @EnvironmentObject var timerManager: TimerManager
    @State private var phoneNumber: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var stories = Stories.load() // 管理多个故事
    let bucketName = "fc-sd-62aafe39g"
    let endpoint = "oss-cn-hangzhou.aliyuncs.com"
    @State private var tochildrenView:Bool = false
    @State private var toOnboardingView:Bool = false
    @State private var isupload:Bool = false
    var body: some View {
         NavigationStack {
             
             ZStack{
                 Image("back_image")
                     .resizable()
                     .scaledToFill()
                     
                     .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                     .offset(x: 0, y: 0) // 调整x和y的值来平移图片位置
                     .ignoresSafeArea(.all)
                     .scaleEffect(1.009)
                 RoundedRectangle(cornerRadius: 50)
                     .fill(Color.white)
                     .frame(width: UIScreen.main.bounds.width)
                     .padding(.top,230)
                 Image("bear_start")
                     .padding(.bottom,500)
                 VStack {
                     Spacer()
                     Text("weaveplay")
                         .font(.system(size: 40))
                         .bold()
                         .opacity(0.7)
                         .padding(10)
                         .padding(.horizontal,20)
                         .frame(width: UIScreen.main.bounds.width, alignment: .leading)
                     Text("登录创作儿童故事")
                         .font(.system(size: 20))
                         .opacity(0.6)
                         .padding(.horizontal,30)
                         .frame(width: UIScreen.main.bounds.width, alignment: .leading)
                         .padding(.bottom,50)
                     Text("电话/邮件")
                         .font(.system(size: 15))
                         .opacity(0.6)
                         .padding(.horizontal,30)
                         .frame(width: UIScreen.main.bounds.width, alignment: .leading)
                     TextField("请输入手机号或邮件", text: $phoneNumber)
                         .padding(5)
                         .background(Color.white) // 背景色（可选）
                         .overlay(
                             VStack {
                                 Spacer()
                                 Rectangle()
                                     .frame(height: 1)
                                     .foregroundColor(.gray) // 分割线颜色
                             }
                         )
                         .textFieldStyle(PlainTextFieldStyle()) // 隐藏边框
                         .padding(.horizontal, 30)
                         .padding(.bottom,30)
                     Text("密码")
                         .font(.system(size: 15))
                         .opacity(0.6)
                         .padding(.horizontal,30)
                         .frame(width: UIScreen.main.bounds.width, alignment: .leading)
                     SecureField("请输入密码", text: $password)
                         .padding(5)
                         .background(Color.white) // 背景色（可选）
                         .overlay(
                             VStack {
                                 Spacer()
                                 Rectangle()
                                     .frame(height: 1)
                                     .foregroundColor(.gray) // 分割线颜色
                             }
                         )
                         .textFieldStyle(PlainTextFieldStyle()) // 隐藏边框
                         .padding(.horizontal, 30)
                         .padding(.bottom,100)
                     
                     if let errorMessage = errorMessage {
                         Text(errorMessage)
                             .foregroundColor(.red)
                             .padding()
                     }
                     
                     Button(action: {
                         login()
                     }) {
                         Text("登录")
                             .font(Font.custom("SF Pro", size: 20))
                             .foregroundColor(.white)
                             .frame(maxWidth: .infinity, minHeight: 66)
                             .background(Color.sub)
                             .cornerRadius(33)
                             .shadow(radius: 10)
                             .padding(.bottom,50)
                     }
                     .disabled(isupload)
                     .padding()
                     
                     .navigationDestination(isPresented: $tochildrenView) {
                         HomeView()
                             .environmentObject(timerManager)
                             .environmentObject(globalSettings)
                     }
                     .navigationDestination(isPresented: $toOnboardingView) {
                         ChildrenOrParent()
                     }
                 }
                 .padding()
             }
             .onAppear(perform: authManager.clearCredentials)

         }
     }

    private func login() {
        isupload = true
        // 使用 AuthManager 进行登录
        checkFolderExists(folderName: "\(phoneNumber)"+"_\(password)") { exists in
            print(exists)
            if exists{
                authManager.saveCredentials(phoneNumber: phoneNumber, password: password)
                let objectKey = "\(phoneNumber)"+"_\(password)/"+"userdata/"+"stories.json"
                stories.downloadStoriesFromOSS(objectKey: objectKey) { stories in
                    if let stories = stories {
                        // 使用下载的 stories 对象
                        stories.save()
                        print("Successfully loaded stories: \(stories)")
                        tochildrenView = true
                    } else {
                        print("Failed to load stories")
                    }
                }
            }else{
                authManager.saveCredentials(phoneNumber: phoneNumber, password: password)
                createFolder(folderName: "\(phoneNumber)"+"_\(password)")
                toOnboardingView = true
                
            }
        }
    }
    private func createFolder(folderName: String) {
        let folderPath = folderName.trimmingCharacters(in: .whitespacesAndNewlines) + "/" // 末尾加上斜杠
        let urlString = "https://\(bucketName).\(endpoint)/\(folderPath)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        // 设置 Content-Type 请求头
        request.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        // 创建空的 Data 对象
        request.httpBody = Data()

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to create folder: \(error)")
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Folder created successfully.")
            } else {
                print("Unexpected response or failed to create folder.")
            }
        }
        task.resume()
    }
    func checkFolderExists(folderName: String, completion: @escaping (Bool) -> Void) {
        let folderPath = folderName.trimmingCharacters(in: .whitespacesAndNewlines) + "/"
        let urlString = "https://\(bucketName).\(endpoint)/?prefix=\(folderPath)&delimiter=/"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to check folder existence: \(error)")
                completion(false)
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let data = data, let xml = String(data: data, encoding: .utf8) {
                    // 解析 XML 数据
                    let exists = xml.contains("<Contents>")
                    completion(exists)
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
        task.resume()
    }
}


#Preview {
    LoginView()
        .environmentObject(TimerManager())
        .environmentObject(GlobalSettings())
}
