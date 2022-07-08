//
//  UserTimelineViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/06/02.
//

import Foundation
import CoreData
import Sweet

final class UserTimelineViewModel: NSObject, TweetsViewProtocol {
  var userID: String
  var latestTapTweetID: String?
  var error: Error?

  @Published var didError: Bool = false
  @Published var loadingTweets: Bool = false
  @Published var isPresentedTweetToolbar: Bool = false
  @Published var isPresentedTweetDetail: Bool = false

  var paginationToken: String?

  var timelines: [String] = []
  var allTweets: [Sweet.TweetModel] = []
  var allUsers: [Sweet.UserModel] = []
  var allMedias: [Sweet.MediaModel] = []
  var allPolls: [Sweet.PollModel] = []
  var allPlaces: [Sweet.PlaceModel] = []
  
  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async {
    do {
      let response = try await Sweet(userID: userID).fetchTimeLine(userID: userID, untilID: lastTweetID, sinceID: firstTweetID, paginationToken: paginationToken)

      paginationToken = response.meta?.nextToken

      response.tweets.forEach { tweet in
        addTweet(tweet)
      }

      response.relatedTweets.forEach { tweet in
        addTweet(tweet)
      }

      response.users.forEach { user in
        addUser(user)
      }

      response.medias.forEach { media in
        addMedia(media)
      }

      response.polls.forEach { poll in
        addPoll(poll)
      }

      response.places.forEach { place in
        addPlace(place)
      }

      response.tweets.forEach { tweet in
        addTimeline(tweet.id)
      }

      objectWillChange.send()
    } catch let newError {
      self.error = newError
      self.didError.toggle()
    }
  }

  init(userID: String) {
    self.userID = userID

    super.init()
  }
}
