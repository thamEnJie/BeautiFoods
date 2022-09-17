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
    
    func viewIsDisappearing(sheetSize: Double) {
        withAnimation (.spring(response: 0.3)) {
            viewOffset = Int(sheetSize/2)
            blur = 0.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
    
    @State var priceRangeHandleOffset: [Double] = [0.0, 0.0]
    let handleSize = 25.0
    @State var sliderWidth = 0.0
    let sliderHeight = 3.5
    let maxPrice = ProductList.map{$0.cost}.max()!
    func calculateHandlePricePoint(_ i: Int, marginPercentage: Double, handleEnd: Double, location handleLocation: Double, maximumPrice: Double) -> Int {
        let pricePercentage = handleLocation/handleEnd
        if i==0 && pricePercentage <= marginPercentage {return 0}
        if i==1 && pricePercentage >= 1-marginPercentage {return -1}
        return Int(pricePercentage*maximumPrice)
    }
    func getHandleLocation(price: Int, maximumPrice: Double, handleEnd: Double) -> Double {
        return price == -1 ? handleEnd:Double(price)/maximumPrice*handleEnd
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Button {
                    viewIsDisappearing(sheetSize: geometry.size.height)
                } label: {
                    Spacer()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }.offset(y:5)
                VStack(alignment: .leading) { //The actual contents of the half modal sheet is here
                    VStack(alignment: .leading) {
                        Text("Sorting")
                            .font(.headline)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach (SortType.allCases) { chosenFilter in
                                    Button  {
                                        withAnimation(.spring()){
                                            filter.sorting = chosenFilter
                                        }
                                    } label: {
                                        Text(chosenFilter.rawValue)
                                            .padding(9)
                                            .foregroundColor(filter.sorting == chosenFilter ? Color(UIColor.label):Color(UIColor.systemBackground))
                                            .background(filter.sorting == chosenFilter ? Color(UIColor.systemGray6):Color(UIColor.systemGray2))
                                            .cornerRadius(7)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 7)
                                                    .stroke(filter.sorting == chosenFilter ? .black:.clear, lineWidth: 2)
                                            )
                                    }
                                    
                                }
                            }.padding(1)
                        }
                    }.padding(.vertical)
                    VStack(alignment: .leading) {
                        Text("Type")
                            .font(.headline)
                        HStack {
                            ForEach (0...1, id: \.self) { i in
                                Button  {
                                    filter.productType[i].toggle()
                                } label: {
                                    Label(i==0 ? "Fruits":"Vegetables", systemImage: filter.productType[i] ? "checkmark":"xmark")
                                        .padding(9)
                                        .foregroundColor(Color(UIColor.systemBackground))
                                        .background(filter.productType[i] ? Color.green:Color.gray)
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }.padding(.vertical)
                    VStack(alignment: .leading) {
                        Text("Price Range [$\(filter.priceRange[0])-$\(filter.priceRange[1] == -1 ? String(maxPrice)+"+":String(filter.priceRange[1]))]")
                            .font(.headline)
                        HStack {
                            Text("$0").foregroundColor(.secondary).padding(.trailing)
                            ZStack(alignment: .leading) {
                                GeometryReader { g in
                                    VStack {
                                        Rectangle()
                                            .fill(Color(UIColor.systemFill))
                                            .onAppear {
                                                if sliderWidth==0.0 { sliderWidth = Double(g.size.width) }
                                            }
                                            .cornerRadius(15)
                                    }.frame(height: sliderHeight)
                                }.frame(height: sliderHeight)
                                Rectangle()
                                    .fill(Color.accentColor)
                                    .frame(width: priceRangeHandleOffset[1]-priceRangeHandleOffset[0]+handleSize, height: sliderHeight)
                                    .offset(x: priceRangeHandleOffset[0]+handleSize/2)
                                HStack(spacing: 0) {
                                    ForEach(0...1, id: \.self) { i in
                                        Circle()
                                            .foregroundColor(.white)
                                            .shadow(radius: handleSize/5, y: handleSize/6.5)
                                            .frame(width: handleSize, height: handleSize)
                                            .offset(x: priceRangeHandleOffset[i])
                                            .gesture(DragGesture()
                                                .onChanged({ dragDistance in
                                                    let handleStart = 0.0
                                                    var handleLocation = Double(dragDistance.location.x)
                                                    let handleEnd = sliderWidth-handleSize
                                                    if handleLocation >= (i==0 ? handleStart:priceRangeHandleOffset[0]+handleSize/2) && handleLocation <= (i==0 ? priceRangeHandleOffset[1]+handleSize/2:handleEnd) {
                                                        if handleLocation<handleStart { handleLocation=handleStart }
                                                        if handleLocation>handleEnd { handleLocation=handleEnd }
                                                        priceRangeHandleOffset[i] = Double(dragDistance.location.x)-handleSize/2
                                                        filter.priceRange[i] = calculateHandlePricePoint(i, marginPercentage: 0.05, handleEnd: handleEnd, location: handleLocation, maximumPrice: maxPrice)
                                                    }
                                                })
                                            )
                                            .onAppear {
                                                priceRangeHandleOffset[i] = getHandleLocation(price: filter.priceRange[i], maximumPrice: maxPrice, handleEnd: sliderWidth-handleSize)-handleSize/2
                                            }
                                    }
                                }
                            }.padding(.vertical)
                            VStack{Text("$" + String(maxPrice) + "+").foregroundColor(.clear).padding(.leading)}.overlay { // overlay to keep GeometryReader to the bounds of the Text, if not, it would breakt the layout
                                GeometryReader { geo in
                                    Text("$" + String(maxPrice) + "+").foregroundColor(.secondary)
                                }.padding(.leading)
                            }
                        }
                    }.padding(.vertical)
                }
                .padding(.horizontal)
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
                                viewIsDisappearing(sheetSize: geometry.size.height)
                            } else {
                                withAnimation (.spring(response: 0.25, dampingFraction: 0.7)) {
                                    viewOffset = 0
                                }
                            }
                        }))
                .onAppear {
                    viewOffset = Int(geometry.size.height)
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.65)){
                        viewOffset = 0
                    }
                }
            }.edgesIgnoringSafeArea(.vertical)
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
