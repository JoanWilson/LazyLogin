//
//  GithubLoginButton.swift
//  LazyLogin
//
//  Created by Joan Wilson Oliveira on 12/09/24.
//

import SwiftUI

struct GithubLoginButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 5)
                .tint(Color("github_color"))
                .frame(height: 60)
                .overlay {
                    HStack {
                        Image("icon_github")
                            .resizable()
                            .scaledToFit()
                        Text("Log in with Github")
                            .foregroundStyle(.background)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                    }
                    .padding(15)
                }
                .padding(.horizontal, 50)
        }
    }
}

#Preview {
    GithubLoginButton {

    }
}

