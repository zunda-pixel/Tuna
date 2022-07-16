import SwiftUI
import Sweet

struct TweetDetailInformation: View {
  let userID: String
  let tweetID: String

  let metrics: Sweet.TweetPublicMetrics

  @Binding var path: NavigationPath
  
  var body: some View {
    HStack {
      HStack {
        Image(systemName: "arrow.turn.up.left")
        Text("\(metrics.replyCount)")
      }

      HStack {
        Image(systemName: "arrow.2.squarepath")
        Text("\(metrics.retweetCount)")
      }
      .onTapGesture {
        let retweetUsersViewModel: RetweetUsersViewModel = .init(userID: userID, tweetID: tweetID)
        path.append(retweetUsersViewModel)
      }

      HStack {
        Image(systemName: "quote.bubble")
        Text("\(metrics.quoteCount)")
      }
      .onTapGesture {
        let quoteTweetViewModel: QuoteTweetsViewModel = .init(userID: userID, source: tweetID)
        path.append(quoteTweetViewModel)
      }

      HStack {
        Image(systemName: "heart")
        Text("\(metrics.likeCount)")
      }
      .onTapGesture {
        let likeUsersViewModel: LikeUsersViewModel = .init(userID: userID, tweetID: tweetID)
        path.append(likeUsersViewModel)
      }
    }
  }
}
