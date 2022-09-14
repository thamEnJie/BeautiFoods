//
//  FilterBottomSheetView.swift
//  BeautiFoods
//
//  Created by Tham En Jie on 14/9/22.
//

import SwiftUI

struct FilterBottomSheetView: View {
    
    @Binding var isPresented: Bool
    @Binding var filter: Filter
    @Binding var blur: Double
    
    @State var viewOffset = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Button {
                    withAnimation (.spring(response: 0.3)) {
                        viewOffset = Int(geometry.size.height/2)
                        blur = 0.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isPresented = false
                    }
                } label: {
                    Spacer()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }.offset(y:5)
                VStack(alignment: .leading) { //The actual contents of the half modal sheet is here
                    //
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemBackground))
                .offset(y: CGFloat(viewOffset))
                .gesture(DragGesture()
                    .onChanged({ dragDistance in
                        if dragDistance.translation.height > 0 {
                            viewOffset = Int(dragDistance.translation.height)
                        }
                    })
                        .onEnded({ dragDistance in
                            if dragDistance.translation.height > CGFloat(geometry.size.height/2*0.4) {
                                withAnimation (.spring(response: 0.3)) {
                                    viewOffset = Int(geometry.size.height/2)
                                    blur = 0.0
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    isPresented = false
                                }
                            } else {
                                withAnimation (.spring(response: 0.25, dampingFraction: 0.7)) {
                                    viewOffset = 0
                                }
                            }
                        }))
                .onAppear {
                    viewOffset = Int(geometry.size.height)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.65)){
                        viewOffset = 0
                    }
                }
            }.edgesIgnoringSafeArea(.top)
                .onAppear {
                    withAnimation {
                        blur = 2.5
                    }
                }
        }.background(Color(red: 0, green: 0, blue: 0, opacity: 0.0000000001))
    }
}

struct FilterBottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        FilterBottomSheetView(isPresented: .constant(true), filter: .constant(Filter(sorting: .random, productType: [true, true], priceRange: [0,-1])), blur: .constant(0))
    }
}
