//
//  LoginView.swift
//  Tuna
//
//  Created by zunda on 2022/03/23.
//

import SwiftUI
import KeychainAccess

struct LoginView: View {
  func getRandomeString() -> String {
    let challenge = SecurityRandom.secureRandomBytes(count: 10)
    return challenge.reduce(into: "") { $0 = $0 + "\($1)" }
  }
  
  func getAuthorizeURL() -> URL {
    let challenge = getRandomeString()
    Secret.challenge = challenge
    
    let state = getRandomeString()
    Secret.state = state
    
    let url = TwitterOauth2().getAuthorizeURL(
      scopes: TwitterScope.allCases,
      callBackURL: Secret.callBackURL,
      challenge: challenge,
      state: state
    )
    
    return url
  }
  
  var body: some View {
    VStack(alignment: .center) {
      let url = getAuthorizeURL()
      Link("LOGIN", destination: url)
    }
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView()
  }
}
