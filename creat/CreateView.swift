import SwiftUI

struct CreateView: View {
    @Binding var newStory: Story?
    @Binding var stories: Stories
    @State private var navigateToSelectman = false // 添加状态变量以控制导航
    @Environment(\.presentationMode) var presentationMode // 用于返回上一个视图
   
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("back_image")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height) // 使用geo的宽高
                    .offset(x: 0, y: 0) // 调整x和y的值来平移图片位置
                    .ignoresSafeArea(.all)
                    .scaleEffect(1.09)

                Image("bear_sit")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 687, height: 764) // 调整图像大小
                    .position(x: geo.size.width / 1.95, y: geo.size.height * 0.85) // 使用geo的位置进行定位

                VStack {
                    HStack {
                        Image("airplane")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50) // 调整图像大小
                            .padding(.leading, 30)
                        Spacer()
                    }
                    Text(NSLocalizedString("你好!我的朋友，我叫小熊维基。", comment: "小熊页面"))
                     .font(.custom("PingFangSC-Regular", size: 25))
                    .fontWeight(.medium)
                        .lineSpacing(5) // 设置行间距为5
                        .foregroundColor(Color.white)
                        .frame(width: 320, alignment: .topLeading)
                        .padding(.top, 5)
                    
                    Text(NSLocalizedString("欢迎来到“创影”——你的故事，你的舞台！", comment: ""))
                        .font(.custom("PingFangSC-Regular", size: 25))
                        .fontWeight(.medium)
                        .lineSpacing(5) // 设置行间距为5
                        .foregroundColor(Color(red: 1, green: 0.8, blue: 0.61))
                        .frame(width: 318, alignment: .topLeading)
                        .padding(.top, 3)
                    Spacer()
                }
                VStack{
                    Spacer()
                    Button(NSLocalizedString("我要写故事！", comment: "")) {
                        let newCharacter = Character(name: NSLocalizedString("王子", comment: ""), characlass: NSLocalizedString("王子", comment: ""), introduction: NSLocalizedString("我是一名爱好看书、乐于助人的王子", comment: ""), hobby: NSLocalizedString("蓝色的眼睛、红色头发", comment: ""), personality: NSLocalizedString("乐于助人", comment: ""), ability: NSLocalizedString("善于剑术", comment: ""), classnum: 1, persontype: 0, maincharacter: true, sex: true)
                        newStory?.characters.characters.append(newCharacter)
                        if let story = newStory {
                            if let index = stories.stories.firstIndex(where: { $0.id == story.id }) {
                                stories.stories[index] = story
                            } else {
                                stories.stories.append(story)
                            }

                            stories.save() // 保存 stories 到 UserDefaults

                            navigateToSelectman = true // 设置导航状态为 true
                        }
                    }
                    .font(Font.custom("SF Pro", size: 20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 66)
                    .background(Color.sub)
                    .cornerRadius(33)
                    .padding(.horizontal)
                    .shadow(radius: 10)
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack{
                        CustomBackButton()
                        Text("创建故事")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToSelectman) {
                SelectMan(selectedStory: $newStory, stories: $stories) // 导航到 selectman 界面
            }
        }
    }

}

struct CreateView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreateView(newStory: .constant(nil), stories: .constant(Stories()))
        }
    }
}
