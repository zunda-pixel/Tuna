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
  static let clientID = "ak1laUJKdGNIa21pTGFZX3A2SjQ6MTpjaQ"
  static let clientSecretKey = "MaNP3s7J6kK0bAfyOp9WrQtj7XmaReLyiBuH1mE7aDPdJNjv4g"
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
  private static let keychain = Keychain()

  static func removeChallenge() throws {
    try keychain.remove(challengeKey)
  }

  static func removeState() throws {
    try keychain.remove(stateKey)
  }

  static var challenge: String? {
    get {
      let challenge = keychain[challengeKey]
      return challenge
    }
    set {
      keychain[challengeKey] = newValue
    }
  }

  static var state: String? {
    get {
      let state = keychain[stateKey]
      return state
    }
    set {
      keychain[stateKey] = newValue
    }
  }

  static var userBearerToken: String {
    get {
      let refreshToken = keychain[userBearerTokenKey]!
      return refreshToken
    }
    set {
      keychain[userBearerTokenKey] = newValue
    }
  }

  static var refreshToken: String {
    get {
      let refreshToken = keychain[refreshTokenKey]!
      return refreshToken
    }
    set {
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
      guard let expireDateString = userDefaults.string(forKey: expireDateKey) else {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        return yesterday
      }

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
