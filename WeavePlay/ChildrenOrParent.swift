//
//  ChildrenOrParent.swift
//  WeavePlay
//
//  Created by 李龙 on 2024/9/3.
//

import SwiftUI

struct ChildrenOrParent: View {
    @State private var tochildrenView:Bool = false
    @State private var toparentView:Bool = false
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var globalSettings: GlobalSettings
    @EnvironmentObject var timerManager: TimerManager
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
                 RoundedRectangle(cornerRadius: 50)
                     .fill(Color.white)
                     .frame(width: UIScreen.main.bounds.width)
                     .padding(.top,230)
                 Image("bear_start")
                     .padding(.bottom,500)
                 VStack {
                     Spacer(minLength: 250)
                     Text("选择您的身份")
                         .font(.system(size: 40))
                         .bold()
                         .opacity(0.7)
                         .padding(10)
                         .padding(.horizontal,20)
                         .frame(width: UIScreen.main.bounds.width, alignment: .leading)
                     Text("点击下方按钮选择家长或者儿童")
                         .font(.system(size: 20))
                         .opacity(0.6)
                         .padding(.horizontal,30)
                         .frame(width: UIScreen.main.bounds.width, alignment: .leading)
                         .padding(.bottom,30)
 
                     
                     Button(action: {
                         tochildrenView = true
                        
                     }) {
                         ZStack{
                             Image("child_card")
                             Text("我是儿童")
                                 .font(.title)
                                 .bold()
                                 .foregroundStyle(Color.black)
                                 .opacity(0.6)
                                 .offset(x:80,y: 10)
                         }
                         
                     }
                     Button(action: {
                         toparentView = true
                     }) {
                         ZStack{
                             Image("parent_card")
                             Text("我是家长")
                                 .font(.title)
                                 .bold()
                                 .foregroundStyle(Color.black)
                                 .opacity(0.6)
                                 .offset(x:80,y: 10)
                         }
                     }
                     Spacer()
                 }
                 .padding()
             }

         }
         .navigationDestination(isPresented: $tochildrenView) {
             HomeView()
                 .environmentObject(timerManager)
                 .environmentObject(globalSettings)
         }
         .navigationDestination(isPresented: $toparentView) {
             OnboardingView()
         }
     }
}

#Preview {
    ChildrenOrParent()
}
