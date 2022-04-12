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
  private static let expireDateKey = "\(currentUserID)-expireDate"
  private static let refreshTokenKey = "\(currentUserID)-refreshToken"
  private static let userBearerTokenKey = "\(currentUserID)-userBearerToken"
  private static let challengeKey = "challenge"
  private static let stateKey = "state"

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

  static var expireDate: Date {
    get {
      let expireDateString = UserDefaults().string(forKey: expireDateKey)!
      let expireDate = Sweet.TwitterDateFormatter().date(from: expireDateString)!

      return expireDate
    }
    set {
      let expireDateString = Sweet.TwitterDateFormatter().string(from: newValue)
      UserDefaults().set(expireDateString, forKey: expireDateKey)
    }
  }

  static var currentUserID: String {
    get {
      return UserDefaults().string(forKey: currentUserIDKey)!
    }
    set {
      UserDefaults().set(newValue, forKey: currentUserIDKey)
    }
  }
}
