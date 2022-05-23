//
//  LoginView.swift
//  Tuna
//
//  Created by zunda on 2022/03/23.
//

import SwiftUI

struct LoginView: View {
  @Binding var userID: String?
  @State var error: Error?
  @State var didError = false

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

  func doSomething(url: URL) async {
    let deepLink = DeepLink(delegate: self)

    do {
      try await deepLink.doSomething(url)
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }

  var body: some View {
    let url = getAuthorizeURL()

    Link(destination: url) {
      Text("Login")
    }
    .alert("Error", isPresented: $didError) {
      Button {
        print(error!)
      } label: {
        Text("Close")
      }
    }
    .onOpenURL { url in
      Task {
        await doSomething(url: url)
      }
    }
  }
}

extension LoginView: DeepLinkDelegate {
  func setUserID(userID: String) {
    self.userID = userID
  }
}
