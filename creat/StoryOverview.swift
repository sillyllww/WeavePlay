//
//  StoryOverview.swift
//  WeavePlay
//
//  Created by 李龙 on 2024/7/17.
//
import Combine
import SwiftUI

struct StoryOverview: View {
    @ObservedObject var chatBot: ChatBot
    @Binding var selectedStory: Story?
    @Binding var stories: Stories
    let titles = [NSLocalizedString("城堡", comment: ""), NSLocalizedString("森林", comment: ""), NSLocalizedString("村庄", comment: ""), NSLocalizedString("海洋", comment: ""), NSLocalizedString("沙漠", comment: ""), NSLocalizedString("雪山", comment: "")]
    @State private var navigateToSelectman = false // 添加状态变量以控制导航
    @State private var cancellables = Set<AnyCancellable>()
    let generator = ImageGenerator()
    @State private var startgen: Bool = false
    @State private var rotationAngle: Double = 0
    @State private var gennumber: Int = 0
    @State private var totalnumber: Int = 0
    @State private var appearance:String  = "黑色头发"
    @State private var initImage:String = ""
    let characterTypes = [NSLocalizedString("王子", comment: ""), NSLocalizedString("公主", comment: ""), NSLocalizedString("皇后", comment: ""), NSLocalizedString("国王", comment: ""), NSLocalizedString("平民", comment: ""), NSLocalizedString("骑士", comment: "")]
    let bucketName = "fc-sd-62aafe39g"
    let endpoint = "oss-cn-hangzhou.aliyuncs.com"
    let charaImage = ["civilian","king","knight","prince","princess","queen",]
    let plotImage = ["castle","desert","forest","ocean","snow","village",]
    @State private var objectname:String = ""
    var body: some View {
        let indices = selectedStory!.findCharacterIndices()
        ZStack{
            // 背景图片
            Image("back_image")
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .offset(x: 0, y: 0) // 调整x和y的值来平移图片位置
                .ignoresSafeArea(.all)
                .scaleEffect(1.009)
            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.0), Color.background.opacity(1)]),
                           startPoint: UnitPoint(x: 0.5, y: 0.2), endPoint: UnitPoint(x: 0.5, y: 0.6))
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .ignoresSafeArea(.all)
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.6)) // 透明颜色
                .frame(width: UIScreen.main.bounds.width * 0.95, height: 775) // 调整宽度和高度
                .padding(.top,55)
            VStack{
                Spacer(minLength: 135)
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.main)
                        .frame(width: 200, height: 20)
                        .offset(x: -200, y: 0) // 偏移图片的位置
                    Text(NSLocalizedString("正派角色", comment: ""))
                        .font(.headline)
                        .foregroundColor(.white)
                        .offset(x: -140, y: 0)
                }
                    .frame(width: 371,height: 20)
                    .clipped()
                TabView {
                    // 显示 persontype 为 0 的角色
                    ForEach(indices.goodpersonIndices, id: \.self) { index in
                        singleCharacterView(maincharacter: selectedStory!.characters.characters[index])
                            .tabItem {
                                Text("Good Person")
                            }
                    }
                    // 显示 persontype 为 1 的角色
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(width: UIScreen.main.bounds.width * 0.9,height: 150)
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.main)
                        .frame(width: 200, height: 20)
                        .offset(x: -200, y: 0) // 偏移图片的位置
                    Text(NSLocalizedString("反派角色", comment: ""))
                        .font(.headline)
                        .foregroundColor(.white)
                        .offset(x: -140, y: 0)
                }
                    .frame(width: 371,height: 20)
                    .clipped()
                if indices.badpersonIndices.isEmpty {
                     // 如果 indices.badpersonIndices 为空，则显示默认文本
                     Text("不存在坏角色哦")
                        .foregroundStyle(Color.light)
                        .font(.title2)
                        .frame(width: UIScreen.main.bounds.width * 0.9,height: 150)
                        .background(Color.white)
                        .cornerRadius(20)
                 } else {
                     // 否则显示 TabView
                     TabView {
                         ForEach(indices.badpersonIndices, id: \.self) { index in
                             if let character = selectedStory?.characters.characters[index] {
                                 singleCharacterView(maincharacter: character)
                                     .tabItem {
                                         Text("Bad Person")
                                     }
                             } else {
                                 // 处理索引超出范围的情况
                                 Text("角色不存在")
                             }
                         }
                     }
                     .frame(width: UIScreen.main.bounds.width * 0.9,height: 150)
                     .tabViewStyle(PageTabViewStyle())
                 }

                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.main)
                        .frame(width: 200, height: 20)
                        .offset(x: -200, y: 0) // 偏移图片的位置
                    Text(NSLocalizedString("故事", comment: ""))
                        .font(.headline)
                        .foregroundColor(.white)
                        .offset(x: -150, y: 0)
                }
                    .frame(width: 371,height: 35)
                    .clipped()
                  

                HStack{
                    if let plots = selectedStory?.plots.plots, !plots.isEmpty {
                         TabView {
                             ForEach(plots) { plot in
                                 ZStack{
                                     VStack {
                                         ScrollView{
                                             Text("\(plot.storyText)")
                                                 .font(.caption)
                                         }
                                             .padding(10)
                                     }
                                     Text("路线\(plot.location[0]) 情节\(plot.location[1])")
                                         .font(.caption)
                                         .foregroundStyle(Color.main)
                                         .padding(.horizontal)
                                         .background(Color.light)
                                         .cornerRadius(30)
                                         .padding()
                                         .frame(width: UIScreen.main.bounds.width * 0.90,height: 90,alignment: .bottomTrailing)
                                 }
                             }
                         }
                         .tabViewStyle(PageTabViewStyle())
                        
                     } else {
                         ZStack{
                             VStack {
                                 ScrollView{
                                     Text("")
                                         .font(.caption)
                                 }
                                     .padding(10)
                             }
                             
                             Text("5145")
                                 .font(.caption)
                                 .foregroundStyle(Color.main)
                                 .padding(.horizontal)
                                 .background(Color.light)
                                 .cornerRadius(30)
                                 .padding()
                                 .frame(width: UIScreen.main.bounds.width * 0.90,height: 90,alignment: .bottomTrailing)
                         }
                     }
                    
                 }
                .frame(width: UIScreen.main.bounds.width * 0.90,height: 90)
                .background(Color.white)
                .cornerRadius(20)
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.main)
                        .frame(width: 200, height: 20)
                        .offset(x: -200, y: 0) // 偏移图片的位置
                    Text(NSLocalizedString("故事简介", comment: ""))
                        .font(.headline)
                        .foregroundColor(.white)
                        .offset(x: -140, y: 0)
                }
                    .frame(width: 371,height: 35)
                    .clipped()
                ZStack{
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.light1, lineWidth: 5)
                    ScrollView{
                        Text("\(selectedStory!.storyintro)")
                            .font(.caption)
                    }
                    .padding(10)
                }
                .frame(width: 356,height: 70)
                .background(.white)
                .cornerRadius(20)
                Spacer(minLength: 180)
            }
            .frame(width: UIScreen.main.bounds.width * 0.95)
            .clipped()

            VStack{
                Spacer()
                Button(NSLocalizedString("开始生成绘本故事", comment: "")) {
                    processStoryPlots(selectedStory!)
                }
                .font(Font.custom("SF Pro", size: 20))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 66)
                .background(Color.sub)
                .cornerRadius(33)
                .padding(.horizontal)
                .shadow(radius: 10)
                .padding(.bottom,50)
            }
            .frame(width: UIScreen.main.bounds.width,height:UIScreen.main.bounds.height)
            if startgen{
                BlurView(style: .systemMaterial)
                    .edgesIgnoringSafeArea(.all)
                ZStack {
                    LottieView(animationName: "Animation - 1726121455984", loopMode: .loop, animationSpeed: 0.5)
                        .padding(.bottom,30)
                    VStack{
                        Spacer()
                        
                        Text(
                            String(
                                format: NSLocalizedString("generating_story_progress_template", comment: ""),
                                "\(gennumber)/\(totalnumber)"
                            )
                        )
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.main.opacity(0.7))
                            .padding(.top,250)
                        Spacer()
                    }
                    

                }
            }
        }
        .navigationDestination(isPresented: $navigateToSelectman) {
            Readview( selectedStory: $selectedStory, stories: $stories) // 导航到 selectman 界面
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack{
                    CustomBackButton()
                    Text("故事概览")
                        .font(.title2)
                        .foregroundColor(.white)
                        
                }
            }
           
        }

    }
    func findIndex(of content: String, in plotImages: [String]) -> Int? {
        for (index, plotImage) in plotImages.enumerated() {
            if content.contains(plotImage) {
                return index
            }
        }
        return nil
    }
    
    private func uploadImage(fileURL: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "https://\(bucketName).\(endpoint)/\(objectname)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.uploadTask(with: request, fromFile: fileURL) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error)) // Pass the error to the completion handler
                } else {
                    completion(.success(())) // Pass success to the completion handler
                }
            }
        }
        
        task.resume()
    }
    func processStoryPlots(_ story: Story) {
        startgen = true
        totalnumber = (selectedStory?.allcharacters.count ?? 0) + (selectedStory?.plots.plots.count ?? 0)
        let dispatchGroup = DispatchGroup()
        let plots = story.plots.plots
        func processPlot(at index: Int) {
            guard index < plots.count else {
                dispatchGroup.notify(queue: .main) {
                    print("所有图片生成和背景移除任务已经完成,接下来执行生成角色")
                    processCharacter(at: 0)
                    // 在这里执行需要等待所有异步操作完成后的代码
                }
                return
            }

            let plot = plots[index]
            let sendtext = String(
                format: NSLocalizedString("generate_environment_prompt_template", comment: ""),
                plot.storyText
            )
            dispatchGroup.enter() // 进入 DispatchGroup
            print("Entered DispatchGroup for plot index \(index)")
            chatBot.answer(sendtext, for: story.id) { result in
                switch result {
                case .success(let content):
                    print("Generated content: \(content)")
                    let imagename = "background\(index)"
                    // 生成图像的异步任务
                    //提取适合的图片
                    if let index = findIndex(of: content, in: plotImage) {
                        print("Found plot image at index \(plotImage[index])")
                        initImage = "https://fc-sd-62aafe39g.oss-cn-hangzhou.aliyuncs.com/PlotImage/\(plotImage[index]).png"
                    } else {
                        print("没有发现出现的场景")
                        initImage = "https://fc-sd-62aafe39g.oss-cn-hangzhou.aliyuncs.com/PlotImage/castle.png"
                    }
                    self.generator.generateImage(
                        initImage: initImage, // 传入初始图像
                        prompt: "\(content),<lora:COOLKIDS_MERGE_V2.5:1>,high quality",
                        denoisingStrength: 0.65, // 如果没有负面提示可以留空
                        numSteps: 30, // 适当设置
                        cfgScale: 6.5,
                        negativePrompt: "", // 适当设置
                        width: 1278,
                        height: 650,
                        imageName: imagename
                        
                    ) { result in
                        // 处理结果的逻辑
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let imageURL):
                                print("Image URL: \(imageURL)")
                                // 在图像生成完成后继续处理逻辑
                                print("完成生成第\(index)张图片")
                                let authManager = AuthManager()
                                let credentials = authManager.getCredentials()
                                if let phoneNumber = credentials.phoneNumber, let password = credentials.password {
                                    objectname = "\(phoneNumber)"+"_\(password)" + "/"+"\(selectedStory?.title ?? "")" + "/"+"PlotImage/"+"plot\(index).png"
                                    selectedStory!.plots.plots[index].imageUrl = URL(string: "https://fc-sd-62aafe39g.oss-cn-hangzhou.aliyuncs.com/"+objectname)!
                                } else {
                                    print("No credentials found.")
                                }
                                uploadImage(fileURL: imageURL) { result in
                                    switch result {
                                    case .success:
                                        // 上传成功后的操作
                                        saveSelectedStory()
                                        dispatchGroup.leave() // 操作成功后离开 DispatchGroup
                                        print("Left DispatchGroup for plot index \(index) after image generation")
                                        // 递归调用下一个 plot
                                        processPlot(at: index + 1)
                                        gennumber += 1
                                        print("Upload succeeded")
                                    case .failure(let error):
                                        // 上传失败后的操作
                                        print("Upload failed: \(error.localizedDescription)")
                                    }
                                }
                            case .failure(let error):
                                print("Failed to generate images: \(error)")
                                dispatchGroup.leave() // 即使失败，也要离开 DispatchGroup，防止阻塞
                                print("Left DispatchGroup for plot index \(index) after image generation failure")
                                
                                // 递归调用下一个 plot，即使失败也继续
                                processPlot(at: index + 1)
                            }
                        }
                    }
                    
                case .failure(let error):
                    print("Failed to generate content: \(error.localizedDescription)")
                    dispatchGroup.leave() // 出错时也要调用 leave
                    print("Left DispatchGroup for plot index \(index) after content generation failure")
                    
                    // 递归调用下一个 plot，即使失败也继续
                    processPlot(at: index + 1)
                }
            }
        }
        // 开始处理第一个 plot
        processPlot(at: 0)
        selectedStory?.allcharacters =  uniqueCharacters(from: story)
        totalnumber = (selectedStory?.allcharacters.count ?? 0) + (selectedStory?.plots.plots.count ?? 0)
        func processCharacter(at index: Int) {
            guard index < (selectedStory?.allcharacters.count)! else {
                dispatchGroup.notify(queue: .main) {
                    print("所有图片生成和背景移除任务已经完成")
                    selectedStory?.finished = true
                    selectedStory?.main_image = (selectedStory?.allcharacterUrls[0])!
                    saveSelectedStory()
                    //储存数据
                    let authManager = AuthManager()
                    let credentials = authManager.getCredentials()
                    if let phoneNumber = credentials.phoneNumber, let password = credentials.password {
                        let objectKey = "\(phoneNumber)"+"_\(password)"  + "/"+"userdata/"+"stories.json"
                        stories.uploadStoriesToOSS(stories: stories, objectKey: objectKey)
                        print(objectKey)
                    } else {
                        print("No credentials found.")
                    }
                    navigateToSelectman = true
                }
                return
            }

            // 遍历 selectedStory?.characters.characters 数组的所有索引
            for character in selectedStory?.characters.characters ?? [] {
                // 构建 currentCharacter 的名字和角色类型组合
                // 判断 allCharacters 是否包含当前角色的名字和角色类型
                let chara01 = selectedStory?.allcharacters[index]
                if chara01!.lowercased().contains(character.name.lowercased()) {
                    // 如果存在，返回该角色的 hobby
                    appearance = character.hobby
                    print("匹配到的角色爱好是：\(appearance)")
                } else {
                    // 如果不存在，返回空字符串
                    appearance = ""
                    print("未匹配到角色，返回空字符")
                }
            }

            let sendtext = String(
                format: NSLocalizedString("character_image_prompt_template", comment: ""),
                selectedStory?.allcharacters[index] ?? "",
                appearance
            )
            dispatchGroup.enter() // 进入 DispatchGroup
            print("Entered DispatchGroup for plot index \(index)")
            chatBot.answer(sendtext, for: story.id) { result in
                switch result {
                case .success(let content):
                    print("Generated content: \(content)")
                    let imagename = "man\(index)"
                    
                    // 生成图像的异步任务
                    if let index = findIndex(of: content, in: charaImage) {
                        print("Found plot image at index \(charaImage[index])")
                        initImage = "https://fc-sd-62aafe39g.oss-cn-hangzhou.aliyuncs.com/CharaImage/\(charaImage[index]).png"
                    } else {
                        print("没有发现出现的人物")
                        initImage = "https://fc-sd-62aafe39g.oss-cn-hangzhou.aliyuncs.com/CharaImage/civilian.png"
                    }
                    
                    self.generator.generateImage(
                        initImage: initImage, // 传入初始图像
                        prompt: "(white background 3),(simple background 3),(solo 5),\(content),<lora:COOLKIDS_MERGE_V2.5:1>,high quality,highres,full shot,(full body 2),high quality,highres,good_eyes",
                        denoisingStrength: 0.55, // 如果没有负面提示可以留空
                        numSteps: 30, // 适当设置
                        cfgScale: 7,
                        negativePrompt: "EasyNegative,ngtv,ngtvb,ngtvH,avoid group shots,skirt,(bad_eyes 3),girls,no backround decorations", // 适当设置
                        width: 400,
                        height: 800,
                        imageName: imagename
                    ) { result in
                        // 处理结果的逻辑
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let imageURL):
                                print("Image URL: \(imageURL)")
                                let backgroundRemovedImage = "man\(index)"
                                self.generator.removeBackground(imageUrl: imageURL, backgroundRemovedImage: backgroundRemovedImage) { removeResult in
                                    DispatchQueue.main.async {
                                        switch removeResult {
                                        case .success(let processedImageURL):
                                            // 将处理后的图像 URL 赋值给 generatedImageurl
                                            print("Background removed successfully.")
                                            print("完成生成第\(index)张图片")
                                            let authManager = AuthManager()
                                            let credentials = authManager.getCredentials()
                                            if let phoneNumber = credentials.phoneNumber, let password = credentials.password {
                                                objectname = "\(phoneNumber)"+"_\(password)" + "/"+"\(selectedStory?.title ?? "")" + "/"+"CharaImage/"+"Chara\(index).png"
                                                selectedStory!.allcharacterUrls.append(URL(string: "https://fc-sd-62aafe39g.oss-cn-hangzhou.aliyuncs.com/"+objectname)!)
                                            } else {
                                                print("No credentials found.")
                                            }
                                            uploadImage(fileURL: processedImageURL) { result in
                                                switch result {
                                                case .success:
                                                    // 上传成功后的操作
                                                    saveSelectedStory()
                                                    // 在图像生成完成后继续处理逻辑
                                                    gennumber += 1
                                                    dispatchGroup.leave() // 操作成功后离开 DispatchGroup
                                                    processCharacter(at: index + 1)
                                                    print("Upload succeeded")
                                                case .failure(let error):
                                                    // 上传失败后的操作
                                                    print("Upload failed: \(error.localizedDescription)")
                                                }
                                            }
                                        case .failure(let error):
                                            print("Failed to remove background: \(error)")
                                        }
                                    }
                                }
                                
 
                            case .failure(let error):
                                print("Failed to generate images: \(error)")
                                dispatchGroup.leave() // 即使失败，也要离开 DispatchGroup，防止阻塞
                                print("Left DispatchGroup for plot index \(index) after image generation failure")
                                // 递归调用下一个 plot，即使失败也继续
                                processCharacter(at: index + 1)
                            }
                        }
                    }
                    
                case .failure(let error):
                    print("Failed to generate content: \(error.localizedDescription)")
                    dispatchGroup.leave() // 出错时也要调用 leave
                    print("Left DispatchGroup for plot index \(index) after content generation failure")
                    
                    // 递归调用下一个 plot，即使失败也继续
                    processCharacter(at: index + 1)
                }
            }
        }
        
    }
    func uniqueCharacters(from story: Story) -> [String] {
        var allCharacters = [String]()
        
        // 遍历故事中的所有 plot 并提取角色
        for plot in story.plots.plots {
            for character in plot.characters {
                allCharacters.append(character)
            }
        }
        
        // 先按照长度从长到短排序，保证较长的字符优先保留
        let sortedCharacters = allCharacters.sorted { $0.count > $1.count }
        
        var uniqueNames: [String] = []
        
        // 去除部分相同的元素，保留最长的
        for character in sortedCharacters {
            if !uniqueNames.contains(where: { character.contains($0) || $0.contains(character) }) {
                uniqueNames.append(character)
            }
        }
        print(uniqueNames)
        return uniqueNames
        
    }
    // 创建一个异步函数来封装图像生成
    func generateImageAsync(
        initImage: String, // 传入初始图像
        prompt: String,
        denoisingStrength: Double,
        numSteps: Int,
        cfgScale: Double,
        negativePrompt: String,
        width: Int,
        height: Int,
        imageName: String
    ) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            generator.generateImage(
                initImage: initImage,
                prompt: prompt,
                denoisingStrength: denoisingStrength,
                numSteps: numSteps,
                cfgScale: cfgScale,
                negativePrompt: negativePrompt,
                width: width,
                height: height,
                imageName: imageName
            ) { result in
                switch result {
                case .success(let imageURL):
                    continuation.resume(returning: imageURL)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    
        private func saveSelectedStory() {
            if let selectedStory = selectedStory {
                if let index = stories.stories.firstIndex(where: { $0.id == selectedStory.id }) {
                    stories.stories[index] = selectedStory
                    stories.save()
                }
            }
        }

}
struct  singleCharacterView: View {
    var maincharacter: Character

    var body: some View {
        ZStack{
            VStack{
                HStack{
                    ZStack{
                        Ellipse()
                            .fill(Color(red: 229/255, green: 230/255, blue: 255/255))
                            .frame(width: 189, height: 189)
                            .offset(x: -60, y: 70) // 偏移图片的位置
                        Ellipse()
                            .fill(Color(red: 173/255, green: 179/255, blue: 255/255))
                            .frame(width: 143, height: 143)
                            .offset(x: -60, y: 70) // 偏移图片的位置
                        Image("category\(maincharacter.classnum)")
                            .resizable()
                            .frame(width: 110, height: 110)
                            .offset(x: 0, y: 30) // 偏移图片的位置
                        
                    }
                    .frame(width: 85, height: 200)
                    .clipped()
                    
                    VStack {
                        HStack {
                            Image("name")
                                .frame(width: 25, height: 25)
                            ZStack {
                                Text(maincharacter.name)
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .foregroundStyle(Color.light1)
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.light1, lineWidth: 2)
                                    .frame(width: 150, height: 25)
                            }
                        }
                        
                        HStack {
                            Image("hobby")
                                .frame(width: 25, height: 25)
                            ZStack {
                                Text(maincharacter.hobby)
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .foregroundStyle(Color.light1)
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.light1, lineWidth: 2)
                                    .frame(width: 150, height: 25)
                            }
                        }
                        
                        HStack {
                            Image("skill")
                                .frame(width: 25, height: 25)
                            ZStack {
                                Text(maincharacter.ability)
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .foregroundStyle(Color.light1)
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.light1, lineWidth: 2)
                                    .frame(width: 150, height: 25)
                            }
                        }
                        
                        HStack {
                            Image("personality")
                                .frame(width: 25, height: 25)
                            
                            ZStack {
                                Text(maincharacter.personality)
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .foregroundStyle(Color.light1)
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.light1, lineWidth: 2)
                                    .frame(width: 150, height: 25)
                            }
                        }
                    }
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 229/255, green: 230/255, blue: 255/255))
                            .frame(width: 100, height: 20)
                            .offset(x: -10, y: -40) // 偏移图片的位置
                        Text(maincharacter.characlass)
                            .font(.headline)
                            .foregroundColor(.main)
                            .offset(x: -18, y: -40)
                    }
                    .frame(width: 20, height: 200)
                }
                .frame(width: 354, height: 145)
                .background()
                .cornerRadius(20)
            }
            if maincharacter.maincharacter{
                Image("main_character2")
                    .offset(x: 16, y:27)
            }
        }
    }
    
}
#Preview {
    StoryOverview(
        chatBot: ChatBot(), selectedStory: .constant(Story(id: UUID(), title: "示例故事", characters: Characters(characters: [Character(name: "王子", characlass: "王子", introduction: "我是一名爱好看书、乐于助人的", hobby: "看书", personality: "乐于助人 乐于助人", ability: "跑得快", classnum: 1, persontype: 0, maincharacter: true, sex: true),Character(name: "王子", characlass: "王子", introduction: "我是一名爱好看书、乐于助人的", hobby: "看书", personality: "乐于助人 乐于助人", ability: "跑得快", classnum: 1, persontype: 0, maincharacter: false, sex: true),Character(name: "王子", characlass: "王子", introduction: "我是一名爱好看书、乐于助人的", hobby: "看书", personality: "乐于助人 乐于助人", ability: "跑得快", classnum: 1, persontype: 1, maincharacter: false, sex: true)]), scene: "城堡", plots: Plots(), plot1: "情节一", plot2: "情节二", plot3: "情节三", topic: [], storyintro: "简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介简介", storyimage: [], finished: false,allcharacterUrls:[], allcharacters: [])),
        stories: .constant(Stories())
    )
}

