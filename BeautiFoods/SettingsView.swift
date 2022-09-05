//
//  SettingsContentView.swift
//  BeautiFoods
//
//  Created by Tham En Jie on 25/8/22.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section("Greet") {
                Text("HI")
                Text("HIel")
            }
            Section("Go") {
                Text("bye")
                Text("bye-bye")
            }
        }
    }
}

struct SettingsContentView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
