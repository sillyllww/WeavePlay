//
//  Readview.swift
//  WeavePlay
//
//  Created by 李龙 on 2024/7/21.
//

import SwiftUI
import UIKit
import AVFoundation

struct Readview: View {
    @State private var viewSize: CGSize = .zero
    @Binding var selectedStory: Story?
    @Binding var stories: Stories
    @State private var location: [Int] = [1, 1]
    @State private var startdialog :Bool = false
    @State private var showbottom : Bool = false
    @State private var navigateToMainView = false // 控制导航的状态
    @State private var text:[String] = [NSLocalizedString("故事开端", comment: ""),NSLocalizedString("故事发展", comment: ""),NSLocalizedString("故事冲突", comment: ""),NSLocalizedString("故事转折", comment: ""),NSLocalizedString("故事高潮", comment: ""),NSLocalizedString("故事结局", comment: "")]
    @State private var backTOchildren :Bool = false
    @State private var width = UIScreen.main.bounds.height
    @State private var height = UIScreen.main.bounds.width
    @State private var finished: Bool = false
    @State private var showDetails = false
    let synthesizer = AVSpeechSynthesizer()
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Image("back_image")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .offset(x: 0, y: 0) // 调整x和y的值来平移图片位置
                    .ignoresSafeArea(.all)
                    .scaleEffect(1.009)
                VStack{
                    HStack {
                        

                        ZStack{
                            Image("story_side")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.25)
                                .padding(.top,40)
                            VStack{
                                HStack{
                                
                                    Button(action: { backTOchildren = true }) {
                                        Image("BackToChildren")
                                            .padding()
                                        Spacer()
                                    }
                                    
                                }
                                VStack(alignment: .leading) {
                                    if let matchedPlot = selectedStory?.plots.plots.first(where: { $0.location == location }) {
//                                        Text(text[(matchedPlot.location[1])-1])
//                                            .font(.headline)
//                                            .foregroundStyle(Color.white)
//                                            .frame(width: 125, height: 23)
//                                            .background(Color.sub)
//                                            .cornerRadius(20)
//                                            .padding(.horizontal)
//                                        
                                        ScrollView {
                                            Text(matchedPlot.storyText)
                                               // .font(.custom("FZFENSTXJW--GB1-0", size: 15))
                                                .font(.custom("FZMWJW--GB1-0", size: 17))
                                                .padding(.horizontal)
                                                .frame(width: 150)
                                                .padding(.top,5)
                                        }
                                        .frame(height: 170)
                                        
                                        Spacer()
                                        
                                        HStack {
                                            Spacer()
                                            
                                            Button(action: {
                                                let utterance = AVSpeechUtterance(string: matchedPlot.storyText)
                                                utterance.rate = AVSpeechUtteranceDefaultSpeechRate
                                                utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_Yu-shu_zh-CN_compact")
                                                synthesizer.speak(utterance)
                                            }) {
                                                Image(systemName: "speaker.wave.2.fill")
                                                    .foregroundColor(.main)
                                                    .frame(width: 35, height: 35)
                                                    .background(Color.white)
                                                    .cornerRadius(15)
                                                    .padding()
                                            }
                                        }
                                    }
                                }
                                .frame(width: 160, height: 250)
                                Spacer()
                    
                            }

                        }
                        Spacer()
                        
//                        VStack {
//                            Spacer()
//                            

//
//                            ZStack {

//                                
//                                Image("bear_sit")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .scaleEffect(x: -1, y: 1, anchor: .center)
//                                    .frame(width: 120, height: 142)
//                            
//                                    .padding(.trailing, 60)
//                            }
//                            
//                            Spacer()
//                        }
                        VStack{
                            Spacer()
                            ZStack {
                                
                                Image("book_read")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geometry.size.width * 0.8 )
                                    .offset(x:0,y: 20)
                                ZStack {
                                    if let matchedPlot = selectedStory?.plots.plots.first(where: { $0.location == location }) {
                                        AsyncImage(url: matchedPlot.imageUrl) { image in
                                                image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width:showDetails ? geometry.size.width * 1 : geometry.size.width * 0.69, height:showDetails ? geometry.size.height * 1 : geometry.size.height * 0.79)
                                                .blur(radius: showDetails ? 3:0)
                                        } placeholder: {
                                            Text("图片加载中")
                                                .font(.title)
                                                .foregroundStyle(Color.gray.opacity(0.5))
                                        }
                                    } else {
                                        Text("Failed to load image")
                                            .foregroundColor(.red)
                                    }
                                    
                                    CharacterDialogView(location: $location, selectedStory: $selectedStory, stories: $stories, showbottom: $showbottom, backTOchildren: $backTOchildren, showDetails: $showDetails, finished: $finished)
                                        .frame(width: geometry.size.width * 0.69, height: geometry.size.height * 0.79)
                                }
                                .frame(width: geometry.size.width * 0.69, height: geometry.size.height * 0.79)
                                .cornerRadius(15)
                                .clipped()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white, lineWidth: 4) // 使用 .overlay 添加圆角边框
                                )
                                .offset(x:0,y: -10)

                                HStack{
                                    VStack{
                                        ZStack{
                                            Image("book_side")
                                            Text(selectedStory!.title)
                                                .font(.custom("FZFENSTXJW--GB1-0", size: 20))
                                                .foregroundStyle(Color.white)
                                                .padding(.bottom,2)
                                        }
                                        .padding(.top,40)
                                        .padding(.leading)
                                        Spacer()
                                    }
                                    Spacer()
                                }
                                
                            }
                            .frame(width: geometry.size.width * 0.75, height: geometry.size.height * 0.8)
                            
                            Spacer()
                        }

                       
                    }
                    
                }
                .onAppear {
                    width = geometry.size.height
                    height = geometry.size.width
                    AppDelegate.orientationLock = .landscapeLeft
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        windowScene.windows.first?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .ignoresSafeArea() // Ignore safe area for the TabView
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true) // 隐藏导航栏
            .navigationDestination(isPresented: $backTOchildren) {
                HomeView()
            }
            if finished {
                Color.black.opacity(0.5) // 背景变暗
                    .edgesIgnoringSafeArea(.all)
                Image("finished")
                HStack{
                    LottieView(animationName: "Animation - 1726121039757", loopMode: .loop, animationSpeed: 0.5)
                        .offset(x:70)
                    LottieView(animationName: "Animation - 1726121039757", loopMode: .loop, animationSpeed: 0.5)
                        .offset(x:-70)
                }
                
            }
        }
        
    }
}

struct CharacterDialogView: View {
    @State private var viewSize: CGSize = .zero
    @Binding var location: [Int]  // 使用 @Binding 绑定 location
    @State private var currentIndex: Int = 0
    @Binding var selectedStory: Story?
    @Binding var stories: Stories
    @Binding var showbottom : Bool
    @Binding var backTOchildren :Bool
    @State private var showselect : Bool = false
    @State private var showImage = true
    @Binding var showDetails :Bool
    @State private var isAnimating = false
    @Binding var finished :Bool
    @State private var showpick : Bool = false //收集节目
    @State private var showshake : Bool = false //传感器互动节目
    @State private var isshowpick : Bool = false //收集节目
    @State private var isshowshake : Bool = false //传感器互动节目
    @State private var buttonPositions: [(x: CGFloat, y: CGFloat)] = [
        (400, 80), (480, 180), (150, 220), (370, 200), (100, 120)
    ]
    @State private var collectedCount = 0
    @State private var showpickAlert = false
    @StateObject private var shakeDetector = ShakeDetector()
        
    let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        GeometryReader { geometry in
            if let matchedPlot = selectedStory?.plots.plots.first(where: { $0.location == location }) {
                ZStack {
                    VStack{
                        Spacer()
                        HStack {
                            Spacer()
                            if showDetails {
                                VStack {
                                    Spacer()
                                    HStack {
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Text(matchedPlot.dialog[currentIndex])
                                                    .font(.custom("FZMWJW--GB1-0", size: 20))
                                                    .padding(.leading)
                                                    .padding(.vertical, 10)
                                                    .frame(maxWidth: 300, maxHeight: 90)
                                                
                                                Spacer()
                                                Button(action: {
                                                    let utterance = AVSpeechUtterance(string: matchedPlot.dialog[currentIndex])
                                                    utterance.rate = AVSpeechUtteranceDefaultSpeechRate
                                                    utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_Yu-shu_zh-CN_compact")
                                                    synthesizer.speak(utterance)
                                                }) {
                                                    Image(systemName: "speaker.wave.2.fill")
                                                        .foregroundColor(.main)
                                                        .frame(width: 30, height: 30)
                                                        .background(Color.light)
                                                        .cornerRadius(15)
                                                        .padding(.trailing)
                                                }
                                            }
                                        }
                                        .background(Color.white)
                                        .cornerRadius(23)
                                        .shadow(radius: 10)
                                        .opacity(0.8)
                                        
                                        ZStack {
                                            Image(systemName: "triangle.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(.white)
                                                .opacity(0.5)
                                                .rotationEffect(.degrees(210))
                                            Image(systemName: "triangle")
                                                .font(.system(size: 20))
                                                .foregroundColor(.white)
                                                .rotationEffect(.degrees(210))
                                        }
                                    }
                                    HStack {
                                        Text(matchedPlot.characters[currentIndex])
                                            .font(.caption)
                                            .padding(.horizontal)
                                            .background(Color.white.opacity(0.5))
                                            .cornerRadius(10)
                                            .padding(.horizontal)
                                        Spacer()
                                    }
                                }
                                .fixedSize(horizontal: true, vertical: true)
                                .transition(.opacity)
                                .padding(.leading)
                                .padding(.trailing,-60)
                            }
                            
                            Button(action: {
                                let utterance = AVSpeechUtterance(string: matchedPlot.dialog[currentIndex])
                                utterance.rate = AVSpeechUtteranceDefaultSpeechRate
                                utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_Yu-shu_zh-CN_compact")
                                
                                
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.3, blendDuration: 0.2)) {
                                    isAnimating.toggle()
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation(.easeInOut(duration: 1.0)) {
                                        showDetails.toggle()
                                        if showDetails{
                                            synthesizer.speak(utterance)//如果显示人物特写才会说话
                                        }
                                    }
                                    
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.3, blendDuration: 0.2)) {
                                        isAnimating.toggle()
                                    }
                                }
                                
                            }) {
                                if showImage {
                                    ZStack {
                                        VStack{
                                            Spacer()
                                            Ellipse()
                                                .fill(Color.black.opacity(0.6))
                                                .frame(width: 100,height: 30)
                                                .blur(radius: 10)
                                                
                                        }
                                        let currentCharacter = matchedPlot.characters[currentIndex]
                                        // 使用 contains 逻辑进行部分匹配
                                        if let characterIndex = selectedStory?.allcharacters.firstIndex(where: { $0.contains(currentCharacter) || currentCharacter.contains($0) }),
                                           let imageUrl = selectedStory?.allcharacterUrls[characterIndex] {
                                           
                                            AsyncImage(url: imageUrl) { phase in
                                                switch phase {
                                                case .empty:
                                                    Text("人物加载中")
                                                        .frame(width: 180, height: 300)
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: showDetails ? 360 : 180, height: showDetails ? 600 : 300)
                                                    
                                                case .failure:
                                                    Text("Failed to load image")
                                                        .frame(width: 180, height: 300)
                                                    
                                                @unknown default:
                                                    Text("Unexpected error")
                                                        .frame(width: 180, height: 300)
                                                }
                                            }
                                            
                                        } else {
                                            Text("No image available")
                                                .frame(width: 180, height: 300)
                                        }

                                    }
                                    .frame(width: showDetails ? 200 :180, height: showDetails ? 600:300)
                                    .padding(.top, showDetails ? 200: 0)
                                }

                            }
                            .scaleEffect(isAnimating ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.3, blendDuration: 0.2), value: isAnimating)
                            Spacer()
                        }
                        Spacer()
                    }
                    .frame(width: viewSize.width,height: viewSize.height)
                    if showselect {
                        ZStack {
                            RoundedRectangle(cornerRadius: 30)
                                .frame(width: 390, height: 250)
                                .foregroundColor(.main)
                                .blur(radius: 30)
                            
                            RoundedRectangle(cornerRadius: 30)
                                .frame(width: 320, height: 180)
                                .foregroundColor(.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.white, lineWidth: 3)
                                )
                            VStack {
                                HStack {
                                    Image("?")
                                        .scaleEffect(0.5)
                                    Text("故事接下来该怎么发展")
                                        .font(.title2)
                                        .foregroundStyle(Color.white)
                                }
                                Button(action: {
                                    location[1] += 1
                                    showselect = false
                                }) {
                                    Text("方向一")
                                        .frame(width: 178, height: 41)
                                        .background(Color.sub)
                                        .foregroundColor(Color.white)
                                        .cornerRadius(20)
                                }
                                Button(action: {
                                    if let nextPlot = selectedStory?.plots.plots.first(where: { $0.location[1] == location[1] + 1 }) {
                                        location[0] = nextPlot.isturn[0]
                                        print(nextPlot.isturn[0])
                                    }
                                    location[1] += 1
                                    showselect = false
                                }) {
                                    Text("方向二")
                                        .frame(width: 178, height: 41)
                                        .background(Color.sub)
                                        .foregroundColor(Color.white)
                                        .cornerRadius(20)
                                }
                            }
                        }
                    }
                    VStack {
                        Spacer()
                        HStack {
                            if location[1] != 1 {
                                Button(action: {
                                    if currentIndex == 0 {
                                        location[1] -= 1
                                        currentIndex = 0
                                    } else {
                                        currentIndex = (currentIndex - 1) % matchedPlot.characters.count
                                    }
                                }) {
                                    Image("next_btn")
                                        .scaleEffect(x: -1, y: 1, anchor: .center)
                                        .padding(20)
                                }
                               

                            }
                            Spacer()
                            if !showshake && !showpick {
                                Button(action: {
                                    showDetails = false
                                    showImage = false
                                    if let matchedPlot = selectedStory?.plots.plots.first(where: { $0.location == location }) {
                                        if let nextPlot = selectedStory?.plots.plots.first(where: { $0.location[1] == location[1] + 1 }) {
                                            if currentIndex == matchedPlot.characters.count - 1 {
                                                if nextPlot.isturn.indices.contains(0) {
                                                    let value = nextPlot.isturn[0]
                                                    if value >= 1 {
                                                        showselect = true
                                                    }
                                                } else {
                                                    if location[1] == 6 {
                                                        finished = true
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                                            
                                                            finished = false
                                                            location = [1,1]
                                                            backTOchildren = true
                                                        }
                                                    }
                                                    if location[1] == 2{
                                                        isshowpick = true
                                                        showpick = true
                                                    }
                                                    if location[1] == 3{
                                                        isshowshake = true
                                                        showshake = true
                                                    }
                                                    if !isshowpick{
                                                        location[1] += 1
                                                        currentIndex = 0
                                                    }

                                                }
                                            } else {
                                                currentIndex = (currentIndex + 1) % matchedPlot.characters.count
                                            }
                                        } else {
                                            finished = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                                
                                                finished = false
                                                location = [1,1]
                                                backTOchildren = true
                                            }
                                        }
                                    }
                                    withAnimation(.easeInOut(duration: 3.0)) {
                                        showImage = true
                                    }
                                }) {
                                    Image("next_btn")
                                        .padding(20)
                                }
           
                            }

                        }
                    }
                    if showpick{
                        VStack{
                            Spacer()
                            Text("请帮助主角收集画面中的蝴蝶")
                                .padding(.bottom,30)
                        }
                    }
                    if showshake{
                        VStack{
                            Spacer()
                            Text("请晃动手机帮主角脱困")
                                .padding(.bottom,30)
                        }
                        if shakeDetector.isShaken {
                            Text("Device shaken!")
                                .onAppear(){
                                    location[1] += 1
                                    showshake = false
                                    isshowshake = false
                                }
                        }
                    }
                    if isshowpick {
                        ForEach(0..<buttonPositions.count, id: \.self) { index in
                            Button(action: {
                            moveButtonToOrigin(index: index)
                            }) {
                                Text("蝴蝶 \(index + 1)")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .position(x: buttonPositions[index].x, y: buttonPositions[index].y)
                        }
                    }
  
                }
                .frame(width: viewSize.width,height: viewSize.height)
                .onAppear {
                    viewSize = geometry.size
                    AppDelegate.orientationLock = .landscapeLeft
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        windowScene.windows.first?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                    }
                }

            }
        }
    }
    private func moveButtonToOrigin(index: Int) {
            // 将按钮移动到 (0, 0) 位置
            buttonPositions[index] = (700, 0)
            collectedCount += 1

            // 检查是否所有按钮都已收集
            if collectedCount == buttonPositions.count {
                showpickAlert = true
                showpick = false
                isshowpick = false
                location[1] += 1
            }
        }
}
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct SizeReaderModifier: ViewModifier {
    let onSizeChange: (CGSize) -> Void

    func body(content: Content) -> some View {
        content
            .background(GeometryReader { geometry in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometry.size)
            })
            .onPreferenceChange(SizePreferenceKey.self, perform: onSizeChange)
    }
}

extension View {
    func onSizeChange(perform: @escaping (CGSize) -> Void) -> some View {
        self.modifier(SizeReaderModifier(onSizeChange: perform))
    }
}

#Preview {
    Readview(selectedStory: .constant(Story(id: UUID(), title: "示例故事", characters: Characters(), scene: "",plots: Plots(plots: [Plot(storyText: "这是故事的简介，这是故事的简介，这是故事的简介，这是故事的简介，这是故事的简介，这是故事的简介，这是故事的简介，这是故事的简介，这是故事的简介，这是故事的简介，这是故事的简介，这是故事的简介，这是故事的简介", imageUrl: URL(string: "https://th.bing.com/th/id/R.d07816d313cad5d2b53b30192443c4c5?rik=SUozltQgAs8%2bNQ&riu=http%3a%2f%2fn.sinaimg.cn%2fsinacn10119%2f600%2fw1920h1080%2f20190325%2f6449-hutwezf3366892.jpg&ehk=DH2hT8Ey9e3gfn%2fUBKrQFjRb3LPXUs9sEIOq4LRDZfQ%3d&risl=&pid=ImgRaw&r=0")!, characterUrls: [], characters: ["公主","王子"], location: [1,1], dialog: ["这是故事内容，这是故事内容，这是故事内容，这是故事内容，这是故事内容，这是故事内容，这是故事内容，这是故事内容，这是故事内容，这是故事内容，这是故事内容，这是故事内容，这是故事内容，这是故事内容，这是故事内容，","这是故事内容，这是故事内容，这是故事内容，这是故事内容，这是故事内容，这是故事内容，这是故事内容，这是故事内容，这是故事内容，这是故事内容，这是故事内容，这是故事内容，这是故事内容，这是故事内容，这是故事内容，"], isturn: [], turninfo: [], plotchose: [], plotchoseindex: 1, promotechara: [], promote: "")]) , plot1:"", plot2: "", plot3: "", topic: [], storyintro: "", storyimage: [],  finished: false,allcharacterUrls:[URL(string: "https://png.pngtree.com/png-clipart/20230221/original/pngtree-beautiful-girl-png-image_8961324.png")!,URL(string: "https://img.shetu66.com/2023/06/19/1687143044235244.png")!], allcharacters: ["公主","王子"])), stories: .constant(Stories()))
}
