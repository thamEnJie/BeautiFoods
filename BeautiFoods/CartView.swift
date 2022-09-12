//
//  CartView.swift
//  BeautiFoods
//
//  Created by Tham En Jie on 25/8/22.
//

import SwiftUI

struct CartView: View {
    
    @ObservedObject var cartManager: CartItemManager
    
    func totalCost(_ cartM: CartItemManager) -> Double {
        var total = 0.0
        for j in cartM.cartItems {
            total += Double(j.count)*ProductList[j.productID].cost
        }
        return total
    }
    
    @State var isRemoveItemAlertPresented: Bool = false
    @State var removeItem: CartItem?
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            HStack {
                Text("$\(String(format: "%.2f", totalCost(cartManager)))")
                    .font(Font.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                Spacer()
            }
            List {
                if String(format: "%.2f", totalCost(cartManager)) == "0.00" {
                    HStack {
                        Spacer()
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            VStack {
                                Image(systemName: "bag.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(.top)
                                    .padding(.horizontal)
                                    .padding(.horizontal)
                                Text("Shop for more in market")
                                    .font(Font.title2)
                                    .padding()
                            }
                        }
                        Spacer()
                    }
                } else {
                    ForEach(cartManager.cartItems) { i in
                        if i.count > 0 {
                            let item = ProductList[i.productID]
                            HStack {
                                VStack {
                                    HStack {
                                        Text(item.name)
                                            .font(Font.body)
                                            .fontWeight(.medium)
                                        Spacer()
                                        Button {
                                            if i.count > 1 {
                                                cartManager.cartItems[i.productID].count -= 1
                                            }
                                            else {
                                                isRemoveItemAlertPresented = true
                                                removeItem = i
                                            }
                                        } label: {
                                            Image(systemName: "minus.circle")
                                                .imageScale(.large)
                                        }
                                        Text(String(i.count))
                                        Button {
                                            cartManager.cartItems[i.productID].count += 1
                                        } label: {
                                            Image(systemName: "plus.circle")
                                                .imageScale(.large)
                                        }
                                    }
                                    HStack {
                                        Text("$" + String(item.cost))
                                            .font(Font.caption)
                                        Spacer()
                                        Text("$" + String(format: "%.2f", item.cost * Double(i.count)))
                                            .font(Font.caption2)
                                    }
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    isRemoveItemAlertPresented = true
                                    removeItem = i
                                } label: {
                                    Text("Remove from Cart")
                                }
                            }
                        } else {
                            // Nothing
                        }
                    }
                }
            }
            .buttonStyle(.borderless)
            if String(format: "%.2f", totalCost(cartManager)) == "0.00" {
                Button {
                    openCheckout = true
                    presentationMode.wrappedValue.dismiss()
                    
                } label: {
                    Text("Checkout")
                }
                .padding(.top)
            }
        }
        .alert("Remove from Cart", isPresented: $isRemoveItemAlertPresented, presenting: removeItem) { item in
            Button(role: .destructive) {
                withAnimation() {
                    cartManager.cartItems[item.productID].count = 0
                }
            } label: {
                Text("Remove")
            }
        } message: { item in
            Text("Remove *\(ProductList[item.productID].name)* from Cart? You can add it again in the home page.")
        }
        
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView(cartManager: CartItemManager())
    }
}
