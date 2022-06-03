//
//  TweetToolBar.swift
//  Tuna
//
//  Created by zunda on 2022/05/23.
//

import SwiftUI
import Sweet

struct TweetToolBar: View {
  let userID: String
  let tweetID: String
  let tweet: String

  let metrics: Sweet.TweetPublicMetrics

  var body: some View {
    HStack {
      RetweetButton(viewModel: .init(user: userID, tweet: tweetID))
        .border(.red)
      Text("\(metrics.retweetCount)")
      LikeButton(viewModel: .init(user: userID, tweet: tweetID))
        .border(.red)
      Text("\(metrics.likeCount)")
      BookmarkButton(viewModel: .init(user: userID, tweet: tweetID))
        .border(.red)
      ShareButton(userID: userID, tweetID: tweetID, tweet: tweet)
        .border(.red)
    }
  }
}

struct TweetToolBar_Previews: PreviewProvider {
  static var previews: some View {
    TweetToolBar(userID: "", tweetID: "", tweet: "", metrics: .init(retweetCount: 1, replyCount: 3, likeCount: 4, quoteCount: 4))
  }
}
