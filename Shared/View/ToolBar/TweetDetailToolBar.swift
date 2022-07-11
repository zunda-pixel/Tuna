import SwiftUI
import Sweet

struct TweetDetailInformation: View {
  let userID: String
  let tweetID: String

  let metrics: Sweet.TweetPublicMetrics

  var body: some View {
    HStack {
      NavigationLink {
        Text("Reply")
      } label: {
        HStack {
          Image(systemName: "arrow.turn.up.left")
          Text("\(metrics.replyCount)")
        }
      }

      NavigationLink {
        Text("Retweet")
      } label: {
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

      NavigationLink {
        Text("Like")
      } label: {
        HStack {
          Image(systemName: "heart")
          Text("\(metrics.likeCount)")
        }
      }


    }
  }
}
