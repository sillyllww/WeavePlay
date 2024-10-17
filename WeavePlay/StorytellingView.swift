////
////  StorytellingView.swift
////  WeavePlay
////
////  Created by 李龙 on 2024/7/13.
////
//import SwiftUI
//
//
//struct StorytellingView: View {
//    @State private var plus = false
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                Text("演绎故事还在制作中")
//                    .font(.largeTitle)
//                    .padding()
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .navigationBarBackButtonHidden(true)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    HStack {
//                        Button(action: {
//                            plus = true
//                        }) {
//                            Image(systemName: "plus")
//                                .foregroundColor(.white)
//                                .font(.system(size: 25))
//                        }
//                    }
//                }
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Text("演绎故事")
//                        .font(.title)
//                        .foregroundColor(.white)
//                    }
//                }
//            }
//            .navigationDestination(isPresented: $plus) {
//                MyView()
//                    .navigationBarBackButtonHidden(true)
//            }
//        }
//    }
//
//
//struct StorytellingView_Previews: PreviewProvider {
//    static var previews: some View {
//        StorytellingView()
//    }
//}
