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
    @ObservedObject var productListManager: ProductManager
    var body: some View {
        VStack {
            Text(productListManager.productList[itemIndex].name)
            Text("$"+String(format: "%.2f", productListManager.productList[itemIndex].cost))
            Text(String(cartManager.cartItems[itemIndex].count))
            Button {
                cartManager.cartItems[itemIndex].count += 1
            } label: {
                Image(systemName: "plus.circle")
            }
        }.background(Color.backgroundColour)
    }
}

struct ProductContentView_Previews: PreviewProvider {
    static var previews: some View {
        ProductContentView(itemIndex: 0, cartManager: CartItemManager())
    }
}
