//
//  BadgeView.swift
//  BeautiFoods
//
//  Created by Tham En Jie on 4/9/22.
//

import SwiftUI

extension View {
    func badge(width: Int = 24, count: Int = 10, tintColour: Color = .red, offset: Int = 0) -> some View {
        ZStack(alignment: .topTrailing) {
            self
            ZStack {
                if count != 0 {
                    Text("\(count)")
                        .font(.system(size: CGFloat(width/20*13)))
                        .fontWeight(.bold)
                        .frame(width: CGFloat(width), height: CGFloat(width))
                        .foregroundColor(Color(UIColor.systemBackground))
                        .background(Circle().fill(tintColour))
                        .transition(.scale)
                }
            }
            .offset(x: CGFloat(width/2+offset), y: CGFloat(width/2*(-1)-offset))
        }
    }
}


struct BadgeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            Text("Test")
                .badge()
        }
    }
}
