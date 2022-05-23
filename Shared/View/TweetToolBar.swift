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

  var body: some View {
    HStack {
      Text("TweetToolBar")
      //RetweetButton(viewModel: .init(user: userID, tweet: tweetID))
      //LikeButton(viewModel: .init(user: userID, tweet: tweetID))
      //BookmarkButton(viewModel: .init(user: userID, tweet: tweetID))
    }
  }
}

struct TweetToolBar_Previews: PreviewProvider {
  static var previews: some View {
    TweetToolBar(userID: "", tweetID: "")
  }
}
