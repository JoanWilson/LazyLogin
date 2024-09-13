//
//  ContentView.swift
//  LazyLogin
//
//  Created by Joan Wilson Oliveira on 12/09/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            GithubLoginButton {
                print("Fazer login")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
