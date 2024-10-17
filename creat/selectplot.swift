//import SwiftUI
//
//struct selectplot: View {
//    @Binding var selectedStory: Story?
//    @Binding var stories: Stories
//    @StateObject private var chatBot = ChatBot()
//    @State private var selectedSegment = 0
//    @State private var navigateToStoryOverview = false // 添加状态变量以控制导航
//    @State private var selectedRectangle: Int? = 0
//    let titles = ["权利压迫", "意外惊喜", "家庭危机", "时间循环", "突发灾难"]
//    @State private var selectedRectangle1: Int? = 0
//    let titles1 = ["团结的力量", "最终的对决", "克服自我怀疑", "揭示隐藏的真相", "牺牲与救赎"]
//    @State private var selectedRectangle2: Int? = 0
//    let titles2 = ["幸福婚礼", "教训学习", "继续冒险", "无奈的分离", "宽恕与和解"]
//
//    var body: some View {
//        ZStack {
//            // 背景图片
//            Image("back_image")
//                .resizable()
//                .scaledToFill()
//                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//                .offset(x: 0, y: 0) // 调整x和y的值来平移图片位置
//                .ignoresSafeArea(.all)
//                .scaleEffect(1.009)
//            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.0), Color.background.opacity(1)]),
//                           startPoint: UnitPoint(x: 0.5, y: 0.2), endPoint: UnitPoint(x: 0.5, y: 0.6))
//                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//                .ignoresSafeArea(.all)
//            VStack {
//                Spacer()
//                ZStack{
//                    Image("bear_plot")
//                    VStack(alignment: .leading){
//                        Text(selectedSegment == 0 ? "故事情节-冲突" : selectedSegment == 1 ? "故事情节-高潮" : "故事情节-结尾")
//                            .font(.title3)
//                            .padding(.bottom,8)
//                            .foregroundColor(.white)
//                            .fontWeight(.medium)
//                        Text(selectedSegment == 0 ? "故事中的冲突是推动情节发展和塑造角色的关键元素。" : selectedSegment == 1 ? "故事的高潮部分是情节最为紧张和激动人心的时刻，通常也是故事中最重要的转折点。" : "故事的结尾也是一个很好的机会来强化故事的主题和信息。")
//                            .font(.subheadline)
//                            .foregroundColor(.white)
//                    }
//                    .frame(width: 200)
//                    .padding(.trailing,130)
//                }
//
//                // 圆角长方形容器
//                ZStack{
//                    
//                    RoundedRectangle(cornerRadius: 25)
//                        .fill(Color.white.opacity(0.6)) // 透明颜色
//                    VStack {
//                        Picker("Select a page", selection: $selectedSegment) {
//                            Text("冲突").tag(0)
//                            Text("高潮").tag(1)
//                            Text("结尾").tag(2)
//                        }
//                        .pickerStyle(SegmentedPickerStyle())
//                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
//                        
//                        
//                        
//
//                        TabView(selection: $selectedSegment) {
//                            VStack{  ForEach(titles.indices, id: \.self) { index in
//                                SenceView1(title: titles[index], isSelected: index == selectedRectangle)
//                                    .onTapGesture {
//                                        selectedRectangle = index
//                                        updateSelectedStoryplot1(with: titles[index])
//                                        saveSelectedStory()
//                                    }
//                            }.padding(.bottom,10)
//                            }
//                                .tag(0)
//                                .tabItem { EmptyView() } // Hide tab item
//
//                            VStack{  ForEach(titles1.indices, id: \.self) { index in
//                                SenceView1(title: titles1[index], isSelected: index == selectedRectangle1)
//                                    .onTapGesture {
//                                        selectedRectangle1 = index
//                                        updateSelectedStoryplot2(with: titles1[index])
//                                        saveSelectedStory()
//                                    }
//                            }.padding(.bottom,10)
//                            }
//                                .tag(1)
//                                .tabItem { EmptyView() } // Hide tab item
//
//                            VStack{  ForEach(titles2.indices, id: \.self) { index in
//                                SenceView1(title: titles2[index], isSelected: index == selectedRectangle2)
//                                    .onTapGesture {
//                                        selectedRectangle2 = index
//                                        updateSelectedStoryplot3(with: titles2[index])
//                                        saveSelectedStory()
//                                    }
//                            }.padding(.bottom,10)
//                            }
//                                .tag(2)
//                                .tabItem { EmptyView() } // Hide tab item
//                        }
//                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//                    }
//                }
//                .frame(width: UIScreen.main.bounds.width * 0.9, height: 530) // 调整宽度和高度
//                Spacer(minLength: 130)
//            }
//            VStack {
//                Spacer()
//                Button(selectedSegment == 0 ? "设置高潮" : selectedSegment == 1 ? "设置结尾" : "下一步") {
//                    if selectedSegment == 0{selectedSegment = 1}
//                    else if selectedSegment == 1{selectedSegment = 2}
//                    else{navigateToStoryOverview = true }// 设置导航状态为 true
//                }
//                .font(Font.custom("SF Pro", size: 20))
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity, minHeight: 66)
//                .background(Color.sub)
//                .cornerRadius(33)
//                .padding(.horizontal)
//                .shadow(radius: 10)
//                .offset(x: 0, y: -55)
//            }
//        }
//        .navigationBarBackButtonHidden(true) // 移动到视图内部
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                HStack{
//                    CustomBackButton()
//                    Text("选择情节")
//                        .font(.title)
//                        .foregroundColor(.white)
//                        .padding(.horizontal,84)
//                }
//            }
//        }
//        .navigationDestination(isPresented: $navigateToStoryOverview) {
//            
//            GenerateName(selectedStory: $selectedStory, stories: $stories, chatBot: ChatBot()) 
//        }
//        .onAppear {
//            if let plot1 = selectedStory?.plot1, let index = titles.firstIndex(of: plot1) {
//                selectedRectangle = index
//                print(plot1)
//            }
//            if let plot2 = selectedStory?.plot2, let index = titles1.firstIndex(of: plot2) {
//                selectedRectangle1 = index
//            }
//            if let plot3 = selectedStory?.plot3, let index = titles2.firstIndex(of: plot3) {
//                selectedRectangle2 = index
//            }
//        }
//    }
//
//    private func updateSelectedStoryplot1(with plot1: String) {
//        if let selectedStory = selectedStory {
//            var updatedStory = selectedStory
//            updatedStory.plot1 = plot1
//            self.selectedStory = updatedStory
//        }
//    }
//    private func updateSelectedStoryplot2(with plot2: String) {
//        if let selectedStory = selectedStory {
//            var updatedStory = selectedStory
//            updatedStory.plot2 = plot2
//            self.selectedStory = updatedStory
//        }
//    }
//    private func updateSelectedStoryplot3(with plot3: String) {
//        if let selectedStory = selectedStory {
//            var updatedStory = selectedStory
//            updatedStory.plot3 = plot3
//            self.selectedStory = updatedStory
//        }
//    }
//
//    private func saveSelectedStory() {
//        if let selectedStory = selectedStory {
//            if let index = stories.stories.firstIndex(where: { $0.id == selectedStory.id }) {
//                stories.stories[index] = selectedStory
//                stories.save()
//            }
//        }
//    }
//}
//struct SenceView1: View {
//    var title: String
//    var isSelected: Bool
//    
//    var body: some View {
//        ZStack {
//            Rectangle()
//                .fill(isSelected ? Color.main : Color.white)
//                .frame(width: 327, height: 74)
//                .cornerRadius(20)
//                .opacity(isSelected ? 1.0 : 0.8)
//            Image("plot_left")
//            Text(title)
//                .foregroundColor(isSelected ? Color.white : Color.gray)
//                .font(.title2)
//        
//        }
//    }
//}
//
//#Preview {
//    selectplot(selectedStory: .constant(Story(id: UUID(), title: "示例故事", characters: Characters(), scene: "", plots: Plots(), plot1: "", plot2: "", plot3: "", topic: [], storyintro: "", storyimage: [], main_image: "", finished: false)), stories: .constant(Stories()))
//}
