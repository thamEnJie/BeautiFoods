//
//  CheckoutPageView.swift
//  BeautiFoods
//
//  Created by Tham En Jie on 12/9/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct CheckoutPageView: View {
    
    let firestoreDB = Firestore.firestore()
    
    @ObservedObject var productListManager: ProductManager
    
    @State var checkoutItems: [CartItem]
    
    var body: some View {
        VStack {
            Button {
                let writeFirestore: [String: Any] = [
                    "uid": (Auth.auth().currentUser?.uid)!,
                    "email": (Auth.auth().currentUser?.email)!,
                    "timestamp": FieldValue.serverTimestamp(),
                ]
                print(writeFirestore)
                var writeRef: DocumentReference? = nil
                writeRef = firestoreDB.collection("orders").addDocument(data: writeFirestore) { error in
                    if let error = error {
                        print("Error adding document: \(error)")
                    } else {
                        print("Document added with ID: \(writeRef!.documentID)")
                        for cartItem in checkoutItems {
                            firestoreDB.collection("orders").document("\(writeRef!.documentID)").collection("cart").document("\(productListManager.productList[cartItem.productID].name) [\(cartItem.count)]").setData(cartItem.dictionary) { err in
                                if let err = err {
                                    print("Error writing document: \(err)")
                                } else {
                                    print("Document successfully written!")
                                }
                            }
                        }
                    }
                }
            } label: {
                Text("Checkout")
            }.disabled(Auth.auth().currentUser?.uid == nil)
        }.background(Color.backgroundColour)
    }
}

struct CheckoutPageView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutPageView(productListManager: ProductManager(), checkoutItems: CartItemManager().cartItems)
    }
}
