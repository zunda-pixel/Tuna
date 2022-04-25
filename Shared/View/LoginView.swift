//
//  LoginView.swift
//  Tuna
//
//  Created by zunda on 2022/03/23.
//

import KeychainAccess
import SwiftUI

struct LoginView: View {
  @State var loading = false

  func getRandomString() -> String {
    let challenge = SecurityRandom.secureRandomBytes(count: 10)
    return challenge.reduce(into: "") { $0 = $0 + "\($1)" }
  }

  func getAuthorizeURL() -> URL {
    let challenge = getRandomString()
    Secret.challenge = challenge

    let state = getRandomString()
    Secret.state = state

    let url = TwitterOAuth2().getAuthorizeURL(
      scopes: TwitterScope.allCases,
      callBackURL: Secret.callBackURL,
      challenge: challenge,
      state: state
    )

    return url
  }

  var body: some View {
    VStack {
      let url = getAuthorizeURL()
      Link("LOGIN", destination: url)
      if loading {
        Text("Loading...")
      }
    }


      .onOpenURL { url in
        Task {
          do {
            loading = true
            
            defer {
              loading = false
            }

            try await DeepLink.doSomething(url)
          } catch {
            print(error)
            fatalError()
          }
        }
      }
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView()
  }
}
