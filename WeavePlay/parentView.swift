import SwiftUI
import Combine

class GlobalSettings: ObservableObject {
    @AppStorage("selectedMinute") var selectedMinute: Int = 60
    @AppStorage("textPositions") var textPositionsData: Data = Data() {
        didSet {
            textPositions = loadTextPositions()
        }
    }
    @Published var textPositions: [TextPosition] = []

    init() {
        textPositions = loadTextPositions()
    }

    func loadTextPositions() -> [TextPosition] {
        guard let positions = try? JSONDecoder().decode([TextPosition].self, from: textPositionsData) else {
            return []
        }
        return positions
    }

    func saveTextPositions() {
        guard let data = try? JSONEncoder().encode(textPositions) else { return }
        textPositionsData = data
    }
}
struct CodablePoint: Codable, Equatable {
    var x: CGFloat
    var y: CGFloat
    
    var cgPoint: CGPoint {
        return CGPoint(x: x, y: y)
    }
    
    init(_ cgPoint: CGPoint) {
        self.x = cgPoint.x
        self.y = cgPoint.y
    }
}

struct TextPosition: Identifiable, Codable, Equatable {
    var id: UUID
    var text: String
    var position: CodablePoint
    
    init(id: UUID = UUID(), text: String, position: CGPoint) {
        self.id = id
        self.text = text
        self.position = CodablePoint(position)
    }
    
    static func loadAll(from data: Data) -> [TextPosition] {
        guard let positions = try? JSONDecoder().decode([TextPosition].self, from: data) else {
            return []
        }
        return positions
    }
    
    static func extractTexts(from positions: [TextPosition]) -> [String] {
        return positions.map { $0.text }
    }
}

struct MinutePickerView: View {
    @EnvironmentObject var globalSettings: GlobalSettings
    @State private var inputText = ""
    @State private var topics: [String] = []
    @State private var selectedStory: Story?
    @State private var stories = Stories.load()
    @State private var intoreadview:Bool = false
    @State private var navigateToSelectMan = false
    @State private var intoCildren:Bool = false
    @State private var newStory: Story? = nil // 新故事
    @State private var navigateToCreateView = false
    @State private var tosdView:Bool = false
    @State private var height: CGFloat = 0
    @State private var width: CGFloat = 0
    @State private var isSidebarVisible = false
    @State private var toLoginView : Bool = false
    @StateObject private var authManager = AuthManager()
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        GeometryReader { geometry in
                   ZStack {
                       Image("back_image")
                           .resizable()
                           .scaledToFill()
                           .frame(width: geometry.size.width, height: geometry.size.height)
                           .offset(x: 0, y: 0) // 调整x和y的值来平移图片位置
                           .ignoresSafeArea(.all)
                           .scaleEffect(1.09)
                       
                       LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.0), Color.background.opacity(1)]),
                                      startPoint: UnitPoint(x: 0.5, y: 0.2), endPoint: UnitPoint(x: 0.5, y: 0.9))
                           .frame(width: geometry.size.width, height: geometry.size.height)
                           .ignoresSafeArea(.all)
                           .scaleEffect(1.2)
         
                       
                       ScrollView {
                           VStack {
                               Spacer(minLength: 10)
                               HStack {
                                   Text("欢迎来到WeavePlay")
                                       .font(.title)
                                       .foregroundStyle(Color.white)
                                       .bold()
                                       .shadow(radius: 5)
                                   Spacer()
                               }
                               .padding(.horizontal, 20)
                               .padding(.bottom)
                               
                               HStack {
                                   Text(NSLocalizedString("来为您的孩子创建一个故事吧", comment: "开头页面"))
                                       .font(.title2)
                                       .foregroundStyle(Color.white)
                                       .bold()
                                       .shadow(radius: 5)
                                   Spacer()
                               }
                               .padding(.horizontal, 20)
                               
                               ZStack {
                                   Image("children")
                                       .resizable()
                                       .scaledToFit()
                                       .frame(width: geometry.size.width < 768 ? geometry.size.width*0.65 : 400, height: geometry.size.height < 768 ?  geometry.size.width*0.65 : 400)
                                   ZStack{
                                       ForEach(globalSettings.textPositions) { item in
                                           HStack {
                                               Button(action: {
                                                   deleteText(item)
                                               }) {
                                                   Image(systemName: "trash")
                                                       .foregroundColor(.red)
                                               }
                                               .padding(12)
                                               Text(item.text)
                                                   .padding(.trailing)
                                               
                                           }
                                           .frame(height: 30, alignment: .leading)
                                           .background(Color.white)
                                           .opacity(0.8)
                                           .cornerRadius(30)
                                           .position(item.position.cgPoint)
                                       }
                                   }
       
                               }
                               .frame(width: geometry.size.width < 768 ? geometry.size.width*0.65 : 400, height: geometry.size.height < 768 ?  geometry.size.width*0.65 : 400)
                           }
                           
                           HStack {
                               TextField(NSLocalizedString("请输入您的烦恼", comment: "请输入您的烦恼"), text: $inputText)
                                   .frame(width: 260, height: 45, alignment: .leading )
                                   .background(Color.light)
                                   .cornerRadius(50)
                                   .font(.system(size: 18, weight: .medium, design: .rounded))
                                   .foregroundColor(.sub)
                                   
                                   
                               Button(action: addText) {
                                   Text(NSLocalizedString("添加", comment: "添加"))
                                       .font(.system(size: 18, weight: .medium, design: .rounded))
                                       .foregroundColor(.white)
                               }
                               .frame(width: 70, height:50)
                               .background(Color.sub)
                               .cornerRadius(50)
                           }
                           .padding(.horizontal)
                           .padding(.bottom)
                           HStack {
                               Text(NSLocalizedString("已创建的故事", comment: "开头页面"))
                                   .font(.title3)
                                   .foregroundStyle(Color.white)
                                   .bold()
                               Spacer()
                           }
                           .padding(.horizontal, 20)
                           
                           ForEach(stories.stories) { story in
                               Button(action: {
                                   selectedStory = story
                               }) {
                                   StoryItemView(story: story, selectedStory: $selectedStory, navigateToSelectMan: $navigateToSelectMan, intoreadview: $intoreadview, stories: $stories, tosdView: $tosdView)
                               }
                           }
                           Spacer(minLength: 200)
                       }
                       
//                       if stories.stories.isEmpty {
//                           VStack {
//                               Spacer()
//                               ZStack {
//                                   Image("bear_tip")
//                                       .scaleEffect(0.8)
//                                       .padding(.trailing, -100)
//                                       .padding(.bottom, 70)
//                                       .shadow(radius: 10)
//                                   Text("您还没有创作过故事哦，点击下面的加号创建一个吧。")
//                                       .foregroundStyle(Color.gray)
//                                       .frame(width: 250)
//                                       .lineSpacing(10.0)
//                                       .tracking(0.5)
//                                       .padding(.trailing, -50)
//                                       .padding(.bottom, 210)
//                               }
//                           }
//                       }
                       
                       VStack {
                           Button(action: {
                               let topics = globalSettings.textPositions.map { $0.text }
                               let story = Story(title: NSLocalizedString("未创建", comment: "未创建"), characters: Characters(), scene: "", plots: Plots(), plot1: "", plot2: "", plot3: "", topic: topics, storyintro: NSLocalizedString("小朋友，这个故事还未创建完成哦，点击按钮继续创建故事吧", comment: ""), storyimage: [], main_image: URL(string: "https://fc-sd-62aafe39g.oss-cn-hangzhou.aliyuncs.com/OtherImage/mianimage.png")!, finished: false, allcharacterUrls: [], allcharacters: [])
                               newStory = story
                               navigateToCreateView = true
                           }) {
                               Image("newstory")
                           }
                           .padding(20)
                           
                       }
                       .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottomTrailing)
                   }
                   .onAppear {
                       width = geometry.size.width
                       height = geometry.size.height
                   }
            if isSidebarVisible {
                SlideInSidebarView(isVisible: $isSidebarVisible,toLoginView: $toLoginView)
            }
               }
        .navigationDestination(isPresented: $navigateToSelectMan) {
            if selectedStory != nil {
                SelectMan(selectedStory: $selectedStory, stories: $stories) // 传递 stories 绑定
            }
        }
        .navigationDestination(isPresented: $intoCildren) {
            HomeView() // 传递 stories 绑定
        }
        .navigationDestination(isPresented: $navigateToCreateView) {
            if newStory != nil {
                CreateView(newStory: $newStory, stories: $stories) // 传递 stories 绑定
            }
        }
        .navigationDestination(isPresented: $toLoginView) {
            LoginView()
                .environmentObject(TimerManager())
                .environmentObject(GlobalSettings())
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.main.opacity(0.5), for: .navigationBar)
        
        .toolbar {
            if !isSidebarVisible {
                ToolbarItem(placement: .navigationBarLeading) {
                                        Button(action: {
                                            withAnimation {
                                                isSidebarVisible.toggle()
                                            }
                                        }) {
                                            Image(systemName: "person.circle")
                                                .foregroundStyle(Color.white)
                                                .font(.system(size: 25))
                                        }
                                    }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            intoCildren = true
                        }) {
                            ZStack{
                                RoundedRectangle(cornerRadius: 30)
                                    .frame(width: 83,height: 40)
                                    .foregroundColor(.main)
                                    .shadow(radius: 3)
                                HStack{
                                    Spacer()
                                    Image("change_parent")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40)
                                       
                                    Image(systemName: "repeat")
                                        .foregroundColor(.white)
                                        .font(.system(size: 20))
                                        .padding(.trailing,10)
  
            
                                }
                            }.frame(width: 83,height: 40)
                        }
                    }
                }
            }

        }
        .onAppear {
            topics = TextPosition.extractTexts(from: globalSettings.textPositions)
            selectedStory = stories.stories.first
        }
        .onChange(of: globalSettings.textPositions) { _ in
            topics = TextPosition.extractTexts(from: globalSettings.textPositions)
            globalSettings.saveTextPositions()
        }
        .onAppear {
            AppDelegate.orientationLock = .portrait
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.first?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
            }

        }
    }

    func addText() {
        guard !inputText.isEmpty else { return }
        
        let circleCenter = CGPoint(x: 150, y: 170)  // Circle center
        let radius: CGFloat = 125  // Radius of the circle (half of diameter 250)
        
        // Generate random position on the circle
        var newPosition: CGPoint
        let maxAttempts = 100
        var attempts = 0
        
        repeat {
            newPosition = randomPointOnCircle(center: circleCenter, radius: radius)
            attempts += 1
        } while !isValidPosition(newPosition) && attempts < maxAttempts
        
        if attempts < maxAttempts {
            globalSettings.textPositions.append(TextPosition(text: inputText, position: newPosition))
            inputText = ""
        }
    }

    func randomPointOnCircle(center: CGPoint, radius: CGFloat) -> CGPoint {
        let angle = CGFloat.random(in: 0...2 * .pi)
        let x = center.x + radius * cos(angle)
        let y = center.y + radius * sin(angle)
        return CGPoint(x: x, y: y)
    }

    func isValidPosition(_ position: CGPoint) -> Bool {
        // Check if the position is inside the circle
        let circleCenter = CGPoint(x: 150, y: 170)  // Circle center
        let radius: CGFloat = 125  // Radius of the circle
        let distance = sqrt(pow(position.x - circleCenter.x, 2) + pow(position.y - circleCenter.y, 2))
        
        return distance <= radius
    }
    
    func deleteText(_ textPosition: TextPosition) {
        globalSettings.textPositions.removeAll { $0.id == textPosition.id }
    }


}

struct SlideInSidebarView: View {
    @Binding var isVisible: Bool
    @Binding var toLoginView : Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                Color.black
                    .opacity(isVisible ? 0.5 : 0) // 背景的透明度随侧边栏显示或隐藏变化
                    .edgesIgnoringSafeArea(.all)
                    .animation(.easeInOut(duration: 0.3), value: isVisible) // 背景动画
                    .onTapGesture {
                        withAnimation {
                            isVisible = false
                        }
                    }
                
                HStack {
                    SidebarView( toLoginView: $toLoginView)
                        .frame(width: 300)
                        .background(Color.white)
                        .offset(x: isVisible ? 0 : -300) // 控制侧边栏的滑入滑出
                        .shadow(radius: 10)
                        .animation(.easeInOut(duration: 0.3), value: isVisible)
                    
                    Spacer()
                }
                .transition(.move(edge: .leading)) // 侧边栏从左边滑入的过渡效果
            }
        }
    }
}
struct SidebarView: View {
    @AppStorage("avatarImage") private var avatarImageData: Data?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var globalSettings: GlobalSettings
    @Binding var toLoginView:Bool
    var body: some View {
        ZStack{
            VStack {
                HStack{
                    Spacer()
                    Image("babo")
                }
                VStack {
                    Button(action: {
                        self.showingImagePicker = true
                    }) {
                        if let avatarImageData = avatarImageData, let uiImage = UIImage(data: avatarImageData) {
                            ZStack {
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                                    .frame(width: 128, height: 128)
                                    .opacity(0.4)
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 120, height: 120)
                            }
                        } else {
                            ZStack {
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                                    .frame(width: 128, height: 128)
                                    .opacity(0.4)
                                Image("default_headimage")
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 120, height: 120)
                            }
                        }
                    }
                    .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                        ImagePicker(image: self.$inputImage)
                    }
                }
                
                Text("用户名")
                    .font(.title)
                    .bold()
                    .foregroundStyle(Color.white)
                    .padding()
                HStack{
                    Text("设定儿童的使用时长：\(globalSettings.selectedMinute)分钟")
                        .font(.callout)
                        .bold()
                        .foregroundStyle(Color.white)
                        .padding()
                    Spacer()
                }
                Picker(NSLocalizedString("Select Minute", comment: "Select Minute"), selection: $globalSettings.selectedMinute) {
                    ForEach(30..<300) { minute in
                        Text("\(minute) min").tag(minute)
                            .foregroundColor(.white)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .labelsHidden()
                .frame(height: 250)
                
                Spacer()
                Button(action: {
                    toLoginView = true
                }) {
                    Text("退出登录")
                        .bold()
                        .foregroundStyle(Color.white)
                        .padding()
                        .opacity(0.8)
                        .padding(.bottom,20)
                }
            }
        }
        .background(Color.main)
        .edgesIgnoringSafeArea(.vertical)
    }
    func loadImage() {
        guard let inputImage = inputImage else { return }
        avatarImageData = inputImage.pngData()
    }

}

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}
struct parentViewPreviews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            MinutePickerView()
                .environmentObject(TimerManager())
                .environmentObject(GlobalSettings())
        }

    }
}

struct StoryItemView: View {
    var story: Story
    @Binding var selectedStory: Story?
    @Binding var navigateToSelectMan: Bool
    @Binding var intoreadview:Bool
    @Binding var stories: Stories
    @State private var showPopover : Bool = false
    @Binding var tosdView :Bool
    @State private var uiImage: UIImage? = nil
    @State private var height = UIScreen.main.bounds.height
    @State private var width = UIScreen.main.bounds.width

    var body: some View {
        VStack{
            ZStack{
                if let uiImage = uiImage {
                        Button(action: {
                            // 更新选中的 story
                            selectedStory = story
                        }) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: selectedStory?.id == story.id ? 160 : UIScreen.main.bounds.width - 20,
                                       height: selectedStory?.id == story.id ? 200 : 150)
                                .scaleEffect(1.3) // 放大图像
                                .background(Color.main)
                                .clipped() // 裁剪超出部分
                                .cornerRadius(20)
                                .padding(.trailing, selectedStory?.id == story.id ? 180 : 0)
                        }
                    } else {
                        Text("加载中...")
                    }
  
//                .onTapGesture {
//                    intoreadview = true
//                }
                if selectedStory?.id != story.id {
                    Spacer()
                      .frame(width: UIScreen.main.bounds.width-20, height: 150)
                      .background(
                        LinearGradient(
                          stops: [
                            Gradient.Stop(color: Color(red: 0.85, green: 0.85, blue: 0.85).opacity(0), location: 0.00),
                            Gradient.Stop(color: Color(red: 0.94, green: 0.39, blue: 1), location: 1.00),
                          ],
                          startPoint: UnitPoint(x: 0.46, y: 1.25),
                          endPoint: UnitPoint(x: -0.27, y: -0.24)
                        )
                      )
                    
                }
            VStack(alignment: .leading) {
                Text(story.title)
                    .frame(width:selectedStory?.id == story.id ? 170: 250,height: 50, alignment: .bottomLeading)
                    .font(.title2)
                    .foregroundColor(selectedStory?.id == story.id ? .black:.white)
                    .bold()
                    .shadow(radius: 5)
                    .opacity(0.8)
                    .multilineTextAlignment(.leading)
                Text(story.storyintro)
                    .frame(width: selectedStory?.id == story.id ? 170 : 250,height: selectedStory?.id == story.id ? 130:60, alignment: .topLeading)
                    .foregroundColor(selectedStory?.id == story.id ? .black:.white)
                    .shadow(radius: 5)
                    .font(.subheadline)
                    .opacity(0.6)
              }
            .padding(.bottom,selectedStory?.id == story.id ? -10 : 40)
            .padding(.trailing,selectedStory?.id == story.id ? -180 : 80)
           HStack{
               Spacer()
               VStack{
                   Button(action: {
                       // 按钮点击事件
                       showPopover = true
                       //selectedStory = story
                   }) {
                       Image(systemName: "ellipsis")
                           .font(.system(size: 20))
                           .foregroundColor(selectedStory?.id == story.id ? .main: .white)
                           .padding(20)
                   }
                   Spacer()
                   if selectedStory?.id != story.id {
                       Image(systemName: "heart")
                           .font(.system(size: 20))
                           .foregroundColor(.white)
                           .padding(20)
                   }
               }
           }
           .frame(width: UIScreen.main.bounds.width-20, height: selectedStory?.id == story.id ? 220 : 150)
      
            if showPopover{
                VStack(spacing: 0) { // 确保分割线紧贴按钮
                    Button(action: {
                        // 分享操作
                        showPopover = false
                        tosdView = true
                        
                    }) {
                        Label("分享", systemImage: "square.and.arrow.up")
                    }
                    .padding(.vertical, 5)
                    
                    Divider() // 分割线
                    
                    Button(action: {
                        // 删除操作
                        selectedStory = story
                        if let story = selectedStory, let index = stories.stories.firstIndex(where: { $0.id == story.id }) {
                            stories.stories.remove(at: index)
                            stories.save()
                            showPopover = false
                        }
                    }) {
                        Label("删除", systemImage: "trash")
                    }
                    .padding(.vertical, 5)
                }
                .frame(width: 90, height: 70)
                .background(Color.white) // 设置背景色以显示分割线
                .opacity(0.8)
                .cornerRadius(10)

            }

        }
            if selectedStory?.id == story.id {
                HStack{
                    Button(action: {
                        selectedStory = story
                        navigateToSelectMan = true
                    }) {
                        Text(!story.finished ? NSLocalizedString("继续编写", comment: "") : NSLocalizedString("改写故事", comment: "") )
                            .frame(maxWidth: .infinity, maxHeight: 52)
                            .foregroundColor(.white)
                            .background(Color.main)
                            .cornerRadius(30)
                    }
                    Button(action: {
                        intoreadview = true
                    }) {
                        Text(NSLocalizedString("阅读故事", comment: ""))
                            .frame(maxWidth: .infinity, maxHeight: 52)
                            .foregroundColor(.white)
                            .background(!story.finished ? Color.gray : Color.main)
                            .opacity(!story.finished ? 0.6 : 1)
                            .cornerRadius(30)
                            .disabled(!story.finished)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .onAppear {
             loadImage()
            
         }
        .frame(width: UIScreen.main.bounds.width-20, height: selectedStory?.id == story.id ? 300: 150)
        .background(selectedStory?.id == story.id ? Color.white.opacity(0.95) : Color.white)
        .cornerRadius(25)
        .animation(.easeInOut(duration: 0.3), value: selectedStory?.id)
    }
    private func loadImage() {
 
        // 异步加载图片数据
        URLSession.shared.dataTask(with: story.main_image) { data, response, error in
            if let error = error {
                print("加载图片时发生错误: \(error.localizedDescription)")
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                print("无法加载图片数据或转换为 UIImage")
                return
            }
            
            // 在主线程更新 UI
            DispatchQueue.main.async {
                self.uiImage = image
            }
        }.resume()
    }
}
