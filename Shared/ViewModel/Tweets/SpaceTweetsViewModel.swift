import Foundation
import Sweet

final class SpaceTweetsViewModel: TweetsViewProtocol {
  static func == (lhs: SpaceTweetsViewModel, rhs: SpaceTweetsViewModel) -> Bool {
    lhs.userID == rhs.userID && lhs.spaceID == rhs.spaceID
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(loadingTweets)
    hasher.combine(paginationToken)
    hasher.combine(latestTapTweetID)
    hasher.combine(timelines)
    hasher.combine(userID)
    hasher.combine(spaceID)
  }

  @Published var loadingTweets = false
  var paginationToken: String?
  var latestTapTweetID: String?
  var error: Error?
  var timelines: [String] = []

  let userID: String
  let spaceID: String

  @Published var isPresentedTweetToolbar: Bool = false
  @Published var didError: Bool = false

  var allTweets: [Sweet.TweetModel] = []
  var allUsers: [Sweet.UserModel] = []
  var allMedias: [Sweet.MediaModel] = []
  var allPolls: [Sweet.PollModel] = []
  var allPlaces: [Sweet.PlaceModel] = []

  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async {
    do {
      let response = try await Sweet(userID: userID).fetchSpaceTweets(spaceID: spaceID)

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

  init(userID: String, spaceID: String) {
    self.userID = userID
    self.spaceID = spaceID
  }
}

