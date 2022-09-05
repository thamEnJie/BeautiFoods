//
//  ProductStructure.swift
//  BeautiFoods
//
//  Created by Tham En Jie on 23/8/22.
//

import Foundation

struct Product: Hashable, Codable {
    var name: String
    var cost: Double
    var imageName: String = "daniel"
    
    var productIndex: Int
    
    var stock: Int = 9999999999
    var isDeprecated: Bool = false
}

var ProductList: [Product] = [ //replace this with the firebase oner
    Product(name: "Tomato", cost: 0.10, productIndex: 0),
    Product(name: "Apple", cost: 0.75, productIndex: 1),
    Product(name: "Lettuce", cost: 0.55, productIndex: 2),
    Product(name: "Orange", cost: 0.12, productIndex: 3),
    Product(name: "Grape", cost: 100.22, productIndex: 4),
]

struct CartItem: Hashable, Codable, Identifiable {
    var id = UUID()
    
    var productID: Int
    
    var count: Int
}
