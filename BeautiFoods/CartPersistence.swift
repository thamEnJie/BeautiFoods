import Foundation
import SwiftUI

class CartItemManager: ObservableObject {
    @Published var cartItems: [CartItem] = [] {
        didSet {
            save()
        }
    }
    
    let sampleCartItems: [CartItem] = []
    
    init() {
        load()
    }
    
    func getArchiveURL() -> URL {
        let plistName = "cartItems.plist"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        return documentsDirectory.appendingPathComponent(plistName)
    }
    
    func save() {
        let archiveURL = getArchiveURL()
        let propertyListEncoder = PropertyListEncoder()
        let encodedCartItems = try? propertyListEncoder.encode(cartItems)
        try? encodedCartItems?.write(to: archiveURL, options: .noFileProtection)
    }
    
    func load() {
        let archiveURL = getArchiveURL()
        let propertyListDecoder = PropertyListDecoder()
        
        var finalCartItems: [CartItem]!
        
        if let retrievedCartItemData = try? Data(contentsOf: archiveURL),
           let decodedCartItems = try? propertyListDecoder.decode([CartItem].self, from: retrievedCartItemData) {
            finalCartItems = decodedCartItems
        } else {
            finalCartItems = sampleCartItems
        }
        
        cartItems = finalCartItems
    }
}

