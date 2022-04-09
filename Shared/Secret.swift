//
//  Secret.swift
//  Tuna
//
//  Created by zunda on 2022/03/23.
//

import Foundation
import KeychainAccess
import Sweet

internal struct Secret {
  public static let clientID = ""
  public static let clientSecretKey = ""
  public static let callBackURL: URL = .init(string: "tuna://")!
  public static let bundleIdentifier = "com.zunda.tuna"
  
  private static let currentUserIDKey = "currentUserID"
  private static let expireDateKey = "\(currentUserID)-expireDate"
  private static let refleshTokenKey = "\(currentUserID)-refleshToken"
  private static let userBearerTokenKey = "\(currentUserID)-userBearerToken"
  private static let challengeKey =  "challenge"
  private static let stateKey = "state"
  
  public static func removeChallenge() throws {
    let keychain = Keychain()
    try keychain.remove(challengeKey)
  }
  
  public static func removeState() throws {
    let keychain = Keychain()
    try keychain.remove(stateKey)
  }
  
  public static var challenge: String? {
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
  
  public static var state: String? {
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

  public static var userBearerToken: String {
    get {
      let keychain = Keychain()
      let refleshToken = keychain[userBearerTokenKey]!
      return refleshToken
    }
    set {
      let keychain = Keychain()
      keychain[userBearerTokenKey] = newValue
    }
  }
  
  public static var refleshToken: String {
    get {
      let keychain = Keychain()
      let refleshToken = keychain[refleshTokenKey]!
      return refleshToken
    }
    set {
      let keychain = Keychain()
      keychain[refleshTokenKey] = newValue
    }
  }
  
  public static var expireDate: Date {
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
  
  public static var currentUserID: String {
    get {
      return UserDefaults().string(forKey: currentUserIDKey)!
    }
    set {
      UserDefaults().set(newValue, forKey: currentUserIDKey)
    }
  }
}
