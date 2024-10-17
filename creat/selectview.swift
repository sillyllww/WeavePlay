import SwiftUI

struct selectview: View {
    @Binding var selectedStory: Story?
    @Binding var stories: Stories
    @StateObject private var chatBot = ChatBot()
    @State private var selectedRectangle: Int? = nil
    let titles = [NSLocalizedString("城堡", comment: ""), NSLocalizedString("森林", comment: ""), NSLocalizedString("村庄", comment: ""), NSLocalizedString("海洋", comment: ""), NSLocalizedString("沙漠", comment: ""), NSLocalizedString("雪山", comment: "")]

    var body: some View {
        ZStack {
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
            VStack {
                Spacer()
                
                // 圆角长方形容器
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white.opacity(0.6)) // 透明颜色
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: 630) // 调整宽度和高度
                    .overlay(
                        VStack {
                            ScrollView {
                                LazyVGrid(columns: [GridItem(), GridItem()], spacing: 20) {
                                    ForEach(titles.indices, id: \.self) { index in
                                        SenceView(title: titles[index], isSelected: index == selectedRectangle, num: index)
                                            .onTapGesture {
                                                selectedRectangle = index
                                                updateSelectedStoryScene(with: titles[index])
                                                saveSelectedStory()
                                            }
                                    }
                                }
                                .padding(.top,10)
                                            
                            }
                            .padding()
                            .cornerRadius(30)
                        }
                    )
                    .padding(.bottom,50)
                
                Spacer()
            }
            VStack {
                Spacer()
                RoundedButton(title: NSLocalizedString("下一步", comment: ""), destination: AnyView(selectplots(selectedStory: $selectedStory, stories: $stories)))
                    .padding(.bottom, 40)
                    .shadow(radius: 10)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack{
                    CustomBackButton()
                    Text("选择场景")
                        .font(.title2)
                        .foregroundColor(.white)
                        
                }
            }
           
        }
        .onAppear {
            if let scene = selectedStory?.scene, let index = titles.firstIndex(of: scene) {
                selectedRectangle = index
            }        
            let newPlot = Plot(
                storyText: "",
                imageUrl: URL(string: "https://example.com/image.jpg")!, // 示例 URL
                characterUrls: [],
                characters: [],
                location: [1,1],
                dialog: [],
                isturn: [],
                turninfo: [],
                plotchose: [PlotChoice(perPlot: NSLocalizedString("夜幕降临，王子走出城堡，手持一把闪亮的剑，漫步在星空下。他回想起之前在书中学到的剑术，正当他沉浸在思考中时，一名神秘的来客出现在他面前，声称有重要的警告。", comment: ""), perCharacter: [NSLocalizedString("林克王子", comment: ""), NSLocalizedString("艾尔德里克骑士", comment: "")], perdialog: [NSLocalizedString("王子，快看！我在城外发现了敌兵的动向！", comment: ""), NSLocalizedString("我们必须立刻行动，保护我们的王国！", comment: "")])], 
                plotchoseindex: 0,
                promotechara: [],
                promote: ""
            )
            selectedStory!.plots.plots.append(newPlot)
            saveSelectedStory()
        }
    }
    
    private func updateSelectedStoryScene(with scene: String) {
        if let selectedStory = selectedStory {
            var updatedStory = selectedStory
            updatedStory.scene = scene
            self.selectedStory = updatedStory
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

struct SenceView: View {
    var title: String
    var isSelected: Bool
    var num: Int
    var body: some View {
        ZStack {
            Image("scene\(num)")
                .resizable()
                .scaledToFit()
                .scaleEffect(2)
                .position(x:100,y: 170)
            RoundedRectangle(cornerRadius: 30)
                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/,height: 30)
                .opacity(0.6)
                .position(x:120,y: 30)
            Text(title)
                .foregroundColor(.white)
                .font(.headline)
                .position(x:120,y: 30)
            if isSelected {
                Image("selected")
            }
        }
        .frame(width: 156, height: 180)
        .cornerRadius(15)
        .opacity(isSelected ? 1.0 : 0.8)
    }
}

#Preview {    selectview(selectedStory: .constant(Story(id: UUID(), title: "示例故事", characters: Characters(), scene: "", plots: Plots(), plot1: "", plot2: "", plot3: "", topic: [], storyintro: "", storyimage: [], finished: false,allcharacterUrls:[], allcharacters: [])), stories: .constant(Stories()))
}
