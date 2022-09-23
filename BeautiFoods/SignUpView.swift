//
//  SignInView.swift
//  BeautiFoods
//
//  Created by Tham En Jie on 18/9/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct SignUpView: View {
    
    @Binding var isPresented: Bool
    
    let firestoreDB = Firestore.firestore()
    
    @State var email = ""
    @State var password = ""
    @State var passwordConfirm = ""
    
    @State var isProcessingSignup = false
    @State var alertPresented = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    
    var body: some View {
        VStack {
            Spacer()
            Text("Sign Up").font(.largeTitle).bold()
            Spacer()
            Spacer()
            HStack {
                Image(systemName: "envelope")
                TextField("Email", text: $email)
                    .modifier(CustomInputField(contentType: .emailAddress))
            }.padding(.vertical)
            HStack {
                Image(systemName: "key").rotationEffect(.degrees(-45))
                SecureField("Password", text: $password)
                    .modifier(CustomInputField(contentType: .newPassword))
            }.padding(.vertical)
            HStack {
                Image(systemName: "key.fill").rotationEffect(.degrees(-45))
                SecureField("Confirm Password", text: $passwordConfirm)
                    .modifier(CustomInputField(contentType: .password))
            }.padding(.vertical).foregroundColor(password != passwordConfirm ? .red:.primary)
            Spacer()
            Spacer()
            if !isProcessingSignup {
                Button {
                    isProcessingSignup = true
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        if error == nil {
                            switch authResult {
                            case .none:
                                alertTitle = "Could not create account"
                                alertMessage = ""
                            case .some:
                                alertTitle = "Account Created"
                                alertMessage = "You may now log in with the assigned email: \(email)"
                                firestoreDB.collection("users").document(Auth.auth().currentUser!.uid).setData([
                                    "email": Auth.auth().currentUser!.email!,
                                    "timeJoined": FieldValue.serverTimestamp(),
                                ])
                            }
                        } else {
                            alertTitle = "Error"
                            alertMessage = error!.localizedDescription
                        }
                        isProcessingSignup = false
                        alertPresented = true
                    }
                } label: {
                    Text("Sign Up")
                        .bold()
                        .disabled(email.isEmpty || password.isEmpty || passwordConfirm.isEmpty || password != passwordConfirm)
                }
            } else {
                HStack {
                    ProgressView()
                    Text("Signing you up")
                }
            }
        }.padding(.horizontal).padding(.horizontal).background(Color.backgroundColour)
            .alert("\(alertTitle)", isPresented: $alertPresented) {
                Button(role: .cancel){
                    if alertTitle == "Account Created" {
                        isPresented = false
                    }
                } label: {
                    Text("OK")
                }
            } message: {
                Text(alertMessage)
            }

    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(isPresented: .constant(false))
    }
}
