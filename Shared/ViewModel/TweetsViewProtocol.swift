//
//  TweetsViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/04/21.
//

import Foundation
import Sweet
import CoreData

@MainActor protocol TweetsViewProtocol: ObservableObject, Hashable {
  var loadingTweets: Bool { get set }

  var userID: String { get }
  var isPresentedTweetToolbar: Bool { get set }
  var isPresentedTweetDetail: Bool { get set }
  var latestTapTweetID: String? { get set }

  var error: Error? { get }
  var didError: Bool { get set }

  var paginationToken: String? { get set }

  var timelines: [String] { get set }
  var showTweets: [Sweet.TweetModel] { get }
  var allTweets: [Sweet.TweetModel] { get set }
  var allUsers: [Sweet.UserModel] { get set }
  var allMedias: [Sweet.MediaModel] { get set }
  var allPolls: [Sweet.PollModel] { get set }
  var allPlaces: [Sweet.PlaceModel] { get set }

  func addTimeline(_ tweetID: String)
  func addTweet(_ tweet: Sweet.TweetModel)
  func addUser(_ user: Sweet.UserModel)
  func addPlace(_ place: Sweet.PlaceModel)
  func addPoll(_ poll: Sweet.PollModel)
  func addMedia(_ media: Sweet.MediaModel)

  func getTweet(_ tweetID: String?) -> Sweet.TweetModel?
  func getPoll(_ pollID: String?) -> Sweet.PollModel?
  func getUser(_ userID: String?) -> Sweet.UserModel?
  func getMedias(_ mediaIDs: [String]?) -> [Sweet.MediaModel]
  func getPlace(_ placeID: String?) -> Sweet.PlaceModel?

  func getTweetCellViewModel(_ tweetID: String) -> TweetCellViewModel

  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async
}

extension TweetsViewProtocol {
  var showTweets: [Sweet.TweetModel] {
    timelines.map { timeline in
      allTweets.first(where: { $0.id == timeline })!
    }.lazy.sorted(by: { $0.createdAt! > $1.createdAt! })
  }

  func addTimeline(_ tweetID: String) {
    if timelines.contains(where: { $0 == tweetID }) {
      return
    }

    timelines.append(tweetID)
  }

  func addPlace(_ place: Sweet.PlaceModel) {
    if let foundIndex = allPlaces.firstIndex(where: { $0.id == place.id }) {
      allPlaces[foundIndex] = place
    } else {
      allPlaces.append(place)
    }
  }

  func addTweet(_ tweet: Sweet.TweetModel) {
    if let foundIndex = allTweets.firstIndex(where: { $0.id == tweet.id }) {
      allTweets[foundIndex] = tweet
    } else {
      allTweets.append(tweet)
    }
  }

  func addPoll(_ poll: Sweet.PollModel) {
    if let foundIndex = allPolls.firstIndex(where: { $0.id == poll.id }) {
      allPolls[foundIndex] = poll
    } else {
      allPolls.append(poll)
    }
  }

  func addUser(_ user: Sweet.UserModel) {
    if let foundIndex = allUsers.firstIndex(where: { $0.id == user.id }) {
      allUsers[foundIndex] = user
    } else {
      allUsers.append(user)
    }
  }

  func addMedia(_ media: Sweet.MediaModel) {
    if let foundIndex = allMedias.firstIndex(where: { $0.key == media.key }) {
      allMedias[foundIndex] = media
    } else {
      allMedias.append(media)
    }
  }

  func getTweet(_ tweetID: String?) -> Sweet.TweetModel? {
    guard let tweetID = tweetID else { return nil }

    guard let tweet = showTweets.first(where: { $0.id == tweetID }) else { return nil }

    return tweet
  }

  func getPlace(_ placeID: String?) -> Sweet.PlaceModel? {
    guard let placeID = placeID else { return nil }

    guard let firstPlace = allPlaces.first(where: { $0.id == placeID }) else {
      return nil
    }

    return firstPlace
  }

  func getPoll(_ pollID: String?) -> Sweet.PollModel? {
    guard let pollID = pollID else { return nil }

    guard let firstPoll = allPolls.first(where: { $0.id == pollID }) else { return nil }

    return firstPoll
  }

  func getMedias(_ mediaIDs: [String]?) -> [Sweet.MediaModel] {
    guard let mediaIDs = mediaIDs else {
      return []
    }

    let medias = allMedias.filter({ mediaIDs.contains($0.key) })

    return medias
  }

  func getUser(_ userID: String?) -> Sweet.UserModel? {
    guard let userID = userID else { return nil }

    guard let firstUser = allUsers.first(where: { $0.id == userID }) else { return nil }

    return firstUser
  }

  func getTweetCellViewModel(_ tweetID: String) -> TweetCellViewModel {
    let tweet = getTweet(tweetID)!

    let author = getUser(tweet.authorID!)!

    let retweet: (user: Sweet.UserModel, tweet: Sweet.TweetModel)? = {
      if tweet.referencedTweet?.type != .retweeted { return nil }

      // TODO ほんとはCalendar.current.yesterdayらへんは必要ない
      // 取得できていないユーザーツイートが問題
      let tweet = getTweet(tweet.referencedTweet?.id) ?? .init(id: "312", text: "mikan", createdAt: Calendar.current.yesterday!)
      let user = getUser(tweet.authorID) ?? .init(id: "423", name: "jflsda", userName: "fdjklsa")

      return (user, tweet)
    }()

    let quoted: (user: Sweet.UserModel, tweet: Sweet.TweetModel)? = {
      guard let quotedTweetID: String? = {
        if tweet.referencedTweet?.type == .quoted {
          return tweet.referencedTweet?.id
        }

        if retweet?.tweet.referencedTweet?.type == .quoted {
          return retweet?.tweet.referencedTweet?.id
        }

        return nil
      }() else { return nil }

      // TODO ほんとはUUIDらへんは必要ない
      // 取得できていないユーザーツイートが問題
      let tweet = getTweet(quotedTweetID) ?? .init(id: UUID().uuidString, text: "Nothing Tweet")

      let user = getUser(tweet.authorID) ?? .init(id: UUID().uuidString, name: "Nothing Name", userName: "Nothing Name")

      return (user, tweet)
    }()

    let medias = getMedias(tweet.attachments?.mediaKeys)

    let poll = getPoll(tweet.attachments?.pollID)

    let place = getPlace(tweet.geo?.placeID)

    let viewModel: TweetCellViewModel = .init(
      userID: userID,
      tweet: tweet, author: author,
      retweet: retweet,
      quoted: quoted,
      medias: medias, poll: poll, place: place)

    return viewModel
  }
}

