//
//  DeepLink.swift
//  Tuna
//
//  Created by zunda on 2022/03/23.
//

import Foundation
import Sweet
import CoreData

protocol DeepLinkDelegate {
  func setUserID(userID: String)
  func addUser(user: Sweet.UserModel) throws
}

struct DeepLink {
  let delegate: DeepLinkDelegate
  let context: NSManagedObjectContext

  func doSomething(_ url: URL) async throws {
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

  private func getMyUser(userBearerToken: String) async throws -> Sweet.UserModel {
    let sweet: Sweet = .init(app: "", user: userBearerToken)
    let response = try await sweet.lookUpMe()
    return response.user
  }

  private func saveOAuthData(code: String) async throws {
    guard let challenge = Secret.challenge else {
      return
    }

    let response = try await TwitterOAuth2().getUserBearerToken(
      code: code, callBackURL: Secret.callBackURL, challenge: challenge)

    let user = try await getMyUser(userBearerToken: response.bearerToken)

    Secret.currentUserID = user.id
    Secret.setUserBearerToken(userID: user.id, newUserBearerToken: response.bearerToken)
    Secret.setRefreshToken(userID: user.id, refreshToken: response.refreshToken)

    var dateComponent = DateComponents()
    dateComponent.second = response.expiredSeconds

    let expireDate = Calendar.current.date(byAdding: dateComponent, to: Date())!
    Secret.setExpireDate(userID: user.id, expireDate: expireDate)

    try Secret.removeState()
    try Secret.removeChallenge()

    try delegate.addUser(user: user)
    delegate.setUserID(userID: user.id)
  }
}
