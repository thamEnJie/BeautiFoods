//
//  ContentView.swift
//  BeautiFoods
//
//  Created by Tham En Jie on 23/8/22.
//

import SwiftUI

struct HomeContentView: View {
    
    @State var viewLoadedAlready = false
    
    @State var searchProducts: String = ""
    @StateObject var cartManager = CartItemManager()
    
    let badgewWidth = 32
    let badgeOffset = -5
    
    let productColumns = [
        GridItem(.adaptive(minimum: 100), spacing: 25, alignment: .center)
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    VStack {
                        Text("BeautiFoods") // Add name?
                            .font(.largeTitle)
                            .bold()
                            .padding(.bottom, 5)
                        Text("Beauty is from within")
                            .font(.callout)
                    }
                    .padding(.top, 15)
                    .padding(.bottom, 25)
                }

                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search for Products", text: $searchProducts)
                    Image(systemName: "line.3.horizontal.decrease")
                        .foregroundColor(.accentColor)
                }
                .padding()
                ScrollView (.vertical, showsIndicators: true) {
                    Spacer()
                        .frame(height: CGFloat(badgewWidth/2-badgeOffset))
                    LazyVGrid(columns: productColumns, spacing: 20) {
                        ForEach(ProductList, id: \.self) { item in
                            if searchProducts.isEmpty {
                                ZStack(alignment: .bottom) {
                                    NavigationLink {
                                        ProductContentView(itemIndex: item.productIndex, cartManager: cartManager)
                                    } label: {
                                        VStack {
                                            Image(item.imageName)
                                                .resizable()
                                                .scaledToFit()
                                            Text(item.name)
                                            Text("$"+String(format: "%.2f", item.cost))
                                        }
                                    }
                                }
                                .badge(
                                    width: badgewWidth,
                                    count: cartManager.cartItems[item.productIndex].count,
                                    tintColour: Color(UIColor.label),
                                    offset: badgeOffset
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 10)
                }
                .padding(.vertical)
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink  {
                        SettingsView()
                    } label: {
                        VStack {
                            Image(systemName: "person.crop.circle")
                            Text("Profile")
                        }
                    }

                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink  {
                        CartView(cartManager: cartManager)
                    } label: {
                        VStack {
                            Image(systemName: "cart")
                            Text("Cart")
                        }
                    }

                }
            }
            .onAppear {
                if !viewLoadedAlready{
                    let old = cartManager.cartItems
                    var update: [CartItem] = []
                    for i in 0...ProductList.count-1 {
                        if let updatedIndex = old.firstIndex(where: { $0.productID == i }) {
                            update.append(CartItem(productID: i, count: old[updatedIndex].count))
                        } else {
                            update.append(CartItem(productID: i, count: 0))
                        }
                    }
                    cartManager.cartItems = update
                    viewLoadedAlready = true
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeContentView()
    }
}
