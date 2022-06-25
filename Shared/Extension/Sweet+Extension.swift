//
//  Sweet+Extension.swift
//  Tuna
//
//  Created by zunda on 2022/03/23.
//

import Foundation
import Sweet

extension Sweet {
  static func updateUserBearerToken(userID: String) async throws {
    let refreshToken = Secret.getRefreshToken(userID: userID)
		let response = try await TwitterOAuth2().getRefreshUserBearerToken(refreshToken: refreshToken)
    
    var dateComponent = DateComponents()
    dateComponent.second = response.expiredSeconds
    
    let expireDate = Calendar.current.date(byAdding: dateComponent, to: Date())!
    
    Secret.setRefreshToken(userID: userID, refreshToken: response.refreshToken)
    Secret.setUserBearerToken(userID: userID, newUserBearerToken: response.bearerToken)
    Secret.setExpireDate(userID: userID, expireDate: expireDate)
  }
  
  init(userID: String) async throws {
    let expireDate = Secret.getExpireDate(userID: userID)
    
    if expireDate < Date() {
      try await Sweet.updateUserBearerToken(userID: userID)
    }
    
    let userBearerToken = Secret.getUserBearerToken(userID: userID)
        
    let appBearerToken = ""

    self.init(app: appBearerToken, user: userBearerToken)
    self.tweetFields = [.id, .text, .attachments, .authorID, .contextAnnotations, .createdAt, .entities, .geo, .replyToUserID, .lang, .possiblySensitive, .referencedTweets, .replySettings, .source, .withheld, .publicMetrics]

    self.mediaFields = [.mediaKey, .type, .height, .publicMetrics, .duration_ms, .previewImageURL, .url, .width, .altText]
  }
}
