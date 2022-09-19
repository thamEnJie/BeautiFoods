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
    
    @State var showMoreAccActions: Bool = false
    @State var resetPasswordSheetShown: Bool = false
    @State var deleteAccAlertShown: Bool = false
    
    var body: some View {
        Form {
            Section("Account") {
                if loginState == .loggedIn {
                    Text(Auth.auth().currentUser?.email ?? "Failed to retrieve this account's email.")
                }
                Button {
                    if loginState == .loggedIn {
                        do {
                            try Auth.auth().signOut()
                        } catch let signOutError as NSError {
                            print("Error signing out: %@", signOutError)
                        }
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
                            resetPasswordSheetShown = true
                        } label: {
                            Text("Reset Password").padding(.leading)
                        }.disabled(Auth.auth().currentUser?.uid == nil)
                            .sheet(isPresented: $resetPasswordSheetShown) {
                                //
                            }
                        Button(role: .destructive) {
                            deleteAccAlertShown = true
                        } label: {
                            Text("Delete Account").padding(.leading)
                        }.disabled(Auth.auth().currentUser?.uid == nil)
                            .sheet(isPresented: $deleteAccAlertShown) {
                                //
                            }

                    }
                }
            }
            Section("Shop") {
                NavigationLink {
                    NotificationSettingsView(loginState: loginState).navigationTitle("Repeated Shopping List").navigationBarTitleDisplayMode(.inline)
                } label: {
                    HStack {
                        Text("Notifications and Lists")
                    }
                }
                NavigationLink {
                } label: {
                    HStack {
                        Text("Credit Card Details")
                    }
                }
            }
        }.navigationBarTitleDisplayMode(.large)
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
    
    @State var repeatedSelectionEnabled: Bool = false
    let timeSelectionCountRanges: [Int] = [28,4,12]
    @State var timeSelectionCountIndex: Int = 0
    let timeSelectionTypeRanges: [String] = ["Day", "Week", "Month"]
    @State var timeSelectionTypeIndex: Int = 0
    @State var arslEnabled: Bool = false
    
    @State var showInfo: Bool = false
    
    var body: some View {
        Form {
            Section("Lists") {
                
            }.disabled(loginState != .loggedIn)
            Section("Notifications") {
                HStack {
                    Toggle(isOn: $repeatedSelectionEnabled.animation(.spring())) {
                        Text((repeatedSelectionEnabled ? "Notifies you every \(timeSelectionCountIndex+1) \(timeSelectionTypeRanges[timeSelectionTypeIndex].lowercased())\(timeSelectionCountIndex == 0 ? "":"s")":"Notifications Disabled")).foregroundColor(.primary)
                    }
                }
                if repeatedSelectionEnabled {
                    HStack(spacing: 0) {
                        Picker("Time Count", selection: $timeSelectionCountIndex) {
                            ForEach(0...timeSelectionCountRanges[timeSelectionTypeIndex]-1, id: \.self) { i in
                                Text("\(i+1)")
                            }
                        }.pickerStyle(.wheel)
                        Picker("Time Type", selection: $timeSelectionTypeIndex) {
                            ForEach(0...timeSelectionTypeRanges.count-1, id: \.self) { i in
                                Text(timeSelectionTypeRanges[i])
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
                        Text("A default shopping list would be added to your cart when you are notified! (Can only be used with an account)").padding([.leading, .vertical])
                    }
                }
            }
            Section{EmptyView()}
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
        SettingsView(loginState: .constant(.loggedIn))
    }
}

struct NotificationSettings_Previews: PreviewProvider {
    static var previews: some View { NotificationSettingsView(loginState: .loggedIn) }
}
struct CreditDetails_Prevews: PreviewProvider {
    static var previews: some View { CreditDetailsView() }
}
