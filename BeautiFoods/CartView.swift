//
//  CartView.swift
//  BeautiFoods
//
//  Created by Tham En Jie on 25/8/22.
//

import SwiftUI

struct CartView: View {
    
    @StateObject var cartManager = CartItemManager()
    
    func totalCost(_ cartM: CartItemManager) -> Double {
        var total = 0.0
        for j in cartM.cartItems {
            total += Double(j.count)*ProductList[j.productID].cost
        }
        return total
    }
    
    @State var isRemoveItemAlertPresented: Bool = false
    @State var removeItem: CartItem?
    
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
                ForEach(cartManager.cartItems) { i in
                    if i.count > 0 {
                        let item = ProductList[i.productID]
                        VStack {
                            HStack {
                                Text(item.name)
                                    .font(Font.body)
                                    .fontWeight(.medium)
                                Spacer()
                                Button {
                                    if i.count > 1 {
                                        let itemLocation = i.productID
                                        var newItem = cartManager.cartItems[itemLocation]
                                        newItem.count -= 1
                                        cartManager.cartItems.remove(at: itemLocation)
                                        cartManager.cartItems.insert(newItem, at: itemLocation)
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
                                    let itemLocation = i.productID
                                    var newItem = cartManager.cartItems[itemLocation]
                                    newItem.count += 1
                                    cartManager.cartItems.remove(at: itemLocation)
                                    cartManager.cartItems.insert(newItem, at: itemLocation)
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
                    } else {
                    }
                }
            }
            .buttonStyle(.borderless)

        }
        .alert("Remove from Cart", isPresented: $isRemoveItemAlertPresented, presenting: removeItem) { item in
            Button(role: .destructive) {
                let itemLocation = item.productID
                var newItem = cartManager.cartItems[itemLocation]
                newItem.count = 0
                withAnimation() {
                    cartManager.cartItems.remove(at: itemLocation)
                    cartManager.cartItems.insert(newItem, at: itemLocation)
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
        CartView()
    }
}
