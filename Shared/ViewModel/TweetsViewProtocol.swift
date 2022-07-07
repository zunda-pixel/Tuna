//
//  TweetsViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/04/21.
//

import Foundation
import Sweet
import CoreData

@MainActor protocol TweetsViewProtocol: NSFetchedResultsControllerDelegate, ObservableObject {
  var loadingTweets: Bool { get set }

  var userID: String { get }
  var isPresentedTweetToolbar: Bool { get set }
  var isPresentedTweetDetail: Bool { get set }
  var latestTapTweetID: String? { get set }

  var error: Error? { get }
  var didError: Bool { get set }

  var paginationToken: String? { get set }

  var showTweets: [Tweet] { get }
  var allUsers: [User] { get }
  var allMedias: [Media] { get }
  var allPolls: [Poll] { get }
  var allPlaces: [Place] { get }

  func addTimeline(_ tweetID: String) throws
  func addTweet(_ tweet: Sweet.TweetModel) throws
  func addUser(_ user: Sweet.UserModel) throws
  func addPlace(_ place: Sweet.PlaceModel) throws
  func addPoll(_ poll: Sweet.PollModel) throws
  func addMedia(_ media: Sweet.MediaModel) throws

  func getTweet(_ tweetID: String?) -> Sweet.TweetModel?
  func getPoll(_ pollID: String?) -> Sweet.PollModel?
  func getUser(_ userID: String?) -> Sweet.UserModel?
  func getMedias(_ mediaIDs: [String]?) -> [Sweet.MediaModel]
  func getPlace(_ placeID: String?) -> Sweet.PlaceModel?

  func getTweetCellViewModel(_ tweetID: String) -> TweetCellViewModel

  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async
  func updateTimeLine()
}

extension TweetsViewProtocol {
  func getPlace(_ placeID: String?) -> Sweet.PlaceModel? {
    guard let placeID = placeID else { return nil }

    guard let firstPlace = allPlaces.first(where: { $0.id == placeID }) else {
      return nil
    }

    return .init(place: firstPlace)
  }

  func getPoll(_ pollID: String?) -> Sweet.PollModel? {
    guard let pollID = pollID else { return nil }

    guard let firstPoll = allPolls.first(where: { $0.id == pollID }) else { return nil }

    return .init(poll: firstPoll)
  }

  func getMedias(_ mediaIDs: [String]?) -> [Sweet.MediaModel] {
    guard let mediaIDs = mediaIDs else {
      return []
    }

    let medias = allMedias.filter({ mediaIDs.contains($0.key!) })

    return medias.map { .init(media: $0) }
  }

  func getUser(_ userID: String?) -> Sweet.UserModel? {
    guard let userID = userID else { return nil }

    guard let firstUser = allUsers.first(where: { $0.id == userID }) else { return nil }

    return .init(user: firstUser)
  }

  func getTweetCellViewModel(_ tweetID: String) -> TweetCellViewModel {
    let tweet = getTweet(tweetID)!

    let author = getUser(tweet.authorID!)!

    let retweet: (user: Sweet.UserModel, tweet: Sweet.TweetModel)? = {
      if tweet.referencedTweet?.type != .retweeted { return nil }

      let tweet = getTweet(tweet.referencedTweet?.id)!
      let user = getUser(tweet.authorID)!

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

