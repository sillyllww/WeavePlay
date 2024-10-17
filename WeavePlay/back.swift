//
//  CustomTabBar.swift
//  WeavePlay
//
//  Created by 李龙 on 2024/7/13.
//

import SwiftUI
//返回
struct CustomBackButton: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.backward")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                    .shadow(radius: 10)
            }
        }
    }
}
//按钮
struct RoundedButton: View {
    var title: String
    var destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
            Text(title)
                .font(Font.custom("SF Pro", size: 20))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 66)
                .background(Color.sub)
                .cornerRadius(33)
                .padding()
        }
    }
}
struct RoundedRectangleShape: Shape {
    var cornerRadius: CGFloat
    var loc: CGFloat
    var long: CGFloat
    var backzero: CGFloat {
        return loc < cornerRadius ? cornerRadius-loc : 0
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // 移动到矩形的左上角，准备开始绘制
        path.move(to: CGPoint(x: rect.minX + cornerRadius-backzero, y: rect.minY))
        
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius + loc - cornerRadius, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.minX + cornerRadius + loc-backzero, y: rect.minY - cornerRadius),
                          control: CGPoint(x: rect.minX + cornerRadius + loc-backzero, y: rect.minY))
        
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius + loc-backzero, y: rect.minY - 40 + cornerRadius))
        path.addQuadCurve(to: CGPoint(x: rect.minX + cornerRadius + loc + cornerRadius-backzero, y: rect.minY - 40),
                          control: CGPoint(x: rect.minX + cornerRadius + loc-backzero, y: rect.minY - 40))
        
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius + loc + long - cornerRadius, y: rect.minY - 40))
        path.addQuadCurve(to: CGPoint(x: rect.minX + cornerRadius + loc + long, y: rect.minY - 40 + cornerRadius),
                          control: CGPoint(x: rect.minX + cornerRadius + loc + long, y: rect.minY - 40))
        
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius + loc + long, y: rect.minY - cornerRadius))
        path.addQuadCurve(to: CGPoint(x: rect.minX + cornerRadius + loc + long + cornerRadius, y: rect.minY),
                          control: CGPoint(x: rect.minX + cornerRadius + loc + long, y: rect.minY))

        // 画上边，从左上角到右上角
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        
        // 绘制右上角圆角
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius),
                          control: CGPoint(x: rect.maxX, y: rect.minY))

        // 画右边，从右上角到右下角
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        // 绘制右下角圆角
        path.addQuadCurve(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY),
                          control: CGPoint(x: rect.maxX, y: rect.maxY))

        // 画下边，从右下角到左下角
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        // 绘制左下角圆角
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius),
                          control: CGPoint(x: rect.minX, y: rect.maxY))

        // 画左边，从左下角到左上角
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        // 绘制左上角圆角
        path.addQuadCurve(to: CGPoint(x: rect.minX + cornerRadius-backzero, y: rect.minY),
                          control: CGPoint(x: rect.minX, y: rect.minY))

        return path
    }
}

struct CustomRoundedRectangle: Shape {
    var topLeft: CGFloat
    var topRight: CGFloat
    var bottomLeft: CGFloat
    var bottomRight: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.size.width
        let height = rect.size.height
        
        // Define the radii for each corner
        let topLeftRadius = topLeft
        let topRightRadius = topRight
        let bottomLeftRadius = bottomLeft
        let bottomRightRadius = bottomRight
        
        // Start drawing the shape
        path.move(to: CGPoint(x: rect.minX + topLeftRadius, y: rect.minY))
        
        // Top edge
        path.addLine(to: CGPoint(x: rect.maxX - topRightRadius, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - topRightRadius, y: rect.minY + topRightRadius), radius: topRightRadius, startAngle: .degrees(270), endAngle: .degrees(360), clockwise: false)
        
        // Right edge
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRightRadius))
        path.addArc(center: CGPoint(x: rect.maxX - bottomRightRadius, y: rect.maxY - bottomRightRadius), radius: bottomRightRadius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        
        // Bottom edge
        path.addLine(to: CGPoint(x: rect.minX + bottomLeftRadius, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + bottomLeftRadius, y: rect.maxY - bottomLeftRadius), radius: bottomLeftRadius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        
        // Left edge
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeftRadius))
        path.addArc(center: CGPoint(x: rect.minX + topLeftRadius, y: rect.minY + topLeftRadius), radius: topLeftRadius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        
        path.closeSubpath()
        
        return path
    }
}

