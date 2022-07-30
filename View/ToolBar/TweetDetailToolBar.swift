import SwiftUI
import Sweet

struct TweetDetailInformation: View {
  let userID: String
  let tweetID: String

  let metrics: Sweet.TweetPublicMetrics

  @Binding var path: NavigationPath
  
  var body: some View {
    HStack {
      Label("\(metrics.replyCount)", systemImage: "arrow.turn.up.left")
        .frame(maxWidth: .infinity)

      Label("\(metrics.retweetCount)", systemImage: "arrow.2.squarepath")
        .frame(maxWidth: .infinity)
        .onTapGesture {
          let retweetUsersViewModel: RetweetUsersViewModel = .init(userID: userID, tweetID: tweetID)
          path.append(retweetUsersViewModel)
        }

      Label("\(metrics.quoteCount)", systemImage: "quote.bubble")
        .frame(maxWidth: .infinity)
        .onTapGesture {
          let quoteTweetViewModel: QuoteTweetsViewModel = .init(userID: userID, source: tweetID)
          path.append(quoteTweetViewModel)
        }

      Label("\(metrics.likeCount)", systemImage: "heart")
        .frame(maxWidth: .infinity)
        .onTapGesture {
          let likeUsersViewModel: LikeUsersViewModel = .init(userID: userID, tweetID: tweetID)
          path.append(likeUsersViewModel)
        }
    }
  }
}
