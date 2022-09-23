//
//  SettingsContentView.swift
//  BeautiFoods
//
//  Created by Tham En Jie on 25/8/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct SettingsView: View {
    
    @Binding var loginState: LoginState
    
    @ObservedObject var cartManager: CartItemManager
    @ObservedObject var productListManager: ProductManager
    
    @State var showMoreAccActions: Bool = false
    @State var resetPasswordAlertShown: Bool = false
    
    @State var deleteAccAlertShown: Bool = false
    @State var emailConfirm: String = ""
    @State var passwordConfirm: String = ""
    @State var deleteConfirm: Bool = false
    
    var body: some View {
        Form {
            Group {
                Section("Account") {
                    if loginState == .loggedIn {
                        Text(Auth.auth().currentUser?.email ?? "Failed to retrieve this account's email.").foregroundColor(.primaryColour)
                    }
                    Button {
                        do {
                            try Auth.auth().signOut()
                        } catch let signOutError as NSError {
                            print("Error signing out: %@", signOutError)
                        }
                        withAnimation {
                            loginState = .notLoggedIn
                        }
                    } label: {
                        Text(loginState == .loggedIn ? "Log Out":"Login/Create an Account")
                    }.disabled(loginState == .anonymous ? false:Auth.auth().currentUser?.uid == nil)
                    if loginState == .loggedIn {
                        Button {
                            withAnimation(.spring()) {
                                showMoreAccActions.toggle()
                            }
                        } label: {
                            HStack {
                                Text("More Account Actions")
                                Spacer()
                                Image(systemName: "chevron.up").controlSize(.mini).foregroundColor(.secondary).rotationEffect(Angle(degrees: showMoreAccActions ? 180:0))
                            }
                        }
                        if showMoreAccActions {
                            Button(role: .destructive) {
                                resetPasswordAlertShown = true
                            } label: {
                                Text("Reset Password").padding(.leading)
                            }.disabled(Auth.auth().currentUser?.uid == nil)
                                .alert("Reset Password?", isPresented: $resetPasswordAlertShown) {
                                    Button(role: .cancel) {} label: { Text("Cancel") }
                                    Button {
                                        Auth.auth().sendPasswordReset(withEmail: Auth.auth().currentUser!.email!) { error in
                                            if let error = error {
                                                print(error)
                                            }
                                        }
                                    } label: {
                                        Text("OK")
                                    }
                                } message: {
                                    Text("An Email will be sent to \(Auth.auth().currentUser!.email!) to reset your password.")
                                }
                            Button(role: .destructive) {
                                deleteAccAlertShown = true
                            } label: {
                                Text("Delete Account").padding(.leading)
                            }.disabled(Auth.auth().currentUser?.uid == nil)
                                .sheet(isPresented: $deleteAccAlertShown) {
                                    VStack {
                                        Spacer()
                                        Text("Delete Account").bold().font(Font.largeTitle).foregroundColor(.primaryLabel)
                                        Spacer()
                                        HStack {
                                            Image(systemName: "envelope")
                                            TextField("Email", text: $emailConfirm)
                                                .modifier(CustomInputField(contentType: .emailAddress))
                                        }.padding(.vertical)
                                        HStack {
                                            Image(systemName: "key").rotationEffect(.degrees(-45))
                                            SecureField("Password", text: $passwordConfirm)
                                                .modifier(CustomInputField(contentType: .password))
                                        }.padding(.vertical)
                                        Spacer()
                                        Spacer()
                                        HStack {
                                            Button(role: .destructive) {
                                                //delete from firestore database
                                                //re-auth
                                                //delete account
                                            } label: {
                                                Text("Delete Account")
                                            }.disabled(!deleteConfirm || emailConfirm != Auth.auth().currentUser!.email!) // also confirm password using reauth
                                            Button {
                                                deleteConfirm.toggle()
                                            } label: {
                                                Image(systemName: deleteConfirm ? "checkmark.square":"xmark.square")
                                            }
                                        }
                                    }.padding(.horizontal).padding(.horizontal)
                                }
                        }
                    }
                }
                Section("Shop") {
                    NavigationLink {
                        NotificationSettingsView(loginState: loginState, cartManager: cartManager, productListManager: productListManager).navigationTitle("Repeated Shopping List").navigationBarTitleDisplayMode(.inline)
                    } label: {
                        HStack {
                            Text("Notifications and Lists")
                        }
                    }
                    NavigationLink {
                    } label: {
                        HStack {
                            Text("Billing")
                        }
                    }
                }
            }.listRowBackground(Color.backgroundColour)
        }.navigationBarTitleDisplayMode(.large).onAppear{ UITableView.appearance().backgroundColor = UIColor(Color.secondaryBackgroundColour) }
    }
}

extension UIPickerView {
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: super.intrinsicContentSize.height)
    }
}
struct NotificationSettingsView: View {
    
    let loginState: LoginState
    
    let firestoreDB = Firestore.firestore()
    
    @ObservedObject var cartManager: CartItemManager
    @ObservedObject var productListManager: ProductManager
    
    @State var addShoppingListSheetShown: Bool = false
    @State var repeatedSelectionEnabled: Bool = false
    let timeSelectionCountRanges: [Int] = [28,4,12]
    @State var timeSelectionCountIndex: Int = 0
    let timeSelectionTypeRanges: [String] = ["Day", "Week", "Month"]
    @State var timeSelectionTypeIndex: Int = 0
    @State var arslEnabled: Bool = false
    
    @State var showInfo: Bool = false
    
    @State var tempShoppingList: [CartItem] = []
    @State var tempShoppingListName: String = ""
    @State var listsOfShoppingListsName: [String] = []
    @State var listsOfShoppingLists = []
    @State var listsUpdated = false
    
    var body: some View {
        Form {
            Group {
                Section("Shopping Lists") {
                    ForEach(listsOfShoppingListsName, id: \.self) { listName in
                        HStack {
                            Text(listName).foregroundColor(.primaryLabel)
                            Spacer()
                            Button {
                                //                            for i in listsOfShoppingLists[listsOfShoppingListsName.firstIndex(of: listName)] {
                                //                                cartManager.cartItems[i.productID].count += i.count
                                //                            }
                            } label: {
                                Image(systemName: "cart.badge.plus")
                            }
                            Button {
                                //                            cartManager.cartItems = cartManager.cartItems.map{CartItem(id: $0.id, productID: $0.productID, count: 0)}
                                //                            for i in listsOfShoppingLists[listsOfShoppingListsName.firstIndex(of: listName)] {
                                //                                cartManager.cartItems[i.productID].count = i.count
                                //                            }
                            } label: {
                                Image(systemName: "cart.fill")
                            }
                        }.buttonStyle(.borderless).swipeActions {
                            Button(role: .destructive) {
                                //
                            } label: {
                                Text("Delete List")
                            }
                            
                        }
                    }
                    Button {
                        addShoppingListSheetShown = true
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add a Shopping List")
                        }.padding(.leading)
                    }
                }.disabled(loginState != .loggedIn)
                    .sheet(isPresented: $addShoppingListSheetShown) {
                        VStack {
                            TextField("Enter Name of List Here", text: $tempShoppingListName).font(.title).textFieldStyle(.roundedBorder).padding([.horizontal, .top])
                            List {
                                ForEach(tempShoppingList, id: \.self) { item in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(productListManager.productList[item.productID].name).foregroundColor(.primaryLabel)
                                            Text("$"+String(format: "%.2f", productListManager.productList[item.productID].cost)).padding(.leading).font(Font.caption).foregroundColor(.primaryLabel)
                                        }
                                        Spacer()
                                        Button {
                                            if item.count >= 1 { tempShoppingList[item.productID].count -= 1 }
                                        } label: {
                                            Image(systemName: "minus")
                                        }
                                        Text(String(item.count)).foregroundColor(.primaryLabel)
                                        Button {
                                            tempShoppingList[item.productID].count += 1
                                        } label: {
                                            Image(systemName: "plus")
                                        }
                                    }
                                }
                            }.buttonStyle(.borderless)
                            Spacer()
                            Button {
                                tempShoppingList = tempShoppingList.filter{$0.count > 0}
                                for shopItem in tempShoppingList {
                                    firestoreDB.collection("users").document("\(Auth.auth().currentUser!.uid)").collection("lists").document("\(tempShoppingListName)").collection("\(tempShoppingListName)").document("\(productListManager.productList[shopItem.productID].name)").setData(shopItem.dictionary)
                                }
                                firestoreDB.collection("users").document("\(Auth.auth().currentUser!.uid)").collection("lists").document("\(tempShoppingListName)").setData(["listName":"\(tempShoppingListName)"])
                                addShoppingListSheetShown = false
                                listsUpdated = false
                            } label: {
                                Text("Add to Lists")
                            }.padding(.top).disabled(tempShoppingListName == "")
                        }.background(Color.backgroundColour)
                            .onAppear {
                                tempShoppingList = []
                                for i in 0...productListManager.productList.count-1 { tempShoppingList.append(CartItem(productID: i, count: 0)) }
                            }
                    }
                    .onAppear {
                        if !listsUpdated {
                            firestoreDB.collection("users").document("\(Auth.auth().currentUser!.uid)").collection("lists").getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                } else {
                                    listsOfShoppingLists = []
                                    for doc in querySnapshot!.documents {
                                        listsOfShoppingListsName.append("\(doc.documentID)")
                                        firestoreDB.collection("users").document("\(Auth.auth().currentUser!.uid)").collection("lists").document("\(doc.documentID)").collection("\(doc.documentID)").getDocuments() { (CquerySnapshot, Cerr) in
                                            if let Cerr = Cerr {
                                                print("Error getting documents: \(Cerr)")
                                            } else {
                                                var temp: [[String:Any]] = []
                                                for document in CquerySnapshot!.documents {
                                                    temp.append(document.data())
                                                }
                                                listsOfShoppingLists.append(temp.map{CartItem(productID: $0["productID"] as! Int, count: $0["count"] as! Int)})
                                            }
                                        }
                                    }
                                }
                            }
                            listsUpdated = true
                        }
                    }
                Section("Notifications") {
                    HStack {
                        Toggle(isOn: $repeatedSelectionEnabled.animation(.spring())) {
                            Text((repeatedSelectionEnabled ? "Notifies you every \(timeSelectionCountIndex+1) \(timeSelectionTypeRanges[timeSelectionTypeIndex].lowercased())\(timeSelectionCountIndex == 0 ? "":"s")":"Notifications Disabled")).foregroundColor(.primaryLabel)
                        }
                    }
                    if repeatedSelectionEnabled {
                        HStack(spacing: 0) {
                            Picker("Time Count", selection: $timeSelectionCountIndex) {
                                ForEach(0...timeSelectionCountRanges[timeSelectionTypeIndex]-1, id: \.self) { i in
                                    Text("\(i+1)").foregroundColor(.primaryLabel)
                                }
                            }.pickerStyle(.wheel)
                            Picker("Time Type", selection: $timeSelectionTypeIndex) {
                                ForEach(0...timeSelectionTypeRanges.count-1, id: \.self) { i in
                                    Text(timeSelectionTypeRanges[i]).foregroundColor(.primaryLabel)
                                }
                            }.pickerStyle(.wheel)
                        }
                        Toggle("Automatic Repeated Shopping List", isOn: $arslEnabled.animation(.spring()))
                            .foregroundColor(loginState == .loggedIn ? .primary:.secondary)
                            .disabled(loginState != .loggedIn)
                        if arslEnabled {
                            //pick from the lists they have
                        }
                        Button {
                            withAnimation(.spring()) {
                                showInfo.toggle()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "info.circle")
                                Text("What is Repeated Shopping List?")
                                Spacer()
                                Image(systemName: "chevron.up").controlSize(.mini).foregroundColor(.secondary).rotationEffect(Angle(degrees: showInfo ? 180:0))
                            }
                        }
                        if showInfo {
                            Text("A default shopping list would be added to your cart when you are notified! (Can only be used with an account)").padding([.leading, .vertical]).foregroundColor(.primaryLabel)
                        }
                    }
                }
                Section{EmptyView()}
            }.listRowBackground(Color.backgroundColour)
        }
    }
}
struct CreditDetailsView: View {
    var body: some View {
        Form{}
    }
}


struct SettingsContentsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(loginState: .constant(.loggedIn), cartManager: CartItemManager(), productListManager: ProductManager())
    }
}

struct NotificationSettings_Previews: PreviewProvider {
    static var previews: some View { NotificationSettingsView(loginState: .loggedIn, cartManager: CartItemManager(), productListManager: ProductManager()) }
}
struct CreditDetails_Prevews: PreviewProvider {
    static var previews: some View { CreditDetailsView() }
}
