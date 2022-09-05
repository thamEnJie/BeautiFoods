//
//  ProductContentView.swift
//  BeautiFoods
//
//  Created by Tham En Jie on 23/8/22.
//

import SwiftUI

struct ProductContentView: View {
    var itemIndex: Int
    @StateObject var cartManager = CartItemManager()
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
        }
    }
}

struct ProductContentView_Previews: PreviewProvider {
    static var previews: some View {
        ProductContentView(itemIndex: 0)
    }
}
