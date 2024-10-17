import SwiftUI

struct HomeView: View {
    @AppStorage("userName") private var userName: String = NSLocalizedString("小小读者", comment: "")
    @AppStorage("avatarImage") private var avatarImageData: Data?
    @AppStorageArray(key: "titlesUnlocked", defaultValue: Array(repeating: false, count: 8)) private var titlesUnlocked: [Bool]
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var selectedStory: Story?
    @State private var navigateToSelectMan = false
    @State private var navigateToCreateView = false
    @State private var title:[String]=[NSLocalizedString("新手读者", comment: ""),"初级读者","中级读者","高级读者","出神入化","巅峰读者","？？？？?","你无敌了"]
    @State private var intoreadview:Bool = false
    @State private var maintopic:Bool = false
    @EnvironmentObject var globalSettings: GlobalSettings
    @State private var stories = Stories.load() // 管理多个故事
    @State private var newStory: Story? = nil // 新故事
    @State private var tosdView: Bool = false
   
    @State private var height = UIScreen.main.bounds.height
    @State private var width = UIScreen.main.bounds.width
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // 背景图片
                    ZStack {
                        Image("back_image")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .scaleEffect(1.2)
                        VStack{
                            HStack{
                                
                                Image("bear_side")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60)
                                Spacer()
                                VStack{
                                    TextField("小小读者", text: $userName)
                                        .bold()
                                        .font(.title2)
                                        .foregroundStyle(Color.white)

                                    Text("来读故事吧!")
                                        .bold()
                                        .font(.title2)
                                        .foregroundStyle(Color.white)
                                }
                                .frame(width: 120)
                                Spacer()
                                ZStack{
                                    Image("top_side")
                                        .resizable()
                                        .scaledToFit()
                                        .offset(x:0,y: -8)
                                    HStack{
                                        ZStack{
                                            Image("bear_level")
                                            Text("我的等级")
                                                .font(.caption)
                                                .offset(x:0,y: 18)
                                                .bold()
                                                .opacity(0.6)
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 7) {
                                                ForEach(0..<8) { index in
                                                    if !titlesUnlocked[index] {
                                                        ZStack {
                                                            Image("epithet")
                                                                .resizable()
                                                                .saturation(0)
                                                            
                                                                .scaledToFit()
                                                                .frame(width: 70, height: 18)
                                                                .opacity(0.6)
                                                            Image(systemName: "lock.fill")
                                                                .foregroundColor(.white)
                                                                .font(.system(size: 15))
                                                                .opacity(0.5)
                                                        }
                                                    } else {
                                                        ZStack {
                                                            Image("epithet")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 70, height: 18)
                                                            HStack {
                                                                Image(systemName: "star.circle")
                                                                    .font(.system(size: 13))
                                                                    .foregroundColor(.mark)
                                                                    .frame(width: 7)
                                                                Text(title[index])
                                                                    .font(.caption2)
                                                                    .fontWeight(.bold)
                                                                    .foregroundColor(.mark)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            .frame(width: 140)
                                            .padding(.bottom)
                                            .padding(.horizontal)
                                            
                                        }
                                        
                                        VStack{
                                            TimeView()
                                                .padding(.bottom)

                                            HStack{
                                                VStack{
                                                    Text("阅读故事，领取积分")
                                                        .font(.caption2)
                                                        .foregroundStyle(Color.black.opacity(0.5))
                                                    ProgressView(value: Double(600), total: Double(1000))
                                                        .progressViewStyle(CustomProgressViewStyle())
                                                    Text("距离下一个等级还差60个金币")
                                                        .font(.caption2)
                                                        .foregroundStyle(Color.black.opacity(0.5))
                                                }

                                                Image("glod")
                                                Text("600")
                                                    .bold()
                                                    .opacity(0.7)
                                            }
                                            .padding(.bottom)
                                        }
                       
                                        Spacer()
                                    }
                                    .frame(width: 545)
                                }
                                .frame(width: 550)
                               Spacer()
                                HStack {
                                    Button(action: {
                                        maintopic = true
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 30)
                                                .frame(width: 83, height: 40)
                                                .foregroundColor(.main)
                                                .shadow(radius: 3)
                                            HStack {
                                                Spacer()
                                                Image(systemName: "repeat")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 20))
                                                Image("change_parent")
                                                    .padding(.trailing, 2)
                                            }
                                        }
                                        
                                    }
                                }
                                .frame(width: 83, height: 40)
                                .padding(.bottom,30)
                                

                            }
                            
                            Spacer()
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 30) {
                                        Spacer(minLength: 20)
                                        ForEach(stories.stories) { story in
                                            Button(action: {
                                                selectedStory = story
                                                if story.finished{
                                                    intoreadview = true
                                                }
                                            }) {
                                                VStack {
                                                    // 显示故事的图片
                                                    ZStack{
                                                        Image("book")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 150)
                                                        ZStack{
                                                            if story.plots.plots.count > 0 {
                                                                AsyncImage(url: story.plots.plots[0].imageUrl) { image in
                                                                    image
                                                                        .resizable()
                                                                        .scaledToFill()
                                                                        .scaleEffect(1.2)
                                                                        .frame(width: 143, height: 179)
                                                                        .offset(x: 10, y: 10)
                                                                        .mask(CustomRoundedRectangle(topLeft: 32, topRight: 6, bottomLeft: 24, bottomRight: 7))
                                                                } placeholder: {
                                                                }
                                                            }
                                                            AsyncImage(url: story.main_image) { image in
                                                                image
                                                                    .resizable()
                                                                    .aspectRatio(contentMode: .fill)
                                                                    .frame(width: 143, height: 179)
                                                                    .offset(x:10,y: 10)
                                                                    .mask(CustomRoundedRectangle(topLeft: 32, topRight: 6, bottomLeft: 24, bottomRight: 7))
                                                            } placeholder: {
                                                                ProgressView()
                                                                    .frame(width: 150, height: 150)
                                                            }
                                                        }

                                                        
                                                        Image("book_open")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 150)
                                                    }
                                                    .clipped(antialiased: true)

                                                    // 显示标题
                                                    Text(story.title)
                                                        .font(.caption)
                                                        .foregroundColor(.white)
                                                        .multilineTextAlignment(.center)
                                                        
                                                        .frame(width: 140, height: 20, alignment: .center)
                                                        .background(Color.main)
                                                        .cornerRadius(10)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 10) // 边框的圆角与背景的圆角一致
                                                                .stroke(Color.white, lineWidth: 1) // 边框的颜色和宽度
                                                        )
                                                        .padding(.top, 10)

                                                }
                                                .frame(width: 150) // 每个 story 的宽度
                                                .shadow(radius: 10)
                                                .opacity(story.finished ? 1:0.6)
                                            }
                                            .buttonStyle(PlainButtonStyle()) // 去除默认按钮样式
                                        }
                                        Spacer(minLength: 150)
                                    }
                                    .padding() // 在 HStack 周围添加内边距
                        }.padding(.top,120)
                       
//                        ScrollView {
//                            VStack {
//                                Spacer(minLength: 80)
//
                              
  
//                                    Spacer()

//                                    }
//                                }
//                                .padding(.horizontal)
//

//
//                                ForEach(stories.stories) { story in
//                                    //放置故事
//    
//                                    
//                                }
//                                VStack {
//                                    Spacer(minLength: 300)
//                                    Text("底下什么都没有了哦")
//                                        .opacity(0.2)
//                                }
//                            }
//                        }
                    }
                }
                .navigationDestination(isPresented: $navigateToSelectMan) {
                    if selectedStory != nil {
                        SelectMan(selectedStory: $selectedStory, stories: $stories)
                    }
                }
                .navigationDestination(isPresented: $intoreadview) {
                    if selectedStory != nil {
                        Readview(selectedStory: $selectedStory, stories: $stories)
                    }
                }
                .navigationDestination(isPresented: $maintopic) {
                    MinutePickerView()
                }
                .navigationDestination(isPresented: $tosdView) {
                    sdView()
                }
                .navigationBarHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.main.opacity(0.5), for: .navigationBar)
                .ignoresSafeArea(.all)
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
 
        }

    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        avatarImageData = inputImage.pngData()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            parent.image = info[.originalImage] as? UIImage
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}
}
@propertyWrapper

struct AppStorageArray<T: Codable> {
    let key: String
    let defaultValue: [T]
    
    var wrappedValue: [T] {
        get {
            guard let data = UserDefaults.standard.data(forKey: key) else {
                return defaultValue
            }
            let value = try? JSONDecoder().decode([T].self, from: data)
            return value ?? defaultValue
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

class TimerManager: ObservableObject {
    @Published var timeElapsed = 0
    @Published var showAlert10Min = false
    @Published var showAlert30Min = false
    private var timer: Timer?
 
    init() {
        startTimer()
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.timeElapsed += 1
            if self.timeElapsed == 1200 { // 20分钟
                self.showAlert10Min = true
            } else if self.timeElapsed == 1800 { // 30分钟
            }
        }
    }

    func timeString(time: Int) -> String {
        let minutes = time / 60
        return String(format: "%2d", minutes)
    }
}

struct TimeView: View {
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var globalSettings: GlobalSettings
    var body: some View {
        HStack {
            Text("今天阅读时长")
                .font(.caption2)
                .foregroundStyle(.black.opacity(0.6))
            ProgressView(value: Double(timerManager.timeElapsed), total: Double(globalSettings.selectedMinute * 60))
                .progressViewStyle(CustomProgressViewStyle())
            Text("\(timerManager.timeString(time: timerManager.timeElapsed))分钟")
                .font(.caption2)
                .foregroundStyle(.black.opacity(0.6))
            if timerManager.timeElapsed == globalSettings.selectedMinute * 60{
                Text("")
                    .onAppear(perform: Closeapp)
            }
        }
        .alert(isPresented: $timerManager.showAlert10Min) {
            Alert(
                title: Text("提醒"),
                message: Text("您已经使用了20分钟"),
                dismissButton: .default(Text("好的"))
            )
        }
        .alert(isPresented: $timerManager.showAlert30Min) {
            Alert(
                title: Text("提醒"),
                message: Text("今日使用上限已达，应用即将退出"),
                dismissButton: .default(Text("退出"), action: {
                    exit(0)
                })
            )
        }
    }
    func Closeapp(){
        //timerManager.showAlert30Min = true
    }
}
struct CustomProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.yellowcus.opacity(0.3))
                .frame(height: 8) // 设置背景的高度
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.yellowcus)
                .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * 300, height: 8) // 设置进度条的高度和宽度
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(TimerManager())
            .environmentObject(GlobalSettings())
            
    }
}
