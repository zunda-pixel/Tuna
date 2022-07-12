import SwiftUI
import Sweet

struct TweetDetailInformation: View {
  let userID: String
  let tweetID: String

  let metrics: Sweet.TweetPublicMetrics

  var body: some View {
    HStack {
      HStack {
        Image(systemName: "arrow.turn.up.left")
        Text("\(metrics.replyCount)")
      }

      let retweetUsersViewModel: RetweetUsersViewModel = .init(userID: userID, tweetID: tweetID)
      NavigationLink(value: retweetUsersViewModel) {
        HStack {
          Image(systemName: "arrow.2.squarepath")
          Text("\(metrics.retweetCount)")
        }
      }

      let quotedTweetViewModel: QuoteTweetsViewModel = .init(userID: userID, source: tweetID)
      NavigationLink(value: quotedTweetViewModel) {
        HStack {
          Image(systemName: "quote.bubble")
          Text("\(metrics.quoteCount)")
        }
      }

      let likeUsersViewModel: LikeUsersViewModel = .init(userID: userID, tweetID: tweetID)
      NavigationLink(value: likeUsersViewModel) {
        HStack {
          Image(systemName: "heart")
          Text("\(metrics.likeCount)")
        }
      }
    }
  }
}
