//
//  TweetViewModel.swift
//  Tuna (iOS)
//
//  Created by zunda on 2022/03/22.
//

import Foundation
import Sweet
import Combine
import MapKit

@MainActor protocol TweetCellViewProtocol: ObservableObject, Hashable {
  var userID: String { get }
  var error: Error? { get set }
  var didError: Bool { get set }

  var author: Sweet.UserModel { get }
  var tweet: Sweet.TweetModel  { get }

  var retweet: (user: Sweet.UserModel, tweet: Sweet.TweetModel)? { get }
  var quoted: (user: Sweet.UserModel, tweet: Sweet.TweetModel)? { get }

  var medias: [Sweet.MediaModel] { get }
  var poll: Sweet.PollModel? { get }
  var place: Sweet.PlaceModel? { get }
  var tweetText: String { get }
  func duration(nowDate: Date) -> String
}

class TweetCellViewModel: TweetCellViewProtocol {
  func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(author)
    hasher.combine(tweet)
    hasher.combine(retweet?.tweet)
    hasher.combine(retweet?.user)
    hasher.combine(quoted?.tweet)
    hasher.combine(quoted?.user)
    hasher.combine(medias)
    hasher.combine(poll)
    hasher.combine(place)
  }

  static func == (lhs: TweetCellViewModel, rhs: TweetCellViewModel) -> Bool {
    lhs.tweet.id == rhs.tweet.id
  }

  let userID: String

  var error: Error?
  let author: Sweet.UserModel
  let tweet: Sweet.TweetModel

  let retweet: (user: Sweet.UserModel, tweet: Sweet.TweetModel)?

  let quoted: (user: Sweet.UserModel, tweet: Sweet.TweetModel)?

  let medias: [Sweet.MediaModel]
  let poll: Sweet.PollModel?
  let place: Sweet.PlaceModel?

  @Published var didError = false

  init(userID: String,
       tweet: Sweet.TweetModel, author : Sweet.UserModel,
       retweet: (Sweet.UserModel, Sweet.TweetModel)? = nil,
       quoted: (Sweet.UserModel, Sweet.TweetModel)? = nil,
       medias: [Sweet.MediaModel] = [],poll: Sweet.PollModel? = nil, place: Sweet.PlaceModel? = nil) {
    self.userID = userID

    self.tweet = tweet

    self.author = author

    self.retweet = retweet

    self.quoted = quoted

    self.medias = medias
    self.poll = poll
    self.place = place
  }

  var tweetText: String {
    if tweet.referencedTweet?.type == .retweeted {
      return retweet!.tweet.text
    } else {
      return tweet.text
    }
  }

  func duration(nowDate: Date) -> String {
    let createdAt: Date? = {
      switch tweet.referencedTweet?.type {
        case .none:
          return tweet.createdAt
        case .quoted:
          return tweet.createdAt
        case .repliedTo:
          return tweet.createdAt
        case .retweeted:
          return retweet?.tweet.createdAt
      }
    }()

    let components: [Calendar.Component] = [.day, .hour, .minute, .second]

    let durationString = Calendar.current.durationString(
      candidate: components, from: createdAt!, to: nowDate)

    return durationString!
  }
}


