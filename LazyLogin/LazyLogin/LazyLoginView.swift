//
//  LazyLoginView.swift
//  LazyLogin
//
//  Created by Joan Wilson Oliveira on 12/09/24.
//

import SwiftUI

struct LazyLoginView: View {
    @ObservedObject private var viewModel = ViewModel()

    var body: some View {
        VStack {
            if 
                let user = viewModel.user,
                let avatarUrl = user.avatarUrl,
                let name = user.name {
                AsyncImage(url: URL(string: avatarUrl)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())

                Text("Seja Bem-vindo \(name) !")
                    .font(.title2)
                    .padding(.bottom, 100)
            } else {
                GithubLoginButton {
                    openGithubOAuthAuthorization()
                }
            }
        }
        .padding()
        .onOpenURL { url in
            Task {
                await viewModel.handleCallback(url: url)
                await viewModel.fetchGithubUserData()
            }
        }
    }

    private func openGithubOAuthAuthorization() {
        if 
            let url = viewModel.getAuthorizationUrl(),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

#Preview {
    LazyLoginView()
}
