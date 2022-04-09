//
//  Tweet+Extension.swift
//  Tuna
//
//  Created by zunda on 2022/03/23.
//

import Foundation
import Sweet

extension Tweet {
  public func setTweetModel(_ tweet: Sweet.TweetModel) throws {
    self.id = tweet.id
    self.text = tweet.text
    self.authorID = tweet.authorID
    self.lang = tweet.lang
    self.createdAt = tweet.createdAt
    self.replySetting = tweet.replySetting?.rawValue
    self.conversationID = tweet.conversationID
    self.source = tweet.source
    self.replyUserID = tweet.replyUserID
    
    let encoder = JSONEncoder()
    self.geo = try encoder.encode(tweet.geo)
    self.entitis = try encoder.encode(tweet.entity)
    self.attachments = try encoder.encode(tweet.attachments)
    self.contextAnnotations = try encoder.encode(tweet.contextAnnotations)
    self.organicMetrics = try encoder.encode(tweet.organicMetrics)
    self.privateMetrics = try encoder.encode(tweet.privateMetrics)
    self.promotedMerics = try encoder.encode(tweet.promotedMerics)
    self.publicMetrics =  try encoder.encode(tweet.publicMetrics)
    self.referencedTweet = try encoder.encode(tweet.referencedTweet)
    self.withheld = try encoder.encode(tweet.withheld)
  }
}
