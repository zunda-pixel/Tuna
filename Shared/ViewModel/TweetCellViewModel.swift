//
//  TweetViewModel.swift
//  Tuna (iOS)
//
//  Created by zunda on 2022/03/22.
//

import Foundation
import Sweet
import Combine

@MainActor protocol TweetCellViewProtocol: ObservableObject {
  var error: Error? { get set }
  var didError: Bool { get set }
  var tweet: Sweet.TweetModel  { get }
  var retweetTweet: Sweet.TweetModel? { get }
  var authorUser: Sweet.UserModel { get }
  var retweetUser: Sweet.UserModel? { get }
  var medias: [Sweet.MediaModel] { get }
  var poll: Sweet.PollModel? { get }
  var place: Sweet.PlaceModel? { get }
  var isPresentedImageView: Bool { get set }
  var timer: Publishers.Autoconnect<Timer.TimerPublisher> { get set }
  var nowDate: Date { get set }
  var selectedMediaURL: URL? { get set }
  var tweetText: String { get }
  var duration: String { get }
  var iconUser: Sweet.UserModel { get }
  func getVotePercent(_ poll: Sweet.PollModel, votes: Int) -> Int
}
@MainActor class TweetCellViewModel: TweetCellViewProtocol {
  var error: Error?
  let tweet: Sweet.TweetModel
  let retweetTweet: Sweet.TweetModel?
  let authorUser: Sweet.UserModel
  let retweetUser: Sweet.UserModel?
  let medias: [Sweet.MediaModel]
  let poll: Sweet.PollModel?
  let place: Sweet.PlaceModel?
  var selectedMediaURL: URL?

  @Published var didError: Bool = false
  @Published var isPresentedImageView = false
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
