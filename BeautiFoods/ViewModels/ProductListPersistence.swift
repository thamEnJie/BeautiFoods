import Foundation
import SwiftUI

class ProductManager: ObservableObject {
    @Published var productList: [Product] = [] {
        didSet {
            save()
        }
    }
    
    let sampleProducts: [Product] = []
    
    init() {
        load()
    }
    
    func getArchiveURL() -> URL {
        let plistName = "productList.plist"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        return documentsDirectory.appendingPathComponent(plistName)
    }
    
    func save() {
        let archiveURL = getArchiveURL()
        let propertyListEncoder = PropertyListEncoder()
        let encodedProducts = try? propertyListEncoder.encode(productList)
        try? encodedProducts?.write(to: archiveURL, options: .noFileProtection)
    }
    
    func load() {
        let archiveURL = getArchiveURL()
        let propertyListDecoder = PropertyListDecoder()
        
        var finalProducts: [Product]!
        
        if let retrievedProductData = try? Data(contentsOf: archiveURL),
           let decodedProducts = try? propertyListDecoder.decode([Product].self, from: retrievedProductData) {
            finalProducts = decodedProducts
        } else {
            finalProducts = sampleProducts
        }
        
        productList = finalProducts
    }
}

