//
//  CartView.swift
//  BeautiFoods
//
//  Created by Tham En Jie on 25/8/22.
//

import SwiftUI

struct CartView: View {
    
    @ObservedObject var cartManager: CartItemManager
    @ObservedObject var productListManager: ProductManager
    @Binding var openCheckout: Bool
    
    func totalCost(cartM: CartItemManager, productM: ProductManager) -> Double {
        var total = 0.0
        for j in cartM.cartItems {
            total += Double(j.count)*productM.productList[j.productID].cost
        }
        return total
    }
    func countCart(_ cartM: CartItemManager) -> Int {
        var a = 0
        for i in cartM.cartItems {
            a += i.count
        }
        return a
    }
    
    @State var isRemoveItemAlertPresented: Bool = false
    @State var removeItem: CartItem?
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            HStack {
                Text("$\(String(format: "%.2f", totalCost(cartM: cartManager, productM: productListManager))) (\(countCart(cartManager)) Items)")
                    .font(Font.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryLabel)
                    .padding()
                Spacer()
            }
            List {
                Group {
                    if String(format: "%.2f", totalCost(cartM: cartManager, productM: productListManager)) == "0.00" {
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
                                let item = productListManager.productList[i.productID]
                                HStack {
                                    VStack {
                                        HStack {
                                            Text(item.name)
                                                .foregroundColor(.primaryLabel)
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
                                            Text(String(i.count)).foregroundColor(.primaryLabel)
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
                                                .foregroundColor(.primaryLabel)
                                            Spacer()
                                            Text("$" + String(format: "%.2f", item.cost * Double(i.count)))
                                                .font(Font.caption2)
                                                .foregroundColor(.primaryLabel)
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
                }.listRowBackground(Color.backgroundColour)
            }.onAppear{ UITableView.appearance().backgroundColor = UIColor(Color.secondaryBackgroundColour) }
            .buttonStyle(.borderless)
            if String(format: "%.2f", totalCost(cartM: cartManager, productM: productListManager)) != "0.00" {
                Button {
                    openCheckout = true
                    presentationMode.wrappedValue.dismiss()
                    
                } label: {
                    Text("Checkout").bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        .background(Color.secondaryColour.opacity(0.6))
                        .cornerRadius(10)
                }
                .padding(.horizontal).padding(.vertical, 1)
            }
        }.background(Color.backgroundColour)
        .alert("Remove from Cart", isPresented: $isRemoveItemAlertPresented, presenting: removeItem) { item in
            Button(role: .destructive) {
                withAnimation() {
                    cartManager.cartItems[item.productID].count = 0
                }
            } label: {
                Text("Remove")
            }
        } message: { item in
            Text("Remove all '\(productListManager.productList[item.productID].name)' from Cart? You can add it again in the home page.")
        }
        
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView(cartManager: CartItemManager(), productListManager: ProductManager(), openCheckout: .constant(false))
    }
}
