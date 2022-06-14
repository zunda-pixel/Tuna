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
    HStack(alignment: .lastTextBaseline) {
      RetweetButton(viewModel: .init(user: userID, tweet: tweetID, retweetCount: metrics.retweetCount))
        .buttonStyle(.borderless)
        .padding(.horizontal)
      LikeButton(viewModel: .init(user: userID, tweet: tweetID, likeCount: metrics.likeCount))
        .buttonStyle(.borderless)
        .padding(.horizontal)
      BookmarkButton(viewModel: .init(user: userID, tweet: tweetID))
        .buttonStyle(.borderless)
        .padding(.horizontal)

      let url: URL = .init(string: "https://twitter.com/\(userID)/status/\(tweetID)")!
      ShareLink(item: url) {
        Image(systemName: "square.and.arrow.up")
          .foregroundColor(.gray)
      }
      .presentationDetents([.medium, .large])
      .padding(.horizontal)
    }
    .font(.system(size: 17))
  }
}

struct TweetToolBar_Previews: PreviewProvider {
  static var previews: some View {
    TweetToolBar(userID: "", tweetID: "", tweet: "", metrics: .init(retweetCount: 1, replyCount: 3, likeCount: 4, quoteCount: 4))
  }
}
