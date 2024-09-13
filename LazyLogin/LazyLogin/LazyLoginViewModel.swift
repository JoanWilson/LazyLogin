//
//  LazyLoginViewModel.swift
//  LazyLogin
//
//  Created by Joan Wilson Oliveira on 12/09/24.
//

import Foundation

struct GithubOAuthKeysModel {
    let clientId: String
    let clientSecret: String
    let redirectUri: String
}

extension LazyLoginView {
    final class ViewModel: ObservableObject {
        @Published var user: User?

        init() {}

        private func getGithubKeys() -> GithubOAuthKeysModel? {
            guard let path = Bundle.main.path(forResource: "GithubOAuthKeys",
                                              ofType: "plist") else {
                return nil
            }

            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let plist = try PropertyListDecoder().decode([String: String].self, from: data)

                guard
                    let clientId = plist["clientId"],
                    let clientSecret = plist["clientSecret"],
                    let redirectUri = plist["redirectUri"] else { return nil }

                let keysModel = GithubOAuthKeysModel(
                    clientId: clientId,
                    clientSecret: clientSecret,
                    redirectUri: redirectUri)

                return keysModel
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }

        func getAuthorizationUrl() -> URL? {
            guard let keys = getGithubKeys() else { return nil }

             let urlStr = "https://github.com/login/oauth/authorize?client_id=\(keys.clientId)&redirect_uri=\(keys.redirectUri)&scope=user"

            return URL(string: urlStr)
        }

        func handleCallback(url: URL) async {
            guard
                let query = URLComponents(string: url.absoluteString)?.queryItems,
                let code = query.first(where: { $0.name == "code" })?.value else { return }

            await exchangeCodeForToken(code: code)
        }

        func exchangeCodeForToken(code: String) async {
            guard 
                let keys = getGithubKeys(),
                let url = URL(string: "https://github.com/login/oauth/access_token") else { return }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

            let body = "client_id=\(keys.clientId)&client_secret=\(keys.clientSecret)&code=\(code)&redirect_uri=\(keys.redirectUri)"

            request.httpBody = body.data(using: .utf8)

            do {
                let (data, _) = try await URLSession.shared.data(for: request)

                guard let token = extractToken(from: data) else { return }

                if let tokenData = token.data(using: .utf8) {
                    let status = KeychainHelper.shared.save(key: GithubOAuthConstants.kAccessToken, data: tokenData)

                    if status {
                        print("Sucesso ao salvar no Keychain!")
                    } else {
                        print("Erro ao salvar no Keychain!")
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }

        private func extractToken(from data: Data) -> String? {
            do {
                let token = try JSONDecoder().decode(AccessToken.self, from: data)
                return token.accessToken
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }

        func fetchGithubUserData() async {
            guard
                let tokenData = KeychainHelper.shared.retrieve(key: GithubOAuthConstants.kAccessToken),
                let tokenStr = String(data: tokenData, encoding: .utf8),
                let url = URL(string: "https://api.github.com/user") else { return }

            var request = URLRequest(url: url)
            request.setValue("token \(tokenStr)", forHTTPHeaderField: "Authorization")

            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                let user = try JSONDecoder().decode(User.self, from: data)

                DispatchQueue.main.async {
                    self.user = user
                }
            } catch {
                print(error.localizedDescription)
            }

        }
    }
}

struct AccessToken: Codable {
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

struct User: Codable {
    let name: String?
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case name
        case avatarUrl = "avatar_url"
    }
}
