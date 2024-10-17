import Combine
import SwiftUI

struct GenerateName: View {
    @Binding var selectedStory: Story?
    @Binding var stories: Stories
    @State private var navigateToSelectman = false // 添加状态变量以控制导航
    @Environment(\.presentationMode) var presentationMode // 用于返回上一个视图
    @ObservedObject var chatBot: ChatBot
    @State private var isGenerating = false
    @State private var cancellables = Set<AnyCancellable>()
    @State private var showAlert = false
    @State private var maincharacteIndex : Int = 999
    @State private var selectedRectangle: Int? = nil
    let titles = [NSLocalizedString("城堡", comment: ""), NSLocalizedString("森林", comment: ""), NSLocalizedString("村庄", comment: ""), NSLocalizedString("海洋", comment: ""), NSLocalizedString("沙漠", comment: ""), NSLocalizedString("雪山", comment: "")]
    @State private var finGenerating = false
    @State private var bottomnum = 0
    @State private var progress: Double = 0.0
    @State private var timer: Timer? = nil
    @State private var message: String = NSLocalizedString("正在生成角色", comment: "")
    @State private var rotationAngle: Double = 0
    var body: some View {
        ZStack {
            Image("back_image")
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .offset(x: 0, y: 0) // 调整x和y的值来平移图片位置
                .ignoresSafeArea(.all)
                .scaleEffect(1.009)

            Image("bear_book")
                .position(x: 220, y: 500) // 调整图像位置

            VStack {
                HStack {
                    Image("airplane")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50) // 调整图像大小
                        .padding(.top, 80)
                        .padding(.horizontal, 30)
                    Spacer()
                }
                Text(NSLocalizedString("最后，为你的故事起一个名字吧！", comment: ""))
                    .font(.title)
                    .fontWeight(.medium)
                    .lineSpacing(5) // 设置行间距为5
                    .foregroundColor(Color.white)
                    .frame(width: 320, alignment: .topLeading)
                    .padding(.top, 5)
                Spacer()
                ZStack {
                    if let unwrappedStory = selectedStory {
                        TextField("Name", text: Binding(
                            get: { unwrappedStory.title },
                            set: { newValue in
                                selectedStory?.title = newValue
                            }
                        ))
                        .frame(height: 25)
                        .padding()
                        .background(Color.light)
                        .cornerRadius(50)
                        .padding(.horizontal)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.sub)
                        
                        Button(action: {
                            bottomnum = 1
                            if let scene = selectedStory?.scene, let index = titles.firstIndex(of: scene) {
                               selectedRectangle = index
                           }
                            maincharacteIndex = selectedStory?.mainCharacterIndex() ?? 999
                            if maincharacteIndex == 999{
                                showAlert = true
                            }
                            generateName()
                            
                        }) {
                            Text(NSLocalizedString("点击生成", comment: ""))
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .disabled(isGenerating)
                        .buttonStyle(RightButtonStyle(backgroundColor: Color.main))
                        .padding(.leading, 230)
                        .padding(.trailing, 24)
                        
                        if chatBot.generating && bottomnum == 1 {
                            ProgressView()
                                .onAppear {
                                    chatBot.$generating
                                        .receive(on: RunLoop.main)
                                        .sink { isGenerating in
                                            self.isGenerating = isGenerating
                                            if !isGenerating && bottomnum == 1  {
                                                selectedStory?.title = self.chatBot.nowgen
                                                print(self.selectedStory?.title ?? "No Title")
                                            }
                                        }
                                        .store(in: &cancellables)
                                }
                                .padding()
                        }
                    }
                }
                
              
                Spacer()
 
            }
            VStack{
                Spacer()
                Button(action: {
                    // 按钮点击事件
                    if let scene = selectedStory?.scene, let index = titles.firstIndex(of: scene) {
                        selectedRectangle = index
                    }
                    maincharacteIndex = selectedStory?.mainCharacterIndex() ?? 999
                    if maincharacteIndex == 999 {
                        showAlert = true
                    }
                    bottomnum = 2
                    let sendtext2 = String(
                        format: NSLocalizedString("story_summary_prompt_template", comment: ""),
                        selectedStory?.characters.characters[maincharacteIndex].name ?? "大卫",
                        selectedStory?.characters.characters[maincharacteIndex].characlass ?? "王子",
                        titles[selectedRectangle ?? 1],
                        selectedStory?.plot1 ?? ""
                    )
                    chatBot.answer(sendtext2, for: selectedStory?.id ?? UUID()) { _ in }
                    print(sendtext2)
                }) {
                    Text(NSLocalizedString("生成故事概览", comment: ""))
                        .font(Font.custom("SF Pro", size: 20))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 66)
                        .background(Color.sub)
                        .cornerRadius(33)
                        .padding(.horizontal)
                        .shadow(radius: 10)
                        .padding(.bottom,50)
                }
            }
            .frame(width: UIScreen.main.bounds.width,height:UIScreen.main.bounds.height)
            if chatBot.generating && bottomnum == 2{
                BlurView(style: .systemMaterial)
                    .edgesIgnoringSafeArea(.all)
                if progress <= 1 {
                    ZStack {
                        LottieView(animationName: "Animation - 1726121308557 (1)", loopMode: .loop, animationSpeed: 0.5)
                        .onAppear {
                            chatBot.$generating
                                .receive(on: RunLoop.main)
                                .sink { isGenerating in
                                    self.isGenerating = isGenerating
                                    if !isGenerating && bottomnum == 2  {
                                        print(chatBot.nowgen)
                                        selectedStory?.storyintro = self.chatBot.nowgen
                                        finGenerating = true
                                        
                                        if let selectedStory = selectedStory {
                                            if let index = stories.stories.firstIndex(where: { $0.id == selectedStory.id }) {
                                                stories.stories[index] = selectedStory
                                                stories.save()
                                            }
                                        }
                                        progress = 1
                                        finGenerating = false
                                        navigateToSelectman = true
                                    }
                                }
                                .store(in: &cancellables)
                        }
                    }
                } else {
                    ZStack {
                        Image("loading")
                        Text(NSLocalizedString("创建完成", comment: ""))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack{
                    CustomBackButton()
                    Text("设置故事名称")
                        .font(.title2)
                        .foregroundColor(.white)
                        
                }
            }
           
        }

        .navigationDestination(isPresented: $navigateToSelectman) {
           StoryOverview(chatBot: ChatBot(), selectedStory: $selectedStory, stories: $stories) // 导航到 selectman 界面
        }
        .alert(isPresented: $showAlert) {
                      Alert(
                        title: Text(NSLocalizedString("未选择故事主角", comment: "")),
                          message: Text("帮您指定\( selectedStory?.characters.characters[0].name ?? "未找到角色")作为故事的主角"),
                          dismissButton: .default(Text("确定"), action: {
                              selectedStory?.characters.characters[0].maincharacter = true
                              maincharacteIndex = 0
                              if let selectedStory = selectedStory {
                                  if let index = stories.stories.firstIndex(where: { $0.id == selectedStory.id }) {
                                      stories.stories[index] = selectedStory
                                      stories.save()
                                  }
                              }
                          })
                      )
                  }
    }
    func generateName() {
        let sendtext = String(
            format: NSLocalizedString("story_name_prompt_template", comment: ""),
            selectedStory?.characters.characters[maincharacteIndex].name ?? "大卫",
            selectedStory?.characters.characters[maincharacteIndex].characlass ?? "王子",
            titles[selectedRectangle ?? 1],
            selectedStory?.plot1 ?? "爱情",
            String(Int.random(in: 1...100000))
        )

        chatBot.answer(sendtext, for: selectedStory?.id ?? UUID()){_ in }
    }
    
    func startTimer() {
        progress = 0.0
        message = NSLocalizedString("正在生成故事概览", comment: "")
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if progress < 1.0 {
                progress += 0.1 / 6
                if progress >= 0.8 {
                    message = NSLocalizedString("马上完成创建", comment: "")
                } else if progress >= 0.5 {
                    message = NSLocalizedString("正在完善故事细节", comment: "")
                } else if progress >= 0.2 {
                    message = NSLocalizedString("正在生成故事简介", comment: "")
                } else {
                    message = NSLocalizedString("正在生成故事概览", comment: "")
                }
            } else {
                timer.invalidate()
            }
        }
    }
}
#Preview {
    GenerateName(
        selectedStory: .constant(Story(id: UUID(), title: "示例故事", characters: Characters(), scene:"", plots: Plots(), plot1: "", plot2: "", plot3: "", topic: [], storyintro: "", storyimage: [], finished: false,allcharacterUrls:[], allcharacters: [])),
        stories: .constant(Stories()),
        chatBot: ChatBot()
    )
}
