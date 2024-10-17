import SwiftUI

struct SelectMan: View {
    @Binding var selectedStory: Story?
    @Binding var stories: Stories
    @State private var nextCharacterNumber = 2
    @State private var showAddCharacterSheet = false
    @State private var selectedCharacter: Character?
    @State private var navigateToCharacterDetail = false
    @StateObject private var chatBot = ChatBot()
    @State private var showAlert = false
    @Environment(\.presentationMode) var presentationMode

    let characterTypes = [NSLocalizedString("王子", comment: ""), NSLocalizedString("公主", comment: ""), NSLocalizedString("皇后", comment: ""), NSLocalizedString("国王", comment: ""), NSLocalizedString("平民", comment: ""), NSLocalizedString("骑士", comment: "")]

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
                                LazyVGrid(columns: [GridItem(), GridItem()]) {
                                    ForEach(selectedStory?.characters.characters ?? []) { character in
                                        CharacterView(character: character, deleteAction: {
                                            if let index = selectedStory?.characters.characters.firstIndex(where: { $0.id == character.id }) {
                                                selectedStory?.characters.characters.remove(at: index)
                                                saveStory()
                                            }
                                        }, selectAction: {
                                            selectedCharacter = character
                                            navigateToCharacterDetail = true
                                        })
                                    }
                                    addCharacterButton
                                }
                            }
                            .padding()
                            .cornerRadius(30)
                        }
                    )
                    .padding(.bottom, 50)

                Spacer()
            }

            VStack {
                Spacer()
                RoundedButton(title: NSLocalizedString("下一步", comment: ""), destination: AnyView(selectview(selectedStory: $selectedStory, stories: $stories)))
                    .padding(.bottom, 40)
                    .shadow(radius: 10)
            }
            if let isEmpty = selectedStory?.characters.characters.isEmpty, isEmpty {
                VStack {
                    Spacer()
                    ZStack {
                        Image("bear_tip")
                            .scaleEffect(0.8)
                            .padding(.trailing, -100)
                            .padding(.bottom, 100)
                            .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        Text(NSLocalizedString("小朋友还没有创建角色哦，点击上面的加号创建一个故事吧。", comment: ""))
                            .foregroundStyle(Color.gray)
                            .frame(width: 250)
                            .lineSpacing(10.0)
                            .tracking(0.5)
                            .padding(.trailing, -50)
                            .padding(.bottom, 240)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack{
                    CustomBackButton()
                    Text("选择角色")
                        .font(.title2)
                        .foregroundColor(.white)
                        
                }
            }
           
        }

        .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(NSLocalizedString("确认删除", comment: "")),
                        message: Text(NSLocalizedString("确定要删除这个故事吗？", comment: "")),
                        primaryButton: .destructive(Text(NSLocalizedString("删除", comment: ""))) {
                            if let story = selectedStory, let index = stories.stories.firstIndex(where: { $0.id == story.id }) {
                                stories.stories.remove(at: index)
                                stories.save()
                                presentationMode.wrappedValue.dismiss() // 返回到上一个视图
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
        .overlay(
            addCharacterSheetOverlay
        )
        .background(
            NavigationLink(
                destination: characterDetailView,
                isActive: $navigateToCharacterDetail,
                label: {
                    EmptyView()
                }
            )
        )
    }

    var addCharacterButton: some View {
        Button(action: {
            showAddCharacterSheet = true
        }) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 90, height: 90)
                Image(systemName: "plus")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            .frame(width: 150, height: 180)
        }
    }

    var addCharacterSheetOverlay: some View {
        Group {
            if showAddCharacterSheet {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showAddCharacterSheet = false
                        }
                    }
                VStack {
                    Text(NSLocalizedString("选择角色类别", comment: ""))
                        .font(.headline)
                        .padding(2)
                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        ForEach(1...6, id: \.self) { index in
                            Button(action: {
                                addCharacter(ofType: characterTypes[index-1], classnum: index)
                                withAnimation {
                                    showAddCharacterSheet = false
                                }
                            }) {
                                characterTypeButton(for: index)
                            }
                        }
                    }
                    .padding(10)
                }
                .frame(width: 350, height: 700)
                .background(Color.background)
                .cornerRadius(20)
                .shadow(radius: 10)
                .transition(.scale)
            }
        }
    }

    func characterTypeButton(for index: Int) -> some View {
        ZStack {
            Ellipse()
                .fill(Color(red: 229/255, green: 230/255, blue: 255/255))
                .frame(width: 189, height: 189)
                .offset(x: -30, y: 50) // 偏移图片的位置
            Ellipse()
                .fill(Color(red: 173/255, green: 179/255, blue: 255/255))
                .frame(width: 143, height: 143)
                .offset(x: -30, y: 50) // 偏移图片的位置
            Image("category\(index)")
                .resizable()
                .frame(width: 150, height: 150)
                .offset(x: 0, y: 20) // 偏移图片的位置
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 229/255, green: 230/255, blue: 255/255))
                .frame(width: 100, height: 20)
                .offset(x: 40, y: -65) // 偏移图片的位置
            Text(characterTypes[index-1])
                .font(.headline)
                .foregroundColor(.main)
                .offset(x: 35, y: -65)
        }
        .frame(maxWidth: 150, minHeight: 180)
        .background(Color.white)
        .cornerRadius(25)
        .padding(.top, 10)
    }

    func addCharacter(ofType type: String, classnum: Int) {
        
        let newCharacter = Character(name: type, characlass: type, introduction: NSLocalizedString("我是一名爱好看书、乐于助人的王子", comment: ""), hobby: NSLocalizedString("蓝色的眼睛、红色头发", comment: ""), personality: NSLocalizedString("乐于助人", comment: ""), ability: NSLocalizedString("善于剑术", comment: ""), classnum: classnum, persontype: 0, maincharacter: false, sex: true)
        selectedStory?.characters.characters.append(newCharacter)
        saveStory()
        selectedCharacter = newCharacter
        navigateToCharacterDetail = true
        nextCharacterNumber += 1
    }

    // 定义一个计算属性 characterDetailView，它返回一个包含角色详情的视图
    var characterDetailView: some View {
        Group {
            // 检查是否有选中的角色和角色的绑定
            if let character = selectedCharacter, let binding = binding(for: character) {
                // 如果有，则返回 CharacterDetailView，传入角色的绑定和保存操作的闭包
                CharacterDetailView(character: binding, stories: $stories, selectedStory: $selectedStory, saveAction: {
                    if let index = stories.stories.firstIndex(where: { $0.id == selectedStory?.id }) {
                                        selectedStory = stories.stories[index]
                                    }
                    saveStory()
                }, chatBot: chatBot)
            } else {
                // 如果没有，则显示“Character not found”提示
                Text("Character not found")
                    .foregroundColor(.red)
            }
        }
    }

    // 这个函数返回一个绑定到特定角色的 Binding<Character> 对象
    func binding(for character: Character) -> Binding<Character>? {
        // 检查是否有选中的故事
        guard let selectedStory = selectedStory else {
            print("Error: Selected story is nil")
            return nil
        }
        // 找到选中故事在 stories 数组中的索引
        guard let storyIndex = stories.stories.firstIndex(where: { $0.id == selectedStory.id }) else {
            print("Error: Story not found")
            return nil
        }
        // 找到选中角色在选中故事的角色数组中的索引
        guard let characterIndex = stories.stories[storyIndex].characters.characters.firstIndex(where: { $0.id == character.id }) else {
            print("Error: Character not found")
            return nil
        }
        // 返回一个绑定对象，绑定到选中角色
        return Binding<Character>(
            get: { stories.stories[storyIndex].characters.characters[characterIndex] },
            set: { stories.stories[storyIndex].characters.characters[characterIndex] = $0 }
        )
    }

    // 这个函数用于保存当前选中故事的更改
    func saveStory() {
        // 找到选中故事在 stories 数组中的索引
        if let storyIndex = stories.stories.firstIndex(where: { $0.id == selectedStory?.id }), let story = selectedStory {
            // 更新 stories 数组中的故事
            stories.stories[storyIndex] = story
            // 保存 stories 数组的更改
            stories.save()
        }
    }

}



struct CharacterView: View {
    var character: Character
    var deleteAction: () -> Void
    var selectAction: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            Button(action: {
                selectAction()
            }) {
                characterDetail
                
            }

            deleteButton
        }
    }

    var characterDetail: some View {
        ZStack{
            ZStack {
                
                Ellipse()
                    .fill(Color(red: 229/255, green: 230/255, blue: 255/255))
                    .frame(width: 189, height: 189)
                    .offset(x: -30, y: 50) // 偏移图片的位置
                Ellipse()
                    .fill(Color(red: 173/255, green: 179/255, blue: 255/255))
                    .frame(width: 143, height: 143)
                    .offset(x: -30, y: 50) // 偏移图片的位置
                Image("category\(character.classnum)")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .offset(x: 0, y: 20) // 偏移图片的位置
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 229/255, green: 230/255, blue: 255/255))
                    .frame(width: 100, height: 20)
                    .offset(x: 40, y: -65) // 偏移图片的位置
                Text(character.name)
                    .font(.headline)
                    .foregroundColor(.main)
                    .offset(x: 35, y: -65)
            }
            .frame(maxWidth: 150, minHeight: 180)
            .background(Color.white)
            .cornerRadius(20)
            .padding(.top, 10)
            if character.maincharacter{
                Image("main_character")
                    .frame(width: 150,height: 180)
                    .offset(x: -18, y: 32)
            }
                
           
        }
    }

    var deleteButton: some View {
        Button(action: {
            deleteAction()
        }) {
            Image(systemName: "trash.circle")
                .font(.system(size: 30))
                .offset(x: -10, y: 1) // 偏移图片的位置
                .foregroundColor(.main)
                .padding(5)
        }
    }
}


