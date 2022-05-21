//
//  Secret.swift
//  Tuna
//
//  Created by zunda on 2022/03/23.
//

import Foundation
import KeychainAccess
import Sweet

struct Secret {
  static let callBackURL: URL = .init(string: "tuna://")!
  static let bundleIdentifier = "com.zunda.tuna"

  private static let currentUserIDKey = "currentUserID"
  private static let expireDateKey = "\(currentUserID!)-expireDate"
  private static let refreshTokenKey = "\(currentUserID!)-refreshToken"
  private static let userBearerTokenKey = "\(currentUserID!)-userBearerToken"
  private static let challengeKey = "challenge"
  private static let stateKey = "state"
  private static let loginUserIDsKey = "loginUserID"

  private static let dateFormatter = Sweet.TwitterDateFormatter()
  private static let userDefaults = UserDefaults()

  static func removeChallenge() throws {
    let keychain = Keychain()
    try keychain.remove(challengeKey)
  }

  static func removeState() throws {
    let keychain = Keychain()
    try keychain.remove(stateKey)
  }

  static var challenge: String? {
    get {
      let keychain = Keychain()
      let challenge = keychain[challengeKey]
      return challenge
    }
    set {
      let keychain = Keychain()
      keychain[challengeKey] = newValue
    }
  }

  static var state: String? {
    get {
      let keychain = Keychain()
      let state = keychain[stateKey]
      return state
    }
    set {
      let keychain = Keychain()
      keychain[stateKey] = newValue
    }
  }

  static var userBearerToken: String {
    get {
      let keychain = Keychain()
      let refreshToken = keychain[userBearerTokenKey]!
      return refreshToken
    }
    set {
      let keychain = Keychain()
      keychain[userBearerTokenKey] = newValue
    }
  }

  static var refreshToken: String {
    get {
      let keychain = Keychain()
      let refreshToken = keychain[refreshTokenKey]!
      return refreshToken
    }
    set {
      let keychain = Keychain()
      keychain[refreshTokenKey] = newValue
    }
  }

  static var loginUserIDs: [String] {
    get {
      let loginUserIDs = userDefaults.stringArray(forKey: loginUserIDsKey)

      return loginUserIDs ?? []
    }
  }

  static func addLoginUser(_ userID: String) {
    var loginUserIDs = loginUserIDs
    loginUserIDs.append(userID)
    userDefaults.set(loginUserIDs, forKey: loginUserIDsKey)
  }

  static func removeLoginUser(_ userID: String) {
    let loginUserIDs = loginUserIDs.filter { $0 != userID }
    userDefaults.set(loginUserIDs, forKey: loginUserIDsKey)
  }

  static var expireDate: Date {
    get {
      let expireDateString = userDefaults.string(forKey: expireDateKey)!
      let expireDate = dateFormatter.date(from: expireDateString)!
      return expireDate
    }
    set {
      let expireDateString = dateFormatter.string(from: newValue)
      userDefaults.set(expireDateString, forKey: expireDateKey)
    }
  }

  static var currentUserID: String? {
    get {
      return userDefaults.string(forKey: currentUserIDKey)
    }
    set {
      userDefaults.set(newValue, forKey: currentUserIDKey)
    }
  }
}
