import SwiftUI
import Combine

struct CharacterDetailView: View {
    @Binding var character: Character
    @Binding var stories: Stories
    @Binding var selectedStory: Story?
    var saveAction: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var chatBot: ChatBot
    @State private var isGenerating = false
    @State private var cancellables = Set<AnyCancellable>()
    @State private var bottomnum = 0
    @State private var selectedSegment = 0
    @State private var finGenerating = false
    @State private var progress: Double = 0.0
    @State private var timer: Timer? = nil
    @State private var message: String = NSLocalizedString("正在生成角色", comment: "")
    @State private var rotationAngle: Double = 0
    let segments = [NSLocalizedString("好人", comment: ""), NSLocalizedString("坏人", comment: "")]

    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 0.99, green: 0.99, blue: 0.99), location: 0.19),
                    Gradient.Stop(color: Color(red: 0.89, green: 0.94, blue: 1), location: 0.42),
                    Gradient.Stop(color: Color(red: 0.91, green: 0.76, blue: 1), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.5, y: -0.15),
                endPoint: UnitPoint(x: 0.5, y: 1.24)
            )
            .ignoresSafeArea()
            
            VStack {
                ZStack {
                    Ellipse()
                        .fill(Color(red: 229/255, green: 230/255, blue: 255/255))
                        .frame(width: 350, height: 350)
                        .offset(x: -100, y: 30)
                    Ellipse()
                        .fill(Color(red: 173/255, green: 179/255, blue: 255/255))
                        .frame(width: 250, height: 250)
                        .offset(x: -100, y: 30)
                    Image("category\(character.classnum)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 280, height: 280)
                        .offset(x: -70, y: -40)
                    RoundedRectangle(cornerRadius: 35)
                        .fill(Color(red: 229/255, green: 230/255, blue: 255/255))
                        .frame(width: 200, height: 40)
                        .offset(x: 135, y: -100)
                    Text(character.characlass)
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(.main)
                        .offset(x: 110, y: -100)
                    Text(character.introduction)
                        .frame(width: 140, height: 150)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                        .offset(x: 110, y: -25)
                }
                Spacer()
            }
            .padding()
            RoundedRectangle(cornerRadius: 50)
                .fill(Color.white)
                .frame(width: UIScreen.main.bounds.width, height: 770)
                .offset(x: 0, y: 220)
                .shadow(radius: 20)
            
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Button(character.maincharacter ? NSLocalizedString("已是主角", comment: "") : NSLocalizedString("设为主角", comment: "")) {
                            if let characterIndex = selectedStory?.characters.characters.firstIndex(where: { $0.id == character.id}){
                                for i in 0..<(selectedStory?.characters.characters.count)! {
                                    selectedStory?.characters.characters[i].maincharacter = false
                                }
                                selectedStory?.characters.characters[characterIndex].maincharacter = true
                                character.maincharacter = true
                                if let selectedStory = selectedStory {
                                    if let index = stories.stories.firstIndex(where: { $0.id == selectedStory.id }) {
                                        stories.stories[index] = selectedStory
                                        stories.save()
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: 150, maxHeight: 40)
                        .background( character.maincharacter ? Color.main : Color.light)
                        .opacity(character.maincharacter ? 1 : 1)
                        .font(.headline)
                        .foregroundColor(character.maincharacter ? Color.white : Color.main)
                        .cornerRadius(30)
                        .padding(.horizontal, 10)
                        HStack {
                            ForEach(segments.indices, id: \.self) { index in
                                Text(self.segments[index])
                                    .frame(maxWidth: 150, maxHeight: 40)
                                    .background(character.persontype == index ? Color.main : Color.clear)
                                    .font(.headline)
                                    .foregroundColor(character.persontype == index ? .white : .gray)
                                    .cornerRadius(30)
                                    .onTapGesture {
                                        withAnimation {
                                            self.character.persontype = index
                                        }
                                    }
                            }
                        }
                        .background(Color.light)
                        .cornerRadius(30)
                        .padding(.horizontal, 10)
                        
                    }
                    .padding(.horizontal,10)
                    ZStack {
                        TextField("Name", text: $character.name)
                            .frame(height: 25)
                            .padding()
                            .background(Color.light)
                            .cornerRadius(50)
                            .padding(.horizontal)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.sub)
                        Button(action: {
                            generateName()
                            self.bottomnum = 1
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
                                            if !isGenerating && chatBot.currentCharacterId == character.id && bottomnum == 1 {
                                                character.name = self.chatBot.nowgen
                                                print(character.name)
                                            }
                                        }
                                        .store(in: &cancellables)
                                }
                                .padding()
                        }
                    }
                    
                    ZStack {
                        TextField("Appearance", text: $character.hobby)//外貌
                            .frame(height: 25)
                            .padding()
                            .background(Color.light)
                            .cornerRadius(50)
                            .padding(.horizontal)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.sub)
                        Button(action: {
                            generateHobby()
                            self.bottomnum = 2
                        }) {
                            Text(NSLocalizedString("点击生成", comment: ""))
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .disabled(isGenerating)
                        .buttonStyle(RightButtonStyle(backgroundColor: Color.main))
                        .padding(.leading, 230)
                        .padding(.trailing, 24)
                        if chatBot.generating && bottomnum == 2 {
                            ProgressView()
                                .onAppear {
                                    chatBot.$generating
                                        .receive(on: RunLoop.main)
                                        .sink { isGenerating in
                                            self.isGenerating = isGenerating
                                            if !isGenerating && chatBot.currentCharacterId == character.id && bottomnum == 2 {
                                                character.hobby = self.chatBot.nowgen
                                            }
                                        }
                                        .store(in: &cancellables)
                                }
                                .padding()
                        }
                    }
                    
                    ZStack {
                        TextField("Personality", text: $character.personality)
                            .frame(height: 25)
                            .padding()
                            .background(Color.light)
                            .cornerRadius(50)
                            .padding(.horizontal)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.sub)
                        Button(action: {
                            generatePersonality()
                            self.bottomnum = 3
                        }) {
                            Text(NSLocalizedString("点击生成", comment: ""))
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .disabled(isGenerating)
                        .buttonStyle(RightButtonStyle(backgroundColor: Color.main))
                        .padding(.leading, 230)
                        .padding(.trailing, 24)
                        if chatBot.generating && bottomnum == 3 {
                            ProgressView()
                                .onAppear {
                                    chatBot.$generating
                                        .receive(on: RunLoop.main)
                                        .sink { isGenerating in
                                            self.isGenerating = isGenerating
                                            if !isGenerating && chatBot.currentCharacterId == character.id && bottomnum == 3 {
                                                character.personality = self.chatBot.nowgen
                                            }
                                        }
                                        .store(in: &cancellables)
                                }
                                .padding()
                        }
                    }
                    
                    ZStack {
                        TextField("Ability", text: $character.ability)
                            .frame(height: 25)
                            .padding()
                            .background(Color.light)
                            .cornerRadius(50)
                            .padding(.horizontal)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.sub)
                        Button(action: {
                            generateAbility()
                            self.bottomnum = 4
                        }) {
                            Text(NSLocalizedString("点击生成", comment: ""))
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .disabled(isGenerating)
                        .buttonStyle(RightButtonStyle(backgroundColor: Color.main))
                        .padding(.leading, 230)
                        .padding(.trailing, 24)
                        if chatBot.generating && bottomnum == 4 {
                            ProgressView()
                                .onAppear {
                                    chatBot.$generating
                                        .receive(on: RunLoop.main)
                                        .sink { isGenerating in
                                            self.isGenerating = isGenerating
                                            if !isGenerating && chatBot.currentCharacterId == character.id && bottomnum == 4 {
                                                character.ability = self.chatBot.nowgen
                                            }
                                        }
                                        .store(in: &cancellables)
                                }
                                .padding()
                        }
                    }
                    
                }
                .padding(.bottom, 220)
            }
            VStack{
                Spacer()
                ZStack {
                    Button(NSLocalizedString("保存", comment: "")) {
                        saveAction()
                        self.finGenerating = true
                        self.bottomnum = 0
                        if let storyIndex = stories.stories.firstIndex(where: { $0.id == selectedStory?.id }) {
                            // 更新 stories 数组中的故事
                            selectedStory = stories.stories[storyIndex]
                        }
                        let description = String(
                            format: NSLocalizedString("character_description_template", comment: ""),
                            character.name,
                            segments[character.persontype],
                            character.hobby,
                            character.personality,
                            character.ability
                        )

                        chatBot.answer(description, for: character.id){_ in }

                    }
                    .font(Font.custom("SF Pro", size: 20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 66)
                    .background(Color.sub)
                    .cornerRadius(33)
                    .padding(.horizontal)
                    .shadow(radius: 10)
                    .offset(x: 0, y: 10)
                    Image("bear_dialog")
                        .offset(x: 0, y: -60)
                        .shadow(radius: 10)
                    Text(NSLocalizedString("让小熊帮忙生成吧", comment: ""))
                        .font(.title2)
                        .foregroundColor(.black)
                        .offset(x: -70, y: -80)
                }
                .padding(.bottom,40)
            }
            .frame(width: UIScreen.main.bounds.width,height:UIScreen.main.bounds.height)
            
            if finGenerating &&  bottomnum == 0 {
                BlurView(style: .systemMaterial)
                    .edgesIgnoringSafeArea(.all)
                    ZStack {
                        LottieView(animationName: "Animation - 1726121308557 (1)", loopMode: .loop, animationSpeed: 0.5)
                            .offset(y:-110)
                        Text(message)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.main.opacity(0.7))
                            .onAppear {
                                chatBot.$generating
                                    .receive(on: RunLoop.main)
                                    .sink { isGenerating in
                                        self.isGenerating = isGenerating
                                        if !isGenerating && bottomnum == 0 {
                                            character.introduction = chatBot.nowgen
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                    }
                                    .store(in: &cancellables)
                            }
                        VStack {
                            Spacer()
                            ProgressView(value: progress, total: 1.0)
                                .progressViewStyle(LinearProgressViewStyle(tint: .main))
                                .padding()
                            Text("\(Int(progress * 100))%")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding()
                        }
                        .padding(70)
                        .padding(.bottom, 70)
                        .onAppear {
                            startTimer()
                            withAnimation {
                                rotationAngle += 720
                            }
                        }
                        .onDisappear {
                            timer?.invalidate()
                        }
                    }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack{
                    CustomBackButton()
                   Spacer()
                    Text("角色详情")
                        .font(.title2)
                        .foregroundColor(.gray.opacity(0.7))
                        
                }
            }
           
        }

    }

    func generateName() {
        let namePrompt = String(
            format: NSLocalizedString("character_name_prompt_template", comment: ""),
            character.characlass
        )
        chatBot.answer(namePrompt, for: character.id){_ in }
    }

    func generateHobby() {
        let hobbyPrompt = String(
            format: NSLocalizedString("hobby_prompt_template", comment: ""),
            character.characlass,
            segments[character.persontype]
        )
        chatBot.answer(hobbyPrompt, for: character.id){_ in }
    }
    func generatePersonality() {
        let personalityPrompt = String(
            format: NSLocalizedString("character_personality_prompt_template", comment: ""),
            character.characlass,
            segments[character.persontype]
        )
        chatBot.answer(personalityPrompt, for: character.id){_ in }
    }

    func generateAbility() {
        let AbilityPrompt = String(
            format: NSLocalizedString("character_Ability_prompt_template", comment: ""),
            character.characlass,
            segments[character.persontype]
        )

        chatBot.answer(AbilityPrompt, for: character.id){_ in }
    }
  
    func startTimer() {
        progress = 0.0
        message = NSLocalizedString("正在生成角色", comment: "")
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if progress < 1.0 {
                progress += 0.1 / 6

                if progress >= 0.8 {
                    message = NSLocalizedString("马上完成创建", comment: "")
                } else if progress >= 0.5 {
                    message = NSLocalizedString("正在完善角色细节", comment: "")
                } else if progress >= 0.2 {
                    message = NSLocalizedString("正在生成角色简介", comment: "")
                } else {
                    message = NSLocalizedString("正在生成角色", comment: "")
                }
            } else {
                timer.invalidate()
            }
        }
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

struct RightButtonStyle: ButtonStyle {
    var backgroundColor: Color

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Image("star")
        }
        .padding()
        .frame(height: 45)
        .background(backgroundColor)
        .foregroundColor(.white)
        .cornerRadius(40)
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct CharacterDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let exampleCharacter = Character(name: "示例角色", characlass: "公主", introduction: "ww", hobby: "读书", personality: "友好", ability: "飞行", classnum: 2, persontype: 0, maincharacter: false, sex: true)
        CharacterDetailView(character: .constant(exampleCharacter), stories: .constant(Stories()), selectedStory: .constant(Story(id: UUID(), title: "示例故事", characters: Characters(), scene: "", plots: Plots(), plot1: "", plot2: "", plot3: "", topic: [], storyintro: "", storyimage: [], finished: false,allcharacterUrls:[], allcharacters: [])), saveAction: {}, chatBot: ChatBot())
    }
}
