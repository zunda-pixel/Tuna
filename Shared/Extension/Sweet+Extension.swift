//
//  Sweet+Extension.swift
//  Tuna
//
//  Created by zunda on 2022/03/23.
//

import Foundation
import Sweet
import KeychainAccess

// refresh

extension Sweet {
	static func updateUserBearerToken() async throws {
    let refreshToken = Secret.refreshToken
		let response = try await TwitterOAuth2().getRefreshUserBearerToken(refreshToken: refreshToken)
    
    var dateComponent = DateComponents()
    dateComponent.second = response.expiredSeconds
    
    let expireDate = Calendar.current.date(byAdding: dateComponent, to: Date())!
    
    Secret.refreshToken = response.refreshToken
    Secret.userBearerToken = response.bearerToken
    Secret.expireDate = expireDate
  }
  
	init() async throws {
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
