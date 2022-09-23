//
//  ProductContentView.swift
//  BeautiFoods
//
//  Created by Tham En Jie on 23/8/22.
//

import SwiftUI
import FirebaseFirestore

struct ProductContentView: View {
    var itemIndex: Int
    @ObservedObject var cartManager: CartItemManager
    var body: some View {
        VStack {
            Text(ProductList[itemIndex].name)
            Text("$"+String(format: "%.2f", ProductList[itemIndex].cost))
            Text(String(cartManager.cartItems[itemIndex].count))
            Button {
                cartManager.cartItems[itemIndex].count += 1
            } label: {
                Image(systemName: "plus.circle")
            }
        }.background(Color.backgroundColour)
        .onAppear {
            if ProductList == [] {
                Firestore.firestore().collection("ProductList").getDocuments() { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                    } else {
                        for document in querySnapshot!.documents {
                            ProductList.append(Product(
                                name: document.data()["name"] as! String,
                                cost: document.data()["cost"] as! Double,
                                productType: document.data()["productType"] as! Int,
                                productIndex: document.data()["productIndex"] as! Int
                            ))
                        }
                        ProductList.sort{$0.productIndex < $1.productIndex}
                    }
                }
            }
        }
    }
}

struct ProductContentView_Previews: PreviewProvider {
    static var previews: some View {
        ProductContentView(itemIndex: 0, cartManager: CartItemManager())
    }
}
