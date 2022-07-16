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
    hasher.combine(timelines)
    hasher.combine(userID)
    hasher.combine(ownerID)
  }
  
  let userID: String
  let ownerID: String

  var error: Error?

  @Published var didError: Bool = false

  var timelines: [String] = []
  var allTweets: [Sweet.TweetModel] = []
  var allUsers: [Sweet.UserModel] = []
  var allMedias: [Sweet.MediaModel] = []
  var allPolls: [Sweet.PollModel] = []
  var allPlaces: [Sweet.PlaceModel] = []
  
  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async {
    do {
      let response = try await Sweet(userID: userID).fetchTimeLine(userID: ownerID, untilID: lastTweetID, sinceID: firstTweetID)

      addResponse(response: response)

      let referencedTweetIDs = response.relatedTweets.lazy.flatMap(\.referencedTweets).filter({$0.type == .quoted}).map(\.id)

      if referencedTweetIDs.count > 0 {
        let referencedResponse = try await Sweet(userID: userID).lookUpTweets(by: Array(referencedTweetIDs))

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

  init(userID: String, ownerID: String) {
    self.userID = userID
    self.ownerID = ownerID
  }
}
