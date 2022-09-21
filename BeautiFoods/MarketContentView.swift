//
//  ContentView.swift
//  BeautiFoods
//
//  Created by Tham En Jie on 23/8/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct MarketContentView: View {
    
    @State var loginState: LoginState = .notLoggedIn
    
    @State var viewLoadedAlready = false
    @State var showCartSheet = false
    @State var loadCheckoutView = false
    
    @State var showFilterCard = false
    @State var backgroundBlur = 0.0
    @State var filters = Filter(sorting: .random, productType: [true, true], priceRange: [0,-1])  // -1 means no filter
    @State var searchProducts: String = ""
    func filterProduct(_ item: Product, filter: Filter) -> Bool {
        if (!filter.productType[0] && !filter.productType[1]) || (item.cost <= Double(filter.priceRange[0])) || (filter.priceRange[1] == -1 ? false:item.cost >= Double(filter.priceRange[1])) {return false}
        if item.productType == 2 {return true}
        else {return filter.productType[item.productType]}
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
        VStack {
            if loginState == .loggedIn || loginState == .anonymous {
                NavigationView {
                    VStack {
                        NavigationLink(
                            destination: CheckoutPageView(checkoutItems: cartManager.cartItems),
                            isActive: $loadCheckoutView
                        ) { EmptyView() }
                        HStack {
                            VStack {
                                Text("BeautiFoods") // Add name?
                                    .font(.largeTitle)
                                    .bold()
                                    .padding(.bottom, 5)
                                Text("Beauty is from within")
                                    .font(.callout)
                                Text("Logged in \(loginState == .loggedIn ? "with \(Auth.auth().currentUser?.email ?? "an Account")":"as guest")").font(.caption).padding(.top, 1).foregroundColor(.secondary)
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
                                                        .cornerRadius(10)
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
                                SettingsView(loginState: $loginState, cartManager: cartManager).navigationTitle("Preferences")
                            } label: {
                                VStack {
                                    Image(systemName: "gear")
                                    Text("Settings")
                                }
                                .blur(radius: CGFloat(backgroundBlur))
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if loginState == .loggedIn {
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
                            } else {
                                Button {
                                    Auth.auth().currentUser!.delete { error in
                                        if let error = error {
                                            print(error)
                                        } else {
                                            withAnimation(.easeIn) {
                                                loginState = .notLoggedIn
                                            }
                                        }
                                    }
                                } label: {
                                    VStack {
                                        Image(systemName: "person.fill")
                                        Text("Login")
                                    }.blur(radius: CGFloat(backgroundBlur))
                                }
                            }
                        }
                    }
                    .sheet(isPresented: $showCartSheet) {
                        CartView(cartManager: cartManager, openCheckout: $loadCheckoutView)
                    }
                    .onAppear {
                        if !viewLoadedAlready {
                            Firestore.firestore().collection("ProductList").getDocuments() { (querySnapshot, error) in
                                if let error = error {
                                    print("Error getting documents: \(error)")
                                } else {
                                    ProductList = []
                                    for document in querySnapshot!.documents {
                                        ProductList.append(Product(
                                            name: document.data()["name"] as! String,
                                            cost: document.data()["cost"] as! Double,
                                            productType: document.data()["productType"] as! Int,
                                            productIndex: document.data()["productIndex"] as! Int
                                        ))
                                    }
                                    ProductList.sort{$0.productIndex < $1.productIndex}
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
                .overlay {
                    if showFilterCard {
                        FilterBottomSheetView(isPresented: $showFilterCard, filter: $filters, blur: $backgroundBlur)
                    }
                }
            } else {
                StartView(loginState: $loginState, cartManager: cartManager)
            }
        }.onAppear {
            if Auth.auth().currentUser?.uid == nil {
                loginState = loginState == .anonymous ? .anonymous:.notLoggedIn
            } else if loginState != .loggedIn { loginState = Auth.auth().currentUser!.isAnonymous ? .anonymous:.loggedIn }
        }
    }
}

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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MarketContentView()
    }
}
