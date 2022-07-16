//
//  ListTweetsViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/06/03.
//

import Foundation
import Sweet

final class ListTweetsViewModel: NSObject, TweetsViewProtocol {
  var loadingTweets = false
  var paginationToken: String?
  var latestTapTweetID: String?
  var error: Error?
  var timelines: [String] = []

  let listID: String
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
      let maxResults = 100

      let listResponse = try await Sweet(userID: userID).fetchListTweets(listID: listID, maxResults: maxResults, paginationToken: paginationToken)

      paginationToken = listResponse.meta?.nextToken

      let tweetIDs = listResponse.tweets.map(\.id)

      if tweetIDs.isEmpty {
        return
      }

      let tweetResponse = try await  Sweet(userID: userID).lookUpTweets(by: tweetIDs)

      addResponse(response: tweetResponse)

      tweetResponse.tweets.forEach { tweet in
        addTimeline(tweet.id)
      }

      if let firstTweetID, tweetResponse.tweets.count == maxResults {
        await fetchTweets(first: firstTweetID, last: nil)
        return
      }

      objectWillChange.send()
    } catch let newError {
      self.error = newError
      self.didError.toggle()
    }
  }

  init(userID: String, listID: String) {
    self.userID = userID
    self.listID = listID
  }
}


