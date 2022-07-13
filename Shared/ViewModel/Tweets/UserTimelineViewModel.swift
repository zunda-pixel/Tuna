//
//  UserTimelineViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/06/02.
//

import Foundation
import Sweet

final class UserTimelineViewModel: TweetsViewProtocol {
  static func == (lhs: UserTimelineViewModel, rhs: UserTimelineViewModel) -> Bool {
    lhs.userID == rhs.userID && lhs.ownerID == rhs.ownerID
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(loadingTweets)
    hasher.combine(paginationToken)
    hasher.combine(latestTapTweetID)
    hasher.combine(timelines)
    hasher.combine(userID)
    hasher.combine(ownerID)
  }
  
  let userID: String
  let ownerID: String

  var latestTapTweetID: String?
  var error: Error?

  @Published var didError: Bool = false
  @Published var loadingTweets: Bool = false
  @Published var isPresentedTweetToolbar: Bool = false

  var paginationToken: String?

  var timelines: [String] = []
  var allTweets: [Sweet.TweetModel] = []
  var allUsers: [Sweet.UserModel] = []
  var allMedias: [Sweet.MediaModel] = []
  var allPolls: [Sweet.PollModel] = []
  var allPlaces: [Sweet.PlaceModel] = []
  
  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async {
    do {
      let response = try await Sweet(userID: userID).fetchTimeLine(userID: ownerID, maxResults: 10, untilID: lastTweetID, sinceID: firstTweetID, paginationToken: paginationToken)



      paginationToken = response.meta?.nextToken

      addAllResponse(response: response)

      let referencedTweetIDs = response.relatedTweets.flatMap(\.referencedTweets).map(\.id)

      if referencedTweetIDs.count > 0 {
        print(referencedTweetIDs)

        let referencedResponse = try await Sweet(userID: userID).lookUpTweets(by: referencedTweetIDs)

        addAllResponse(response: referencedResponse)
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

  init(userID: String, ownerID: String) {
    self.userID = userID
    self.ownerID = ownerID
  }
}
