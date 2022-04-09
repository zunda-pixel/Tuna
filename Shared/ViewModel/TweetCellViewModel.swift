//
//  TweetViewModel.swift
//  Tuna (iOS)
//
//  Created by zunda on 2022/03/22.
//

import Foundation
import Sweet
import SwiftUI

@MainActor class TweetCellViewModel: ObservableObject {
  public var error: Error?
  public let tweet: Sweet.TweetModel
  public let retweetTweet: Sweet.TweetModel?
  public let authorUser: Sweet.UserModel
  public let retweetUser: Sweet.UserModel?
  public let medias: [Sweet.MediaModel]
  public let poll: Sweet.PollModel?
  public let place: Sweet.PlaceModel?
  
  public var selectedMediaURL: URL?
  public var isRetweet: Bool
  
  @Published var isPresentedImageView = false
  @Published var isPresentedErrorAlert = false
  @Published var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  @Published var nowDate: Date = Date()
  
  public init(isRetweet: Bool = false, tweet: Sweet.TweetModel, retweet retweetTweet : Sweet.TweetModel? = nil,
              author authorUser : Sweet.UserModel, retweetUser: Sweet.UserModel? = nil, medias: [Sweet.MediaModel] = [],
              poll: Sweet.PollModel? = nil, place: Sweet.PlaceModel? = nil) {
    self.isRetweet = isRetweet
    self.tweet = tweet
    self.retweetTweet = retweetTweet
    self.authorUser = authorUser
    self.retweetUser = retweetUser
    self.medias = medias
    self.poll = poll
    self.place = place
  }
  
  public var tweetText: String {
    if tweet.referencedTweet?.type == .retweeted {
      return retweetTweet!.text
    } else {
      return tweet.text
    }
  }
  
  public var duration: String {
    guard let createdAt = (retweetTweet ?? tweet).createdAt else {
      return ""
    }
    
    let components: [Calendar.Component]  = [.day, .hour, .minute, .second]
    
    let durationString = Calendar.current.durationString(candidate: components, from: createdAt, to: nowDate)
    
    return durationString!
  }
  
  public var iconUser: Sweet.UserModel {
    guard let type = tweet.referencedTweet?.type else {
      return authorUser
    }
    
    switch type {
      case .repliedTo:
        return  authorUser
      case .retweeted:
        return  retweetUser!
      case .quoted:
        return  retweetUser!
    }
  }
  
  func getVotePercent(_ poll: Sweet.PollModel, votes: Int) -> Int {
    let sumVotes = poll.totalVote
    
    if sumVotes == 0 {
      return 0
    }
    
    let percent: Double = Double(votes) / Double(sumVotes) * 100
    
    return Int(percent)
  }
}

extension Sweet.PollModel {
  public var totalVote: Int {
    return self.options.reduce(into: 0) { $0 = $0 + $1.votes }
  }
}
