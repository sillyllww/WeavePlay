import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    let images: [String] = ["bear_book", "bear_sit", "bear_camara"] // 图片名称或 URL
    let texts: [String] = ["欢迎来到“创影”--创造你的专属儿童故事。", "在这里，AI将辅助您定制出您所需要的教育内容。", "独特的阅读体验让阅读不再乏味"]
    @State private var navigateToMainView = false
    
    var body: some View {
        NavigationStack {
            ZStack{
                Image("back_image")
                    .resizable()
                    .scaledToFill()
                    
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .offset(x: 0, y: 0) // 调整x和y的值来平移图片位置
                    .ignoresSafeArea(.all)
                    .scaleEffect(1.009)
                VStack {
                    TabView(selection: $currentPage) {
                        ForEach(0..<images.count, id: \.self) { index in
                            ZStack{
                                if index == 0{
                                    Image(images[index])
                                        .offset(x:30,y: 80)
                                }
                                else if index == 1{
                                    Image(images[index])
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 600)
                                        .offset(x:130,y: 160)
                                }else{
                                    Image(images[index])
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 500)
                                        .offset(x:-40,y: 150)
                                }
                                VStack {
                                    HStack {
                                            Image("airplane")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 50) // 调整图像大
                                                .offset(x:-130,y: 0)
                                    }
                                    Text(texts[index])
                                        .font(.title)
                                        .fontWeight(.medium)
                                        .lineSpacing(5) // 设置行间距为5
                                        .foregroundColor(Color.white)
                                        .frame(width: 320, alignment: .topLeading)
                                        .padding(.top, 5)
                                    Spacer()
                                    HStack {
                                        ForEach(0..<images.count, id: \.self) { index in
                                            Circle()
                                                .fill(index == currentPage ? Color.white : Color.gray)
                                                .frame(width: 8, height: 8)
                                                .padding(2)
                                        }
                                    }
                                    .frame(width: 80,height: 20)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(10)
                                    .padding(.bottom,100)
      
                                }
                            }

                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // 不显示分页指示器
                    
     
                }
                VStack{
                    Spacer()
                    Button(action: {
                        if currentPage < images.count - 1 {
                            currentPage += 1
                        } else {
                            // 当到达最后一个页面时，跳转到主页面
                            navigateToMainView = true
                        }
                    }) {
                        Text(currentPage == images.count - 1 ? "开始" : "下一页")
                            .font(Font.custom("SF Pro", size: 20))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 66)
                            .background(Color.sub)
                            .cornerRadius(33)
                            .shadow(radius: 10)
                            .padding(.bottom,50)
                            .padding(.horizontal)
                    }
                }

                
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
               
            }
        }
        .navigationDestination(isPresented: $navigateToMainView) {
            MinutePickerView()
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
