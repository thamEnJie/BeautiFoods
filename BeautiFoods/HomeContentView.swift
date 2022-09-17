//
//  ContentView.swift
//  BeautiFoods
//
//  Created by Tham En Jie on 23/8/22.
//

import SwiftUI

struct HomeContentView: View {
    
    @State var viewLoadedAlready = false
    @State var showCartSheet = false
    @State var loadCheckoutView = false
    
    @State var showFilterCard = false
    @State var backgroundBlur = 0.0
    @State var filters = Filter(sorting: .random, productType: [true, true], priceRange: [0,-1])  // -1 means no filtera
    @State var searchProducts: String = ""
    func filterProduct(_ item: Product, filter: Filter) -> Bool {
        if (!filter.productType[0] && !filter.productType[1]) || (item.cost <= Double(filter.priceRange[0])) || (filter.priceRange[1] == -1 ? false:item.cost >= Double(filter.priceRange[1])) {return false}
        if item.productType.rawValue == 2 {return true}
        else {return filter.productType[item.productType.rawValue]}
    }
    
    @StateObject var cartManager = CartItemManager()
    
    let badgewWidth = 32
    let badgeOffset = -5
    
    let productColumns = [
        GridItem(.adaptive(minimum: 100), spacing: 25, alignment: .center)
    ]
    
    func countCart(_ cartM: CartItemManager) -> Int {
        var a = 0
        for i in cartM.cartItems {
            a += i.count
        }
        return a
    }
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(
                    destination: CheckoutPageView(),
                    isActive: $loadCheckoutView
                ) {
                    EmptyView()
                }
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
                    Button {
                        showFilterCard = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .foregroundColor(.accentColor)
                    }
                }
                .padding()
                ScrollView (.vertical, showsIndicators: true) {
                    Spacer()
                        .frame(height: CGFloat(badgewWidth/2-badgeOffset))
                    LazyVGrid(columns: productColumns, spacing: 20) {
                        ForEach(ProductList, id: \.self) { item in
                            if filterProduct(item, filter: filters) {
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
            .blur(radius: CGFloat(backgroundBlur))
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
                        .blur(radius: CGFloat(backgroundBlur))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button  {
                        showCartSheet = true
                    } label: {
                        VStack {
                            Image(systemName: (countCart(cartManager)==0 ? "cart" : "cart.fill"))
                            Text("Cart")
                        }
                        .badge(width: 17, count: countCart(cartManager), tintColour: .black, offset: -2)
                        .blur(radius: CGFloat(backgroundBlur))
                    }
                }
            }
            .sheet(isPresented: $showCartSheet) {
                CartView(cartManager: cartManager, openCheckout: $loadCheckoutView)
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
        .overlay {
            if showFilterCard {
                FilterBottomSheetView(isPresented: $showFilterCard, filter: $filters, blur: $backgroundBlur)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeContentView()
    }
}
