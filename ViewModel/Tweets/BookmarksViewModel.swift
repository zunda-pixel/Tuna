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
    hasher.combine(paginationToken)
    hasher.combine(timelines)
    hasher.combine(userID)
  }

  var paginationToken: String?
  var error: Error?
  var timelines: [String] = []

  let userID: String

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
