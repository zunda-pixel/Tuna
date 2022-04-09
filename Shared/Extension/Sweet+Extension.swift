//
//  Sweet+Extension.swift
//  Tuna
//
//  Created by zunda on 2022/03/23.
//

import Foundation
import Sweet
import KeychainAccess

extension Sweet {
  public static func updateUserBearerToken() async throws {
    let refleshToken = Secret.refleshToken
    let response = try await TwitterOauth2().getRefreshUserBearerToken(refleshToken: refleshToken)
    
    var dateComponent = DateComponents()
    dateComponent.second = response.expiredSeconds
    
    let expireDate = Calendar.current.date(byAdding: dateComponent, to: Date())!
    
    Secret.refleshToken = response.refleshToken
    Secret.userBearerToken = response.bearerToken
    Secret.expireDate = expireDate
  }
  
  public init() async throws {
    let expireDate = Secret.expireDate
    
    if expireDate < Date() {
      try await Sweet.updateUserBearerToken()
    }
    
    let userBearerToken = Secret.userBearerToken
        
    let appBearerToken = ""

    self.init(app: appBearerToken, user: userBearerToken)
    self.tweetFields = [.id, .text, .attachments, .authorID, .contextAnnotations, .createdAt, .entities, .geo, .replyToUserID, .lang, .possiblySensitive, .referencedTweets, .replySettings, .source, .withheld]
  }
}
