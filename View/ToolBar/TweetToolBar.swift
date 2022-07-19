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

  let tweet: Sweet.TweetModel
  let user: Sweet.UserModel

  @State var isPresentedRetweetQuotedAlert = false
  @State var isPresentedNewTweetView = false

  var body: some View {
    HStack {
      Text("\(Image(systemName: "arrow.2.squarepath")) \(tweet.publicMetrics!.retweetCount + tweet.publicMetrics!.quoteCount)")
        .frame(maxWidth: .infinity)
        .onTapGesture {
          isPresentedRetweetQuotedAlert.toggle()
        }
        .confirmationDialog("Retweet Tweet Or Quoted Tweet", isPresented: $isPresentedRetweetQuotedAlert) {
          RetweetButton(viewModel: .init(user: userID, tweet: tweet.id, retweetCount: tweet.publicMetrics!.retweetCount))
          QuotedButton(isPresentedNewTweetView: $isPresentedNewTweetView, userID: userID)
        }

      LikeButton(viewModel: .init(user: userID, tweet: tweet.id, likeCount: tweet.publicMetrics!.likeCount))
        .frame(maxWidth: .infinity)

      BookmarkButton(viewModel: .init(user: userID, tweet: tweet.id))
        .frame(maxWidth: .infinity)
    }

    .sheet(isPresented: $isPresentedNewTweetView) {
      let viewModel: NewTweetViewModel = .init(userID: userID, quoted: (tweet, user))
      NewTweetView(viewModel: viewModel)
    }
    .font(.system(size: 17))
  }
}
