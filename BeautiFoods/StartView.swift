//
//  StartView.swift
//  BeautiFoods
//
//  Created by Tham En Jie on 18/9/22.
//

import SwiftUI

struct StartView: View {
    
    @Binding var loginState: LoginState
    
    @ObservedObject var cartManager: CartItemManager
    
    @State var loadLoginPage = false
    
    var body: some View {
        VStack {
            if !loadLoginPage {
                Button {
                    withAnimation(.easeOut) {
                        loadLoginPage = true
                    }
                } label: {
                    Text("Get Started")
                }
            } else { LoginView(loginState: $loginState, cartManager: cartManager, isPresented: $loadLoginPage) }
        }.background(Color.backgroundColour)
    }
}

struct CustomInputField: ViewModifier {
    var contentType: UITextContentType
    func body(content: Content) -> some View {
        content
            .font(Font.title2)
            .textFieldStyle(.plain)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .textContentType(contentType)
            .overlay{
                VStack {
                    Spacer()
                    Rectangle().frame(height: 1).foregroundColor(.secondary)
                }
            }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView(loginState: .constant(.notLoggedIn), cartManager: CartItemManager())
    }
}
