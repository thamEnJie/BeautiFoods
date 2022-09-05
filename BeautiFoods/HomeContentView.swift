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
                }
                .padding()
                ScrollView (.vertical, showsIndicators: true) {
                    LazyVGrid(columns: productColumns, spacing: 20) {
                        ForEach(ProductList, id: \.self) { item in
                            if searchProducts.isEmpty {
                                ZStack(alignment: .bottom) {
                                    NavigationLink {
                                        ProductContentView(itemIndex: item.productIndex)
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
                                    width: 32,
                                    count: cartManager.cartItems[item.productIndex].count,
                                    tintColour: .black,
                                    offset: -5
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
                        CartView()
                    } label: {
                        VStack {
                            Image(systemName: "cart")
                            Text("Cart")
                        }
                    }

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
