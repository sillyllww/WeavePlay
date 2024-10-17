//
//  selectplots.swift
//  WeavePlay
//
//  Created by 李龙 on 2024/8/24.
//

import SwiftUI
import Combine
import Lottie
import Foundation
struct selectplots: View {
    @Binding var selectedStory: Story?
    @Binding var stories: Stories
    @StateObject private var chatBot = ChatBot()
    @State private var rotationAngle: Double = 0
    @State private var cancellables = Set<AnyCancellable>()
    @State private var selectedMarker: [Int] = [1, 1]
    @State private var previousMarker: [Int] = [1, 1] // 用于保存上一个 Marker 的值
    @State private var rightButtonValues = [Int]() // 初始按钮值为空
    @State private var turnmark: [[Int]] = [] // 初始化为空
    @State private var isGenerating = false
    @State private var showgen = false
    @State private var maincharacter:Character? = Character(name: NSLocalizedString("王子", comment: ""), characlass: NSLocalizedString("王子", comment: ""), introduction: NSLocalizedString("我是一名爱好看书、乐于助人的王子", comment: ""), hobby: NSLocalizedString("蓝色的眼睛、红色头发", comment: ""), personality: NSLocalizedString("乐于助人", comment: ""), ability: NSLocalizedString("善于剑术", comment: ""), classnum: 1, persontype: 0, maincharacter: true, sex: true)
    @State private var goodintroductions :String = ""
    @State private var badintroductions :String = ""
    @State private var selectedPerPlot: String = ""
    @State private var prePerPlot: String = ""
    @State private var needregen: Bool = false
    @State private var perplotindex : Int = 0
    @State private var prePerplotindex : Int = 0
    @State private var navigateToStoryOverview = false // 添加状态变量以控制导航
    @State private var plotComplete:Bool = false
    @State private var text:[String] = [NSLocalizedString("故事开端", comment: ""),NSLocalizedString("故事发展", comment: ""),NSLocalizedString("故事冲突", comment: ""),NSLocalizedString("故事转折", comment: ""),NSLocalizedString("故事高潮", comment: ""),NSLocalizedString("故事结局", comment: "")]
    @State private var loc: CGFloat = 0
    @State private var isAnimating = false
    @State private var animationProgress: CGFloat = 0

    var body: some View {
        
        ZStack {
            Image("back_image")
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .offset(x: 0, y: 0) // 调整x和y的值来平移图片位置
                .ignoresSafeArea(.all)
                .scaleEffect(1.009)
            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.0), Color.background.opacity(0.95)]),
                           startPoint: UnitPoint(x: 0.5, y: 0.2), endPoint: UnitPoint(x: 0.5, y: 0.8))
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .ignoresSafeArea(.all)
            VStack {
                Spacer()
                HStack {
                    ForEach(1...6, id: \.self) { value in
                        let isDisabled = isButtonDisabled(value: value)
                        Button(action: {
                            previousMarker = selectedMarker
                            selectedMarker[1] = value
                            checkAndAddPlot(isRightButton: false)
                        }) {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(selectedMarker[1] == value ? Color.main : (isDisabled ? Color.white.opacity(0.5) : Color.white))
                                .frame(width: 30, height: 7)
                        }
                        .disabled(isDisabled)
                    }
                }
                .padding(5)
                ZStack{
                    VStack{
                        
                        if !showgen{
                            if let index = selectedStory!.plots.plots.firstIndex(where: { $0.location == selectedMarker }) {
                                Text(text[(selectedStory?.plots.plots[index].location[1])!-1])
                                    .font(.title3)
                                    .padding(.top)
                                    .foregroundColor(.white)
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 0) {
                                        if let index2 = selectedStory?.plots.plots[index].plotchoseindex,
                                           let perplot = selectedStory?.plots.plots[index].plotchose[index2].perPlot {
                                            Text(perplot)
                                                .font(.callout)
                                                .foregroundColor(.white)
                                                .frame(width: 300, alignment: .topLeading) // 设置文本框架的对齐方式为顶端对齐
                                                
                                        } else {
                                          if  let perplot = selectedStory?.plots.plots[index].plotchose[perplotindex].perPlot {
                                                Text(perplot)
                                                    .font(.callout)
                                                    .foregroundColor(.white)
                                                    .frame(width: 300, alignment: .topLeading) // 设置文本框架的对齐方式为顶端对齐
                                                  
                                            }
                                        }
                                        Spacer() // 使用 Spacer 将文本推到顶端
                                    }
                                    
                                }.frame(width: 300, height: 170) // 设置 VStack 的宽高
                                HStack{
                                    ForEach(selectedStory!.plots.plots[index].plotchose[perplotindex].perCharacter, id: \.self) { character in
                                        Text(character)
                                            .font(.subheadline)
                                            .bold()
                                            .padding(.horizontal, 10) // 添加一些内边距，使文本周围有一定空间
                                            .padding(.vertical, 5)    // 垂直方向的内边距
                                            .foregroundColor(.main)
                                            .opacity(0.8)
                                            .background(Color.white)
                                            .cornerRadius(30)
                                            .fixedSize(horizontal: true, vertical: false) // 让宽度根据文本自动调整
                                    }
                                    Spacer()
                                }
                                .padding(.leading, 30)
                                .padding(.bottom,10)
                            }
                            Spacer()
                        }else{
                            Text("故事内容")
                                .font(.title3)
                                .foregroundColor(.white)
                            ScrollView {
                                Text(selectedPerPlot)
                                    .font(.callout)
                                    .foregroundColor(.white)
                                    .frame(width: 300, alignment: .topLeading)
                            }.frame(width: 365, height: 190) // 设置 VStack 的宽高
                        }
                    }
                    VStack{
                        Spacer()
                        HStack{
                            Spacer()
                            Image("bear_sit")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 220)
                                .offset(x: 90,y: 100)
                        }
                    }

                }
                .frame(width:UIScreen.main.bounds.width * 0.95,height:UIScreen.main.bounds.height * 0.33)
                .background(
                  LinearGradient(
                    stops: [
                      Gradient.Stop(color: Color(red: 0.87, green: 0.48, blue: 0.97).opacity(0.8), location: 0.00),
                      Gradient.Stop(color: Color(red: 0.47, green: 0.32, blue: 0.92), location: 0.74),
                    ],
                    startPoint: UnitPoint(x: 0.89, y: -0.04),
                    endPoint: UnitPoint(x: 0, y: 1.24)
                  )
                )
                .cornerRadius(30)
                .shadow(radius: 10)
                .onChange(of: needregen) { newValue in
                    if newValue {
                        showgen = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            regen()
                            
                            print("重试")
                            needregen = false
                            
                        }
                    }
                }
                .padding(.bottom,40)
                // 顶部的6个按钮

             
                ZStack{
                    RoundedRectangleShape(cornerRadius: 15, loc: loc, long: 80)
                        .foregroundColor(.light)
                        .padding(5)
                        .frame(height: 320)    // 设置矩形的尺寸
                        .opacity(0.8)
                        .shadow(radius: 10)
                    if !showgen{
                        VStack {
      
                            // 右侧的3个按钮
                            DetailView(selectedMarker: $selectedMarker, selectedStory: $selectedStory, perplotindex: $perplotindex, prePerplotindex: $prePerplotindex, plotComplete: $plotComplete)
                                .padding(.horizontal,15)
                                .transition(.slide) // 添加过渡效果
                                .onChange(of: selectedMarker) { newValue in
                                    if let index = selectedStory?.plots.plots.firstIndex(where: { $0.location == newValue }) {
                                        perplotindex = selectedStory?.plots.plots[index].plotchoseindex ?? 0
                                    } else {
                                        perplotindex = 0
                                    }
                                }

                            HStack{
                                if selectedMarker[0] > 1 {
                                    Button(action: {
                                        deletePlot(for: selectedMarker[0])
                                    }) {
                                        Image("trash")
                                          
                                    }

                                }

                                Spacer()
                                Button(action: regen) {
                                    Image("regen")
                                }
                            }
                            .padding(.horizontal,20)
                            
                        }
                    }
                    if showgen{
                        ZStack {
                            LottieView(animationName: "Animation - 1726122467044", loopMode: .loop, animationSpeed: 0.5)
                                .frame(width: 350, height: 320)  // 设置动画视图的大小
                                .onAppear {
                                    chatBot.$generating
                                        .receive(on: RunLoop.main)
                                        .sink { isGenerating in
                                            self.isGenerating = isGenerating
                                            if !isGenerating {
                                                showgen = false
                                                updatePlotChose(from: chatBot.nowgen.data(using: .utf8)!, to: &selectedStory, for: selectedMarker)
                                                self.selectedStory = selectedStory
                                                
                                            }
                                        }
                                        .store(in: &cancellables)
                                }
                        }
                    }
                   

                    VStack{
                        HStack {
                            ForEach(rightButtonValues, id: \.self) { value in
                                HStack{
                                    Button(action: {
                                        let laterLoc:CGFloat = CGFloat((value-1) * 70)
                                        let nowloc = loc
                                        previousMarker = selectedMarker
                                        selectedMarker[0] = value
                                        checkAndAddPlot(isRightButton: true)
                                        if !isAnimating {
                                            isAnimating = true
                                            animationProgress = 0
                                            Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true) { timer in
                                                if animationProgress < 1 {
                                                    animationProgress += 0.01
                                                    let normalizedProgress = min(max(animationProgress, 0), 1) // 确保 progress 在 0 到 1 之间
                                                    let easedValue = easeInOut(t: normalizedProgress)

                                                    if laterLoc > loc {
                                                        let plusloc = easedValue * (laterLoc - nowloc)  // 目标位置的平缓移动
                                                        loc = nowloc + plusloc
                                                    } else if laterLoc < loc {
                                                        let plusloc = easedValue * (nowloc - laterLoc)  // 目标位置的平缓移动
                                                        loc = nowloc - plusloc
                                                    }
                                                    
                                                } else {
                                                    timer.invalidate()
                                                    isAnimating = false
                                                }
                                            }
                                        }
                                    }) {
                                        Text( value > 1 ? NSLocalizedString("支线\(value-1)", comment: "") : NSLocalizedString("主线", comment: ""))
                                            .frame(width: value > 1 ? 63 : 90, height: 40)
                                            .font(.system(size: selectedMarker[0] == value ? 20:15))
                                            .bold()
                                            .foregroundColor(selectedMarker[0] == value ? Color.main : Color.white.opacity(0.6))
                                            
                                            .padding(.horizontal, value > 1 ? 20 : 10)
                                            
                                    }
                                    .frame(width: value > 1 ? 60 : 90)
                                }
                                
                            }
                            // 加号按钮
                            Spacer()
                            Button(action: addButton) {
                                Image("plus")
                                    .resizable()
                                    .frame(width: 90, height: 70)
                                    .padding(.horizontal,10)
                            }
                            .disabled(!canAddButton()) // 禁用条件
                            
                            
                        }
                        .padding(.leading,5)
                        .offset(y:-44)
                        Spacer()
                    }

                }
                .frame(maxHeight: 330)
                
                
                
                // 显示当前选中的标记
                if !plotComplete{
                    HStack {
                        Spacer()
                        Button(action: previousStep) {
                            Text(NSLocalizedString("上一步", comment: ""))
                                .frame(width: 175,height: 60)
                                .font(.headline)
                                .background(Color.main)
                                .foregroundColor(.white)
                                .cornerRadius(60)
                            
                        }
                        .disabled(isPreviousButtonDisabled())
                        Spacer()
                        Button(action: nextStep) {
                            Text(NSLocalizedString("下一步", comment: ""))
                                .frame(width: 175,height: 60)
                                .font(.headline)
                                .background(Color.main)
                                .foregroundColor(.white)
                                .cornerRadius(60)
                        }
                        .disabled(isnextButtonDisabled())
                        Spacer()
                    }
                    .padding(.bottom,40)
                   
                }else{
                    HStack {
                        Spacer()
                        Button(action: previousStep) {
                            Text(NSLocalizedString("返回设置情节分支", comment: ""))
                                .frame(width: 175,height: 60)
                                .font(.headline)
                                .background(Color.main)
                                .foregroundColor(.white)
                                .cornerRadius(60)
                            
                        }
                        .disabled(isPreviousButtonDisabled())
                        Spacer()
                        Button(action: {navigateToStoryOverview = true;removeEmptyStoryTextPlots(from: &(selectedStory)!)}) {
                            Text(NSLocalizedString("完成情节设置", comment: ""))
                                .frame(width: 175,height: 60)
                                .font(.headline)
                                .background(Color.main)
                                .foregroundColor(.white)
                                .cornerRadius(60)
                            
                        }
                        Spacer()
                    }
                    .padding(.bottom,40)
                }
               
            }
            .padding()
            .navigationDestination(isPresented: $navigateToStoryOverview) {
                GenerateName(selectedStory: $selectedStory, stories: $stories, chatBot: ChatBot())
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack{
                        CustomBackButton()
                        Text("StoryLine")
                            .font(.title2)
                            .foregroundColor(.white)
                            
                    }
                }
               
            }
            
            .onAppear(perform: initializeData) // 页面加载时初始化数据
  
        }
    }
    private func GiveTheChoise() {
        if selectedMarker.count > 1, selectedMarker[1] == 2 {
            if let story = selectedStory {
                let sendtext = String(
                    format: NSLocalizedString("story_prompt_template", comment: ""),
                    selectedPerPlot,
                    maincharacter?.characlass ?? "",
                    maincharacter?.name ?? "",
                    maincharacter?.personality ?? "",
                    maincharacter?.ability ?? "",
                    goodintroductions,
                    badintroductions,
                    selectedStory?.scene ?? ""
                )
                chatBot.answer(sendtext, for: story.id){_ in }
                print(sendtext)
                showgen = true
                print(5)
            }
        }
        if selectedMarker.count > 1, selectedMarker[1] == 3 {
            let modifiedTopics = addPrefixToTopics(topics: selectedStory!.topic).joined(separator: " ")
            if let story = selectedStory {
                let sendtext = String(
                    format: NSLocalizedString("conflict_story_prompt_template", comment: ""),
                    selectedPerPlot,
                    modifiedTopics
                )
                print(sendtext)
                chatBot.answer(sendtext, for: story.id , modelName: "gpt-4o"){_ in }
                showgen = true
            }
        }
        if selectedMarker.count > 1, selectedMarker[1] == 4 {
            let modifiedTopics = addPrefixToTopics(topics: selectedStory!.topic).joined(separator: " ")
            if let story = selectedStory {
                let sendtext = String(
                    format: NSLocalizedString("twist_story_prompt_template", comment: ""),
                    selectedPerPlot
                )
                print(sendtext)
                chatBot.answer(sendtext, for: story.id, modelName: "gpt-4o"){_ in }
                showgen = true
            }
        }
        if selectedMarker.count > 1, selectedMarker[1] == 5 {
            if let story = selectedStory {
                let sendtext = String(
                    format: NSLocalizedString("climax_story_prompt_template", comment: ""),
                    selectedPerPlot,
                    goodintroductions,
                    badintroductions,
                    selectedStory?.scene ?? ""
                )
                print(sendtext)
                chatBot.answer(sendtext, for: story.id){_ in }
                showgen = true
            }
        }
        if selectedMarker.count > 1, selectedMarker[1] == 6 {
            if let story = selectedStory {
                let sendtext = String(
                    format: NSLocalizedString("ending_story_prompt_template", comment: ""),
                    selectedPerPlot,
                    maincharacter?.characlass ?? "",
                    maincharacter?.name ?? "",
                    maincharacter?.hobby ?? "",
                    maincharacter?.personality ?? "",
                    maincharacter?.ability ?? "",
                    goodintroductions,
                    badintroductions,
                    selectedStory?.scene ?? ""
                )
                print(sendtext)
                chatBot.answer(sendtext, for: story.id){_ in }
                showgen = true

            }
        }

    }
    private func initializeData() {
        
        setmaincharacter()
        let indices = selectedStory!.findCharacterIndices()
        if let selectedStory = selectedStory {
           goodintroductions = combineIntroductions(from: indices.goodpersonIndices, with: selectedStory)
           badintroductions = combineIntroductions(from: indices.badpersonIndices, with: selectedStory)
                    }
        guard let selectedStory = selectedStory else { return }

        // 初始化 turnmark
        for plot in selectedStory.plots.plots {
            // 排除 plot.location 第一个值为 1 的 Plot，并且 plot.isturn 不为空
            if !plot.isturn.isEmpty && plot.location.first != 1 {
                turnmark.append(plot.isturn)
            }
        }        
        print(turnmark)

        // 初始化 rightButtonValues
        if turnmark.count > 0 {
            // 如果 turnmark 有值，根据其长度初始化 rightButtonValues
            rightButtonValues = Array(1...(turnmark.count)+1) // 根据需要调整初始值
        } else {
            // 如果 turnmark 为空，使用默认值初始化
            rightButtonValues = [1]
        }

        saveSelectedStory()
        if selectedStory.plots.plots.first?.storyText == ""{
            let sendtext = String(
                format: NSLocalizedString("story_opening_prompt_template", comment: ""),
                maincharacter?.characlass ?? "",
                maincharacter?.name ?? "",
                maincharacter?.hobby ?? "",
                maincharacter?.personality ?? "",
                maincharacter?.ability ?? "",
                goodintroductions,
                badintroductions,
                selectedStory.scene
            )
            chatBot.answer(sendtext, for: selectedStory.id){_ in }
            showgen = true
        }
        //初始化选中的选项
        perplotindex = selectedStory.plots.plots.first!.plotchoseindex
 
    }
    //删除空的plot
    func removeEmptyStoryTextPlots(from story: inout Story) {
        story.plots.plots.removeAll { plot in
            return plot.storyText.isEmpty
        }
        saveSelectedStory()
    }


    func updatePlotChose(from jsonData: Data, to selectedStory: inout Story?, for selectedMarker: [Int]) {
        do {
            // 将 JSON 解析为 StoryContainer 结构体
             let storyContainer = try JSONDecoder().decode(StoryContainer.self, from: jsonData)
            
            // 找到 selectedStory 中与 selectedMarker 匹配的 Plot
            if let index = selectedStory?.plots.plots.firstIndex(where: { $0.location == selectedMarker }) {
                // 将解析出来的 stories 添加到 plotchose 中
                selectedStory?.plots.plots[index].plotchose = storyContainer.stories
                selectedStory?.plots.plots[index].plotchoseindex = 0
                if (selectedStory?.plots.plots[index].plotchose.count)! < 3 || (selectedStory?.plots.plots[index].plotchose.count)! > 3{
                    needregen = true
                    showgen = true
                }else{
                    if selectedStory?.plots.plots[index].plotchose[0].perCharacter.count != 2{
                        needregen = true
                        showgen = true
                    }
                    if selectedStory?.plots.plots[index].plotchose[1].perCharacter.count != 2{
                        needregen = true
                        showgen = true
                    }
                    if selectedStory?.plots.plots[index].plotchose[2].perCharacter.count != 2{
                        needregen = true
                        showgen = true
                    }
                    if selectedStory?.plots.plots[index].plotchose[0].perdialog.count != 2{
                        needregen = true
                        showgen = true
                    }
                    if selectedStory?.plots.plots[index].plotchose[1].perdialog.count != 2{
                        needregen = true
                        showgen = true
                    }
                    if selectedStory?.plots.plots[index].plotchose[2].perdialog.count != 2{
                        needregen = true
                        showgen = true
                    }
                }
   
                // 验证结果
            }
        } catch {
            print("Failed to decode JSON: \(error)")
            needregen = true
            showgen = true
        }
    }
    // 删除 Plot 的函数
    private func deletePlot(for value: Int) {
        guard var selectedStory = selectedStory else { return }
        
        // 删除对应的 plot
        selectedStory.plots.plots.removeAll { $0.location.first == value }
        
        // 更新 rightButtonValues
        rightButtonValues.removeAll { $0 == value }
        
        // 更新 turnmark
        turnmark.removeAll { $0.first == value }
        
        // 重置 selectedMarker 如果当前选中的按钮被删除
        if selectedMarker[0] == value {
            selectedMarker = [1, 1] // 或者设置为其他默认值
        }

        self.selectedStory = selectedStory
        saveSelectedStory()
    }
    //组合主题
    func addPrefixToTopics(topics: [String]) -> [String] {
        return topics.enumerated().map { index, topic in
            let prefix = String(
                format: NSLocalizedString("question_prefix_template", comment: ""),
                index + 1
            )
            return prefix + topic
        }
    }

    //设置主角
    func setmaincharacter(){
        
        let  maincharacteIndex = selectedStory?.mainCharacterIndex()
        maincharacter = (selectedStory?.characters.characters[maincharacteIndex!])!
    }
    //设置配角
    func combineIntroductions(from indices: [Int], with selectedStory: Story) -> String {
                var goodIntroductions: [String] = []
    
                for index in indices {
                    let character = selectedStory.characters.characters[index]
                    let introduction = String(
                        format: NSLocalizedString("character_introduction_template", comment: ""),
                        character.name,
                        character.characlass,
                        character.ability,
                        character.personality
                    )
                    goodIntroductions.append(introduction)
                }
    
                return goodIntroductions.joined(separator: "；") // 使用空格将字符串连接起来
    }
    func easeInOut(t: CGFloat) -> CGFloat {
        return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t
    }
    private func saveSelectedStory() {
        if let selectedStory = selectedStory {
            if let index = stories.stories.firstIndex(where: { $0.id == selectedStory.id }) {
                stories.stories[index] = selectedStory
                stories.save()
            }
        }
    }
    //判断下一步按钮的禁用
    private func isPreviousButtonDisabled() -> Bool {
        return turnmark.contains(where: { $0 == selectedMarker }) || showgen
    }
    private func isnextButtonDisabled() -> Bool {
        return showgen
    }
    // “下一步”按钮的操作
    private func nextStep() {
        if selectedMarker[1] < 6 {
            
            if let index = selectedStory!.plots.plots.firstIndex(where: { $0.location == selectedMarker }) {
                //保存到情节中
                selectedStory?.plots.plots[index].dialog = (selectedStory?.plots.plots[index].plotchose[perplotindex].perdialog)!
                selectedStory?.plots.plots[index].characters = (selectedStory?.plots.plots[index].plotchose[perplotindex].perCharacter)!
                selectedStory?.plots.plots[index].storyText = (selectedStory?.plots.plots[index].plotchose[perplotindex].perPlot)!
                if selectedMarker[0]>1{
                    if let index = turnmark.firstIndex(where: { $0[0] == selectedMarker[0] }) {
                        selectedPerPlot = selectedStory!.plots.plots[0...turnmark[index][1]-2].map { $0.storyText }.joined()
                        // 确保 selectedStory 存在

                        // 获取 plots 数组
                        let plots = selectedStory!.plots.plots
                        // 枚举索引和值
                        let enumeratedPlots = plots.enumerated()
                        // 获取 turnmark 的第一个元素和 selectedMarker 的第二个元素
                        let turnmarkStart = turnmark[index][1]
                        let selectedRangeEnd = selectedMarker[1]
                        // 过滤符合条件的 plot
                        let filteredPlots = enumeratedPlots.filter { (index, plot) in
                            return plot.location[0] == selectedMarker[0] && (turnmarkStart...selectedRangeEnd).contains(plot.location[1])
                        }
                        let storyTexts = filteredPlots.map { (index, plot) in
                            return plot.storyText
                        }
                        let selectedPerPlot2 = storyTexts.joined()
                        print(selectedPerPlot)
                        print("")
                        print(selectedPerPlot2)
                        selectedPerPlot = selectedPerPlot + selectedPerPlot2
                        if selectedMarker[1] == 2{
                            selectedStory?.plot2 = selectedPerPlot
                        }else if selectedMarker[1] == 3{
                            selectedStory?.plot3 = selectedPerPlot
                        }
                    }
                }else{
                    selectedPerPlot = selectedStory!.plots.plots[0...index].map { $0.storyText }.joined()
                }
                
                
                if perplotindex < 3 && perplotindex != prePerplotindex{
                    print("删除plot")
                    selectedStory?.plots.plots.removeAll { plot in
                        // 删除所有 location 的第二个值大于 selectedMarker 第二个值的 plot
                        return plot.location.count > 1 && plot.location[1] > selectedMarker[1]&&plot.location[0] == selectedMarker[0]
                    }
                }
            }
            //切换页面
            selectedMarker[1] += 1
            checkAndAddPlot(isRightButton: false)
        }else{
            //最后点击下一步
            if let index = selectedStory!.plots.plots.firstIndex(where: { $0.location == selectedMarker }) {
                //保存到情节中
                selectedStory?.plots.plots[index].dialog = (selectedStory?.plots.plots[index].plotchose[perplotindex].perdialog)!
                selectedStory?.plots.plots[index].characters = (selectedStory?.plots.plots[index].plotchose[perplotindex].perCharacter)!
                selectedStory?.plots.plots[index].storyText = (selectedStory?.plots.plots[index].plotchose[perplotindex].perPlot)!
                selectedPerPlot = selectedStory!.plots.plots[0...index].map { $0.storyText }.joined()
            }
         plotComplete = true
        }
        selectedStory?.plot1 = selectedPerPlot
        saveSelectedStory()
    }
    //刷新选项
    private func regen() {
        print(selectedPerPlot)
        GiveTheChoise()
        perplotindex = 0
        if selectedMarker.count > 1, selectedMarker[1] == 1 {
            if let story = selectedStory {
                let sendtext = String(
                    format: NSLocalizedString("story_opening_prompt_template", comment: ""),
                    maincharacter?.characlass ?? "",
                    maincharacter?.name ?? "",
                    maincharacter?.hobby ?? "",
                    maincharacter?.personality ?? "",
                    maincharacter?.ability ?? "",
                    goodintroductions,
                    badintroductions,
                    selectedStory!.scene
                )
                chatBot.answer(sendtext, for: story.id){_ in }
                showgen = true
            }
        }
    }
    // “上一步”按钮的操作
    private func previousStep() {
        if selectedMarker[1] > 1 {
            selectedMarker[1] -= 1
            checkAndAddPlot(isRightButton: false)
            saveSelectedStory()
        }
        plotComplete = false
    }
    // 检查是否可以添加按钮
    private func canAddButton() -> Bool {
        let doesPlotExist = selectedStory?.plots.plots.contains(where: { $0.location == [1, 6] }) == true
        let isSelectedMarkerValid = selectedMarker[0] == 1
        return doesPlotExist && isSelectedMarkerValid
    }

    // 添加按钮的函数
    private func addButton() {
        // 新增一个按钮值，假设依次递增
        plotComplete = false
        if let maxValue = rightButtonValues.max() {
            let newValue = maxValue + 1
            rightButtonValues.append(newValue)
            
            // 自动选择新增的按钮
            previousMarker = selectedMarker
            selectedMarker[0] = newValue
            loc = CGFloat((selectedMarker[0]-1)*70)
            checkAndAddPlot(isRightButton: true)
        }
        
    }
    //检查按钮是否应该禁用
    private func isButtonDisabled(value: Int) -> Bool {
        // 检查是否存在 location 中第二个值为 6 的 plot
        let isFull: Bool
        if let plots = selectedStory?.plots {
            isFull = plots.plots.contains { plot in
                return plot.location.count > 1 && plot.location[1] == 6
            }
        } else {
            isFull = false
        }

        // 如果没有 plot 的第二个值等于 6，则禁用按钮
        if !isFull {
            return true
        }

        // 遍历 turnmark 数组，进一步检查是否应该禁用按钮
        for mark in turnmark {
            if selectedMarker[0] == mark[0] && value < mark[1] {
                return true
            }
        }

        return false
    }
    // 检查并添加 plot 的函数
    private func checkAndAddPlot(isRightButton: Bool) {
        guard var selectedStory = selectedStory else { return }


        if isRightButton {
            // 右侧按钮点击时的处理
            if let index = selectedStory.plots.plots.firstIndex(where: { $0.location.first == selectedMarker.first }) {
                // 获取匹配的 plot
                let matchedPlot = selectedStory.plots.plots[index]
                
                // 自动选择与 location 第二个值相同的顶部按钮
                selectedMarker[1] = matchedPlot.location[1]
                
                // 你可以在这里执行其他需要的操作，比如更新 UI 或者调用其他方法
            }else {
                // 如果不存在相同位置的 plot，则创建新的 plot 并设置 isturn
                if let index = selectedStory.plots.plots.firstIndex(where: { $0.location[1] == selectedMarker[1]-1 }) {
                    // 合并从第一个情节到当前情节的所有 storyText
                    selectedPerPlot = selectedStory.plots.plots[0...index].map { $0.storyText }.joined()
                    print(selectedPerPlot)
                }
               
                let newPlot = Plot(
                    storyText: "",
                    imageUrl: URL(string: "https://c-ssl.dtstatic.com/uploads/blog/202208/20/20220820215029_f02bd.thumb.1000_0.jpeg")!, // 示例 URL
                    characterUrls: [],
                    characters: [],
                    location: selectedMarker,
                    dialog: [],
                    isturn: selectedMarker,
                    turninfo: [],
                    plotchose: [PlotChoice(perPlot: NSLocalizedString("夜幕降临，王子走出城堡，手持一把闪亮的剑，漫步在星空下。他回想起之前在书中学到的剑术，正当他沉浸在思考中时，一名神秘的来客出现在他面前，声称有重要的警告。", comment: ""), perCharacter: [NSLocalizedString("林克王子", comment: ""), NSLocalizedString("艾尔德里克骑士", comment: "")], perdialog: [NSLocalizedString("王子，快看！我在城外发现了敌兵的动向！", comment: ""), NSLocalizedString("我们必须立刻行动，保护我们的王国！", comment: "")])],
                    plotchoseindex: 0,
                    promotechara: [],
                    promote: ""
                )
                if let index = selectedStory.plots.plots.firstIndex(where: { $0.location == previousMarker }) {
                    selectedStory.plots.plots[index].isturn = selectedMarker
                }
                selectedStory.plots.plots.append(newPlot)
                turnmark.append(selectedMarker)
                saveSelectedStory()
                GiveTheChoise()
                perplotindex = 0
            }

            // 查找并更新与 previousMarker 匹配的 plot

        } else {
            // 顶部按钮点击时的处理
            if !selectedStory.plots.plots.contains(where: { $0.location == selectedMarker }) {
                // 如果不存在相同位置的 plot，则创建新的 plot
                let newPlot = Plot(
                    storyText: "",
                    imageUrl: URL(string: "https://c-ssl.dtstatic.com/uploads/blog/202208/20/20220820215029_f02bd.thumb.1000_0.jpeg")!, // 示例 URL
                    characterUrls: [],
                    characters: [],
                    location: selectedMarker,
                    dialog: [],
                    isturn: [],
                    turninfo: [],
                    plotchose: [PlotChoice(perPlot: NSLocalizedString("夜幕降临，王子走出城堡，手持一把闪亮的剑，漫步在星空下。他回想起之前在书中学到的剑术，正当他沉浸在思考中时，一名神秘的来客出现在他面前，声称有重要的警告。", comment: ""), perCharacter: [NSLocalizedString("林克王子", comment: ""), NSLocalizedString("艾尔德里克骑士", comment: "")], perdialog: [NSLocalizedString("王子，快看！我在城外发现了敌兵的动向！", comment: ""), NSLocalizedString("我们必须立刻行动，保护我们的王国！", comment: "")])],
                    plotchoseindex: 0,
                    promotechara: [],
                    promote: ""
                )
                selectedStory.plots.plots.append(newPlot)
                saveSelectedStory()
                GiveTheChoise()
                perplotindex = 0
            }
        }

        // 将修改后的 selectedStory 赋值回去
        self.selectedStory = selectedStory
    }
}

struct DetailView: View {
    @Binding var selectedMarker: [Int]
    @Binding var selectedStory: Story?
    @Binding var perplotindex : Int
    @Binding var prePerplotindex : Int
    @Binding var plotComplete:Bool
    var body: some View {
         VStack(alignment: .leading, spacing: 5) {
             if let plotIndex = selectedStory?.plots.plots.firstIndex(where: { $0.location == selectedMarker }) {
                 let plot = selectedStory!.plots.plots[plotIndex]
                 ForEach(plot.plotchose.indices, id: \.self) { index in
                     let plotChoice = plot.plotchose[index]
                     ZStack{
                         RoundedRectangle(cornerRadius: 30)
                             .foregroundColor(plot.plotchoseindex == index ? Color.main : Color.gray)
                             .opacity(0.3)
                             .frame(width:330, height: 60)
                             .padding(.horizontal,5)
                             .offset(x: 4, y: 7) // 向右偏移 10 点，向下偏移 10 点

                         Button(action: {
                             // 更新 selectedStory 中的 plotchoseindex
                             prePerplotindex = (selectedStory?.plots.plots[plotIndex].plotchoseindex)!
                             selectedStory?.plots.plots[plotIndex].plotchoseindex = index
                             perplotindex = index
                             plotComplete = false
                             
                         }) {
                             VStack(alignment: .leading, spacing: 5) {
                                 // 显示 perPlot
                                 Text(plotChoice.perPlot)
                                     .font(.headline)
                                     .foregroundColor(plot.plotchoseindex != index ? Color.main : Color.white)
                                     .padding()
                                     .padding(.horizontal,20)
                                     

                                 // 显示每个 perCharacter 的元素
    //                             HStack{
    //                                 ForEach(plotChoice.perCharacter, id: \.self) { character in
    //                                     Text(character)
    //                                         .font(.subheadline)
    //                                         .padding(.leading, 10)
    //                                 }
    //                             }
                             }
                             .frame(width:330, height: 60)
                             .background(plot.plotchoseindex == index ? Color.main : Color.white)
                             .cornerRadius(30)
                             .padding(.vertical,8)
                         }
                     
                     }

                 }
             } else {
                 Text("No plot available for this marker")
                     .font(.largeTitle)
                     .foregroundColor(.red)
             }
         }
        
     }

}

#Preview {
    let initialStory = Story(
        id: UUID(),
        title: "示例故事",
        characters: Characters(
            characters: [
                Character(name: "王子", characlass: "王子", introduction: "一名勇敢的王子", hobby: "阅读", personality: "仁慈", ability: "剑术", classnum: 1, persontype: 0, maincharacter: true, sex: true)
            ]
        ),
        scene: "古老的城堡",
        plots: Plots(
            plots: [
                Plot(
                    storyText: "夜幕降临，王子走出城堡，手持一把闪亮的剑，漫步在星空下。他回想起之前在书中学到的剑术，正当他沉浸在思考中时，一名神秘的来客出现在他面前，声称有重要的警告。",
                    imageUrl: URL(string: "https://example.com/image.jpg")!,
                    characterUrls: [],
                    characters: ["王子","王子"],
                    location: [1, 1],
                    dialog: [],
                    isturn: [],
                    turninfo: [],
                    plotchose: [PlotChoice(perPlot: "夜幕降临，王子走出城堡，手持一把闪亮的剑，漫步在星空下。他回想起之前在书中学到的剑术，正当他沉浸在思考中时，一名神秘的来客出现在他面前，声称有重要的警告。", perCharacter: ["王子", "骑士艾尔德里克"], perdialog: ["王子，快看！我在城外发现了敌兵的动向！", "我们必须立刻行动，保护我们的王国！"]),PlotChoice(perPlot: "夜幕降临，王子走出城堡，手持一把闪亮的剑，漫步在星空下。他回想起之前在书中学到的剑术，正当他沉浸在思考中时，一名神秘的来客出现在他面前，声称有重要的警告。", perCharacter: ["王子", "骑士艾尔德里克"], perdialog: ["王子，快看！我在城外发现了敌兵的动向！", "我们必须立刻行动，保护我们的王国！"]),PlotChoice(perPlot: "夜幕降临，王子走出城堡，手持一把闪亮的剑，漫步在星空下。他回想起之前在书中学到的剑术，正当他沉浸在思考中时，一名神秘的来客出现在他面前，声称有重要的警告。", perCharacter: ["王子", "骑士艾尔德里克"], perdialog: ["王子，快看！我在城外发现了敌兵的动向！", "我们必须立刻行动，保护我们的王国！"])
                    ],
                    plotchoseindex: 0,
                    promotechara: [],
                    promote: ""
                ),
                Plot(
                    storyText: "夜幕降临，王子走出城堡，手持一把闪亮的剑，漫步在星空下。他回想起之前在书中学到的剑术，正当他沉浸在思考中时，一名神秘的来客出现在他面前，声称有重要的警告。",
                    imageUrl: URL(string: "https://example.com/image.jpg")!,
                    characterUrls: [],
                    characters: ["王子","王子"],
                    location: [2, 1],
                    dialog: [],
                    isturn: [],
                    turninfo: [],
                    plotchose: [PlotChoice(perPlot: "夜幕降临，王子走出城堡，手持一把闪亮的剑，漫步在星空下。他回想起之前在书中学到的剑术，正当他沉浸在思考中时，一名神秘的来客出现在他面前，声称有重要的警告。", perCharacter: ["王子", "骑士艾尔德里克"], perdialog: ["王子，快看！我在城外发现了敌兵的动向！", "我们必须立刻行动，保护我们的王国！"]),PlotChoice(perPlot: "夜幕降临，王子走出城堡，手持一把闪亮的剑，漫步在星空下。他回想起之前在书中学到的剑术，正当他沉浸在思考中时，一名神秘的来客出现在他面前，声称有重要的警告。", perCharacter: ["王子", "骑士艾尔德里克"], perdialog: ["王子，快看！我在城外发现了敌兵的动向！", "我们必须立刻行动，保护我们的王国！"]),PlotChoice(perPlot: "夜幕降临，王子走出城堡，手持一把闪亮的剑，漫步在星空下。他回想起之前在书中学到的剑术，正当他沉浸在思考中时，一名神秘的来客出现在他面前，声称有重要的警告。", perCharacter: ["王子", "骑士艾尔德里克"], perdialog: ["王子，快看！我在城外发现了敌兵的动向！", "我们必须立刻行动，保护我们的王国！"])
                    ],
                    plotchoseindex: 0,
                    promotechara: [],
                    promote: ""
                )
            ]
        ),
        plot1: "故事情节1",
        plot2: "故事情节2",
        plot3: "故事情节3",
        topic: ["勇气", "冒险"],
        storyintro: "这是一个关于勇气和冒险的故事。",
        storyimage: [URL(string: "https://example.com/storyimage1.jpg")!],
        finished: false,
        allcharacterUrls: [],
        allcharacters: []
    )
    
    return selectplots(
        selectedStory: .constant(initialStory),
        stories: .constant(Stories(stories: [initialStory]))
    )
}

struct LottieView: UIViewRepresentable {
    var animationName: String
    var loopMode: LottieLoopMode = .loop
    var animationSpeed: CGFloat = 0.5

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        // 创建 Lottie 动画视图
        let animationView = LottieAnimationView(name: animationName)
        animationView.frame = view.bounds
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed
        
        // 将动画视图添加到 SwiftUI 的 UIView 中
        view.addSubview(animationView)
        
        // 播放动画
        animationView.play()
        
        // 设置动画大小自动调整
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // 这里可以更新动画相关的逻辑
    }
}
