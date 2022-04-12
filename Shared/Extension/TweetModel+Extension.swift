//
//  TweetModel+Extension.swift
//  Tuna
//
//  Created by zunda on 2022/03/24.
//

import Foundation
import Sweet

extension Sweet.TweetModel {
  init(tweet: Tweet) {
    let decoder = JSONDecoder()

    let emptyData = Data()

    let geo = try? decoder.decode(Sweet.GeoModel.self, from: tweet.geo ?? emptyData)
    let publicMetics = try? decoder.decode(
      Sweet.TweetPublicMetrics.self, from: tweet.publicMetrics ?? emptyData)
    let privateMetrics = try? decoder.decode(
      Sweet.PrivateMetrics.self, from: tweet.privateMetrics ?? emptyData)
    let organicMetrics = try? decoder.decode(
      Sweet.OrganicMetrics.self, from: tweet.organicMetrics ?? emptyData)
    let promotedMetrics = try? decoder.decode(
      Sweet.PromotedMetrics.self, from: tweet.promotedMetrics ?? emptyData)
    let attachments = try? decoder.decode(
      Sweet.AttachmentsModel.self, from: tweet.attachments ?? emptyData)
    let withheld = try? decoder.decode(Sweet.WithheldModel.self, from: tweet.withheld ?? emptyData)
    let contextAnnotations = try? decoder.decode(
      [Sweet.ContextAnnotationModel].self, from: tweet.contextAnnotations ?? emptyData)
    let entity = try? decoder.decode(Sweet.EntityModel.self, from: tweet.entities ?? emptyData)
    let referencedTweet = try? decoder.decode(
      Sweet.ReferencedTweetModel.self, from: tweet.referencedTweet ?? emptyData)

    let replySettings: Sweet.ReplySetting? = .init(rawValue: tweet.replySetting ?? "")

    self.init(
      id: tweet.id ?? "", text: tweet.text ?? "", authorID: tweet.authorID,
      lang: tweet.lang, replySetting: replySettings, createdAt: tweet.createdAt,
      source: tweet.source, sensitive: tweet.sensitive, conversationID: tweet.conversationID,
      replyUserID: tweet.replyUserID, geo: geo, publicMetrics: publicMetics,
      organicMetrics: organicMetrics, privateMetrics: privateMetrics,
      attachments: attachments, promotedMetrics: promotedMetrics,
      withheld: withheld, contextAnnotations: contextAnnotations ?? [],
      entity: entity, referencedTweet: referencedTweet)
  }
}
