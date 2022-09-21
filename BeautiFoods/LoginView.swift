//
//  LoginView.swift
//  BeautiFoods
//
//  Created by Tham En Jie on 18/9/22.
//

import SwiftUI
import Firebase

struct LoginView: View {
    
    @Binding var loginState: LoginState
    
    @ObservedObject var cartManager: CartItemManager
    
    @Binding var isPresented: Bool
    @State var showSignUp: Bool = false
    
    @State var email = ""
    @State var password = ""
    
    @State var isProcessingGuest = false
    @State var isProcessingLogin = false
    @State var alertPresented = false
    @State var alertMessage = ""
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "envelope")
                TextField("Email", text: $email)
                    .modifier(CustomInputField(contentType: .emailAddress))
            }.padding(.vertical)
            HStack {
                Image(systemName: "key").rotationEffect(.degrees(-45))
                SecureField("Password", text: $password)
                    .modifier(CustomInputField(contentType: .password))
            }.padding(.vertical)
            Button {
                showSignUp = true
            } label: {
                Text("I don't have an account (Sign Up)")
            }.padding()
            Divider().padding(.vertical).padding(.vertical)
            Button {
                isProcessingLogin = true
                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                    if error == nil {
                        switch authResult {
                        case .none:
                            alertMessage = "Could not log in"
                            alertPresented = true
                        case .some:
                            withAnimation(.spring()){
                                loginState = .loggedIn
                            }
                        }
                    } else {
                        alertMessage = error!.localizedDescription
                        if alertMessage == "There is no user record corresponding to this identifier. The user may have been deleted." {
                            alertMessage = "Please check if your email is correct, or create an account if you haven't done so."
                        }
                        alertPresented = true
                    }
                    isProcessingLogin = false
                }
            } label: {
                if !isProcessingLogin {
                    Text("Login")
                } else {
                    HStack {
                        ProgressView()
                        Text("Logging you in")
                    }
                }
            }.padding().disabled(email.isEmpty||password.isEmpty)
            Button {
                isProcessingGuest = true
                Auth.auth().signInAnonymously() { _, error in
                    if error == nil {
                        withAnimation(.easeOut) {
                            loginState = .anonymous
                            Firestore.firestore().collection("ProductList").getDocuments() { (querySnapshot, error) in
                                isProcessingGuest = false
                                if let error = error {
                                    print("Error getting documents: \(error)")
                                } else {
                                    ProductList = []
                                    for document in querySnapshot!.documents {
                                        ProductList.append(Product(
                                            name: document.data()["name"] as! String,
                                                cost: document.data()["cost"] as! Double,
                                                productType: document.data()["productType"] as! Int,
                                                productIndex: document.data()["productIndex"] as! Int
                                            ))
                                    }
                                    ProductList.sort{$0.productIndex < $1.productIndex}
                                    var update: [CartItem] = []
                                    for i in 0...ProductList.count-1 { update.append(CartItem(productID: i, count: 0)) }
                                    cartManager.cartItems = update
                                }
                            }
                        }
                    } else {
                        alertMessage = error!.localizedDescription
                        alertPresented = true
                    }
                }
            } label: {
                if !isProcessingGuest {
                    Text("Continue as Guest")
                } else {
                    HStack {
                        ProgressView()
                        Text("Creating Guest Account")
                    }.foregroundColor(.primary)
                }
            }.padding().padding(.top)
        }.padding(.horizontal).padding(.horizontal)
            .alert("Error", isPresented: $alertPresented) {} message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showSignUp) {
                SignUpView(isPresented: $showSignUp)
            }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(loginState: .constant(.notLoggedIn), cartManager: CartItemManager(), isPresented: .constant(true), showSignUp: false)
    }
}