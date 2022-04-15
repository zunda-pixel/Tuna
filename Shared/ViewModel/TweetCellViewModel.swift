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
  var error: Error?
  let tweet: Sweet.TweetModel
  let retweetTweet: Sweet.TweetModel?
  let authorUser: Sweet.UserModel
  let retweetUser: Sweet.UserModel?
  let medias: [Sweet.MediaModel]
  let poll: Sweet.PollModel?
  let place: Sweet.PlaceModel?

  var selectedMediaURL: URL?

  @Published var isPresentedImageView = false
  @Published var isPresentedErrorAlert = false
  @Published var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  @Published var nowDate: Date = Date()

  init(tweet: Sweet.TweetModel, retweet retweetTweet: Sweet.TweetModel? = nil,
       author authorUser: Sweet.UserModel, retweetUser: Sweet.UserModel? = nil,
       medias: [Sweet.MediaModel] = [],poll: Sweet.PollModel? = nil, place: Sweet.PlaceModel? = nil
  ) {
    self.tweet = tweet
    self.retweetTweet = retweetTweet
    self.authorUser = authorUser
    self.retweetUser = retweetUser
    self.medias = medias
    self.poll = poll
    self.place = place
  }

  var tweetText: String {
    if tweet.referencedTweet?.type == .retweeted {
      return retweetTweet!.text
    } else {
      return tweet.text
    }
  }

  var duration: String {
    guard let createdAt = (retweetTweet ?? tweet).createdAt else {
      return ""
    }

    let components: [Calendar.Component] = [.day, .hour, .minute, .second]

    let durationString = Calendar.current.durationString(
      candidate: components, from: createdAt, to: nowDate)

    return durationString!
  }

  var iconUser: Sweet.UserModel {
    switch tweet.referencedTweet?.type {
      case .repliedTo:
        return authorUser
      case .retweeted:
        return retweetUser!
      case .quoted:
        return authorUser
      case .none:
        return authorUser
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
  var totalVote: Int {
    return self.options.reduce(into: 0) { $0 = $0 + $1.votes }
  }
}
