//
//  BookmarksViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/05/25.
//

import Foundation
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

  @Published var loadingTweets = false
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

      addResponse(response: response)

      let referencedTweetIDs = response.relatedTweets.flatMap(\.referencedTweets).map(\.id)

      if referencedTweetIDs.count > 0 {
        let referencedResponse = try await Sweet(userID: userID).lookUpTweets(by: referencedTweetIDs)

        addResponse(response: referencedResponse)
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
