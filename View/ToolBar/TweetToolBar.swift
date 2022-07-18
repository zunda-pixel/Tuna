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

  @State var isPresentedRetweetQuotedAlert = false
  var body: some View {
    HStack(alignment: .lastTextBaseline) {
      Button {
        isPresentedRetweetQuotedAlert.toggle()
      } label: {
        Text("\(Image(systemName: "arrow.2.squarepath")) \(metrics.retweetCount + metrics.quoteCount)")
      }
      .buttonStyle(.borderless)
      .padding(.horizontal)

      LikeButton(viewModel: .init(user: userID, tweet: tweetID, likeCount: metrics.likeCount))
        .buttonStyle(.borderless)
        .padding(.horizontal)

      BookmarkButton(viewModel: .init(user: userID, tweet: tweetID))
        .buttonStyle(.borderless)
        .padding(.horizontal)

      TweetMenu(userID: userID, tweetID: tweetID)
        .menuStyle(.borderlessButton)
        .padding(.horizontal)
    }
    .confirmationDialog("Retweet Tweet Or Quoted Tweet", isPresented: $isPresentedRetweetQuotedAlert) {
      RetweetButton(viewModel: .init(user: userID, tweet: tweetID, retweetCount: metrics.retweetCount))
      QuotedButton(userID: userID)
    }
    .font(.system(size: 17))
  }
}

struct TweetToolBar_Previews: PreviewProvider {
  static var previews: some View {
    TweetToolBar(userID: "", tweetID: "", tweet: "", metrics: .init(retweetCount: 1, replyCount: 3, likeCount: 4, quoteCount: 4))
  }
}
