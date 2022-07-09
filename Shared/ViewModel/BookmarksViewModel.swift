//
//  BookmarksViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/05/25.
//

import Foundation
import CoreData
import Sweet

final class BookmarksViewModel: TweetsViewProtocol {
  static func == (lhs: BookmarksViewModel, rhs: BookmarksViewModel) -> Bool {
    lhs.userID == rhs.userID
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(loadingTweets)
    hasher.combine(paginationToken)
    hasher.combine(latestTapTweetID)
    hasher.combine(timelines)
    hasher.combine(userID)
  }

  var loadingTweets = false
  var paginationToken: String?
  var latestTapTweetID: String?
  var error: Error?
  var timelines: [String] = []

  let userID: String

  @Published var isPresentedTweetToolbar: Bool = false
  @Published var didError: Bool = false
  
  var allTweets: [Sweet.TweetModel] = []
  var allUsers: [Sweet.UserModel] = []
  var allMedias: [Sweet.MediaModel] = []
  var allPolls: [Sweet.PollModel] = []
  var allPlaces: [Sweet.PlaceModel] = []
  
  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async {
    do {
      let response = try await Sweet(userID: userID).fetchBookmarks(userID: userID, paginationToken: paginationToken)

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
  }
}
