//
//  TweetToolBar.swift
//  Tuna
//
//  Created by zunda on 2022/05/23.
//

import SwiftUI

struct TweetToolBar: View {
  let userID: String
  let tweetID: String
  let tweet: String

  var body: some View {
    HStack {
      RetweetButton(viewModel: .init(user: userID, tweet: tweetID))
      Spacer()
      LikeButton(viewModel: .init(user: userID, tweet: tweetID))
      Spacer()
      BookmarkButton(viewModel: .init(user: userID, tweet: tweetID))
      Spacer()
      ShareButton(userID: userID, tweetID: tweetID, tweet: tweet)
    }
  }
}

struct TweetToolBar_Previews: PreviewProvider {
  static var previews: some View {
    TweetToolBar(userID: "", tweetID: "", tweet: "")
  }
}
