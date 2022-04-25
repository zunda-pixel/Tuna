//
//  DeepLink.swift
//  Tuna
//
//  Created by zunda on 2022/03/23.
//

import Foundation
import KeychainAccess
import Sweet

struct DeepLink {
  static func doSomething(_ url: URL) async throws {
    let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!

    guard let queryItems = components.queryItems,
      let savedState = Secret.state
    else { return }

    if let state = queryItems.first(where: { $0.name == "state" })?.value,
      let code = queryItems.first(where: { $0.name == "code" })?.value,
      state == savedState {
      try await saveOAuthData(code: code)
    }
  }

  private static func getMyUserID(userBearerToken: String) async throws -> String {
    let sweet: Sweet = .init(app: "", user: userBearerToken)
    let response = try await sweet.lookUpMe()
    return response.user.id
  }

  private static func saveOAuthData(code: String) async throws {
    guard let challenge = Secret.challenge else {
      return
    }

    let response = try await TwitterOAuth2().getUserBearerToken(
      code: code, callBackURL: Secret.callBackURL, challenge: challenge)

    let userID = try await getMyUserID(userBearerToken: response.bearerToken)

    Secret.addLoginUser(userID)
    Secret.currentUserID = userID
    Secret.userBearerToken = response.bearerToken
    Secret.refreshToken = response.refreshToken

    var dateComponent = DateComponents()
    dateComponent.second = response.expiredSeconds

    let expireDate = Calendar.current.date(byAdding: dateComponent, to: Date())!
    Secret.expireDate = expireDate

    try! Secret.removeState()
    try! Secret.removeChallenge()
  }
}
