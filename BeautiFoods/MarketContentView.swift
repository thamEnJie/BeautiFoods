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
    @State var sortedProductList: [Product] = []
    @State var prevSort: SortType = .random
    func sortProducts() -> [Product] {
        switch filters.sorting {
            case .random:
                return productListManager.productList.shuffled()
            case .az:
                return productListManager.productList.sorted { $0.name < $1.name }
            case .za:
                return productListManager.productList.sorted { $0.name > $1.name }
            case .priceAscending:
                return productListManager.productList.sorted { $0.cost < $1.cost }
            case .priceDescending:
                return productListManager.productList.sorted { $0.cost > $1.cost }
        }
    }
    
    @StateObject var cartManager = CartItemManager()
    @StateObject var productListManager = ProductManager()
    
    let badgeWidth = 32
    
    let productColumns = [
        GridItem(.adaptive(minimum: 150), spacing: 25, alignment: .center)
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
                            destination: CheckoutPageView(productListManager: productListManager, checkoutItems: cartManager.cartItems),
                            isActive: $loadCheckoutView
                        ) { EmptyView() }
                        HStack {
                            VStack {
                                Text("BeautiFoods").foregroundColor(.primaryLabel)
                                    .font(.largeTitle)
                                    .bold()
                                    .padding(.bottom, 5)
                                Text("Beauty is from within").foregroundColor(.primaryLabel)
                                    .font(.callout)
                                Text("Logged in \(loginState == .loggedIn ? "with \(Auth.auth().currentUser?.email ?? "an Account")":"as guest")").foregroundColor(.secondaryColour)
                                    .font(.caption)
                                    .padding(.top, 1)
                            }
                            .padding(.top, 15)
                            .padding(.bottom, 25)
                        }
                        
                        HStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                TextField("Search for Products", text: $searchProducts).padding(.vertical, 5)
                            }.padding(.horizontal, 5).background(Color.secondaryColour.opacity(0.5)).cornerRadius(10)
                            Button {
                                showFilterCard = true
                            } label: {
                                Image(systemName: "line.3.horizontal.decrease")
                                    .foregroundColor(.accentColor)
                                    .frame(maxHeight: .infinity).padding(5).background(Color.secondaryColour.opacity(0.5)).cornerRadius(10)
                            }
                        }.padding(10).fixedSize(horizontal: false, vertical: true)
                        ScrollView(.vertical, showsIndicators: true) {
                            LazyVGrid(columns: productColumns, spacing: 20) {
                                ForEach(sortedProductList, id: \.self) { item in
                                    if filterProduct(item, filter: filters) && searchProducts == "" ? true:item.name.lowercased().contains(searchProducts.lowercased()) && item.name != "Test Item" && !item.isDeprecated {
                                        ZStack(alignment: .bottom) {
                                            NavigationLink {
                                                ProductContentView(itemIndex: item.productIndex, cartManager: cartManager, productListManager: productListManager)
                                            } label: {
                                                ZStack {
                                                    Color.secondaryColour.opacity(0.5).cornerRadius(10)
                                                    VStack(spacing: 0) {
                                                        Image(item.imageName)
                                                            .resizable()
                                                            .cornerRadius(10)
                                                            .scaledToFit()
                                                            .scaleEffect(0.85)
                                                            .badge(
                                                                width: badgeWidth,
                                                                count: cartManager.cartItems[item.productIndex].count,
                                                                textColour: Color.secondaryLabel,
                                                                tintColour: Color.secondaryColour,
                                                                offset: -badgeWidth-2
                                                            )
                                                        HStack {
                                                            Text(item.name).foregroundColor(.secondaryLabel)
                                                            Spacer()
                                                            Text("$"+String(format: "%.2f", item.cost)).foregroundColor(.secondaryLabel)
                                                        }.padding()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 30)
                            .padding(.bottom, 10)
                        }
                    }
                    .blur(radius: CGFloat(backgroundBlur))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            NavigationLink  {
                                SettingsView(loginState: $loginState, cartManager: cartManager, productListManager: productListManager).navigationTitle("Preferences")
                            } label: {
                                Image(systemName: "gear")
                                    .blur(radius: CGFloat(backgroundBlur))
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if loginState == .loggedIn {
                                Button  {
                                    showCartSheet = true
                                } label: {
                                    Image(systemName: (countCart(cartManager)==0 ? "cart" : "cart.fill"))
                                        .badge(width: 15, count: countCart(cartManager), textColour: .secondaryColour , tintColour: .secondaryLabel, offset: -2)
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
                        CartView(cartManager: cartManager, productListManager: productListManager, openCheckout: $loadCheckoutView)
                    }
                    .onAppear {
                        if !viewLoadedAlready {
                            sortedProductList = sortProducts()
                            prevSort = filters.sorting
                            retrieveProductList(updateCartItems: true, productListManager: ProductManager(), CartManager: cartManager)
                            viewLoadedAlready = true
                        }
                    }.background(Color.backgroundColour)
                }
                .overlay {
                    if showFilterCard {
                        FilterBottomSheetView(productListManager: productListManager, isPresented: $showFilterCard, filter: $filters, blur: $backgroundBlur)
                            .onDisappear {
                                if prevSort != filters.sorting { sortedProductList = sortProducts() }
                                prevSort = filters.sorting
                            }
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

func retrieveProductList(updateCartItems: Bool, productListManager: ProductManager, CartManager cartManager: CartItemManager) {
    Firestore.firestore().collection("ProductList").document("testItem").getDocument() { (testDoc, err) in
        if let testDoc = testDoc, testDoc.exists {
            if (productListManager.productList == [] ? true:(testDoc.data()!["productListVersion"] as! Double != 0.0)) {
                Firestore.firestore().collection("ProductList").getDocuments() { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                    } else {
                        productListManager.productList = []
                        for document in querySnapshot!.documents {
                            productListManager.productList.append(Product(
                                name: document.data()["name"] as! String,
                                cost: (document.data()["name"] as! String == "Test Item") ? (document.data()["productListVersion"] as! Double):(document.data()["cost"] as! Double),
                                productType: document.data()["productType"] as! Int,
                                productIndex: document.data()["productIndex"] as! Int
                            ))
                        }
                        productListManager.productList.sort{$0.productIndex < $1.productIndex}
                        if updateCartItems {
                            let old = cartManager.cartItems
                            var update: [CartItem] = []
                            for i in 0...productListManager.productList.count-1 {
                                if let updatedIndex = old.firstIndex(where: { $0.productID == i }) {
                                    update.append(CartItem(productID: i, count: old[updatedIndex].count))
                                } else {
                                    update.append(CartItem(productID: i, count: 0))
                                }
                            }
                            cartManager.cartItems = update
                        }
                    }
                }
            }
        } else {
            print("Document does not exist")
        }
    }
}

extension View {
    func badge(width: Int = 24, count: Int = 10, textColour: Color = .black, tintColour: Color = .red, borderColour: Color = .white, offset: Int = 0) -> some View {
        ZStack(alignment: .topTrailing) {
            self
            ZStack {
                if count != 0 {
                    Text("\(count)")
                        .font(.system(size: CGFloat(width/20*13)))
                        .fontWeight(.black)
                        .frame(width: CGFloat(width), height: CGFloat(width))
                        .foregroundColor(textColour)
                        .background(Circle().fill(tintColour))
                        .transition(.scale)
                }
            }
            .offset(x: CGFloat(width/2+offset), y: CGFloat(width/2*(-1)-offset))
        }
    }
}

extension Color {
    static let backgroundColour = Color("backgroundColour")
    static let secondaryBackgroundColour = Color("secondaryBackgroundColour")
    static let primaryColour = Color("primary")
    static let secondaryColour = Color("secondary")
    static let primaryLabel = Color("primary")
    static let secondaryLabel = Color("secondaryLabel")
    static let middleColour = Color("middleColour")
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MarketContentView().preferredColorScheme(.light)
        MarketContentView().preferredColorScheme(.dark)
    }
}
