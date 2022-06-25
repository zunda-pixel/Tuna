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
  private static let expireDateKey = "expireDate"
  private static let refreshTokenKey = "refreshToken"
  private static let userBearerTokenKey = "userBearerToken"
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

  static func getUserBearerToken(userID: String) -> String {
    let refreshToken = keychain[userID + userBearerTokenKey]!
    return refreshToken
  }

  static func setUserBearerToken(userID: String, newUserBearerToken: String) {
    keychain[userID + userBearerTokenKey] = newUserBearerToken
  }

  static func getRefreshToken(userID: String) -> String {
    let refreshToken = keychain[userID + refreshTokenKey]!
    return refreshToken
  }

  static func setRefreshToken(userID: String, refreshToken: String) {
    keychain[userID + refreshTokenKey] = refreshToken
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

  static func getExpireDate(userID: String) -> Date {
    guard let expireDateString = userDefaults.string(forKey: userID + expireDateKey) else {
      let today = Date()
      let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
      return yesterday
    }

    let expireDate = dateFormatter.date(from: expireDateString)!

    return expireDate
  }

  static func setExpireDate(userID: String, expireDate: Date) {
    let expireDateString = dateFormatter.string(from: expireDate)
    userDefaults.set(expireDateString, forKey: userID + expireDateKey)
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
