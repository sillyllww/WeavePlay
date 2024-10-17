//import SwiftUI
//
//struct ContentView: View {
//    @State private var selectedTab = 0
//    @State private var stories = Stories.load() // 管理多个故事
//    @State private var newStory: Story? = nil // 新故事
//    @State private var navigateToCreateView = false
//    @EnvironmentObject var globalSettings: GlobalSettings
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Image("back_image")
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//                    .offset(x: 0, y: 0) // 调整x和y的值来平移图片位置
//                    .ignoresSafeArea(.all)
//                    .scaleEffect(1.009)
//                LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.0), Color.background.opacity(1)]),
//                               startPoint: UnitPoint(x: 0.5, y: 0.2), endPoint: UnitPoint(x: 0.5, y: 0.6))
//                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//                    .ignoresSafeArea(.all)
//
//                switch selectedTab {
//                case 0:
//                    HomeView(stories: $stories) // 传递 stories 绑定
//                case 1:
//                    StorytellingView()
//                default:
//                    Text("首页")
//                }
//
//                VStack {
//                    Spacer()
//                    CircularButton(newStory: $newStory, navigateToCreateView: $navigateToCreateView) // 传递状态变量
//                        .padding(.bottom, -20)
//                        .shadow(radius: 3)
//
//                    CustomTabBar(selectedTab: $selectedTab, tabItems: [
//                        (title: "阅读故事", image: "book"),
//                        (title: "演绎故事", image: "film")
//                    ])
//                }
//                .padding(.bottom, 65)
//            }
//            .navigationDestination(isPresented: $navigateToCreateView) {
//                if let story = newStory {
//                    
//                }
//            }
//        }
//    }
//}
//
//struct CircularButton: View {
//    @Binding var newStory: Story?
//    @Binding var navigateToCreateView: Bool
//    @EnvironmentObject var globalSettings: GlobalSettings
//    var body: some View {
//        Button(action: {
//            let topics = globalSettings.textPositions.map { $0.text }
//            let story = Story(title: "未创建", characters: Characters(), scene: "",plots:Plots(), plot1: "", plot2: "", plot3: "", topic: topics, storyintro: "小朋友，这个故事还未创建完成哦，点击按钮继续创建故事吧", storyimage: [], main_image: "main_image", finished: false,allcharacterUrls:[], allcharacters: [])
//            newStory = story
//            navigateToCreateView = true
//        }) {
//            ZStack {
//                Circle()
//                    .fill(LinearGradient(
//                        gradient: Gradient(stops: [
//                            Gradient.Stop(color: Color(red: 0.47, green: 0.32, blue: 0.92), location: 0.00),
//                            Gradient.Stop(color: Color(red: 0.96, green: 0.58, blue: 1), location: 1.00),
//                        ]),
//                        startPoint: UnitPoint(x: 0.23, y: -0.12),
//                        endPoint: UnitPoint(x: 0.82, y: 1.1)
//                    ))
//                    .frame(width: 90, height: 90)
//
//                Image(systemName: "plus")
//                    .font(.system(size: 50))
//                    .foregroundColor(.white)
//            }
//        }
//    }
//}
//
//
//struct CustomTabBar: View {
//    @Binding var selectedTab: Int
//    let tabItems: [(title: String, image: String)]
//
//    var body: some View {
//        HStack {
//            ForEach(0..<tabItems.count, id: \.self) { index in
//                Spacer()
//                VStack {
//                    Image(systemName: tabItems[index].image)
//                        .font(.system(size: 32))
//                        .foregroundColor(selectedTab == index ? .main : .gray)
//                        .padding(0.5)
//
//                    Text(tabItems[index].title)
//                        .font(.system(size: 12))
//                        .foregroundColor(selectedTab == index ? .main : .gray)
//                }
//                .onTapGesture {
//                    selectedTab = index
//                }
//                Spacer()
//            }
//        }
//        .padding(.top, 10)
//        .padding(.horizontal, -20)
//        .background(
//            Image("Subtract")
//                .resizable()
//                .padding(.horizontal, 20)
//                .frame(width: 408, height: 94)
//                .shadow(radius: 5)
//        )
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//
//
//    }
//}
