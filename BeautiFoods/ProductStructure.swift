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
    var productType: ProductType
    var imageName: String = "daniel"
    
    var productIndex: Int
    
    var stock: Int = 9999999999
    var isDeprecated: Bool = false
}

var ProductList: [Product] = [ //replace this with the firebase oner
    Product(name: "Tomato", cost: 0.10, productType: .both, productIndex: 0),
    Product(name: "Apple", cost: 0.75, productType: .fruit, productIndex: 1),
    Product(name: "Lettuce", cost: 0.55, productType: .vegetable, productIndex: 2),
    Product(name: "Orange", cost: 0.12, productType: .fruit, productIndex: 3),
    Product(name: "Grape", cost: 10.22, productType: .fruit, productIndex: 4),
]

struct CartItem: Hashable, Codable, Identifiable {
    var id = UUID()
    
    var productID: Int
    
    var count: Int
    
    var dictionary: [String: Any] {
        return ["productID": productID,
                "count": count]
    }
}

struct Filter {
    var sorting: SortType
    
    var productType: [Bool]
    var priceRange: [Int]
}

enum ProductType: Int, Codable{
    case fruit = 0
    case vegetable = 1
    case both = 2
}

enum SortType: String, CaseIterable, Codable, Identifiable {
    case random = "Random"
    case alphabetical = "Alphabetical"
    case priceAscending = "Price Ascending"
    case priceDescending = "Price Descending"
    //case popularity = "Popularity"
    
    var id: Self {self}
}

enum LoginState {
    case notLoggedIn
    case loggedIn
    case anonymous
}
