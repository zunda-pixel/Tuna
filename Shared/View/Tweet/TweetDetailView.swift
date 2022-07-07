//
//  TweetDetailView.swift
//  Tuna
//
//  Created by zunda on 2022/06/05.
//

import SwiftUI

struct TweetDetailView<Tweet: TweetCellViewProtocol>: View {
  @StateObject var tweetCellViewModel: Tweet
  var body: some View {
    VStack {
      TweetCellView(viewModel: tweetCellViewModel)
      TweetToolBar(userID: tweetCellViewModel.userID, tweetID: tweetCellViewModel.tweet.id,
                   tweet: tweetCellViewModel.tweet.text, metrics: tweetCellViewModel.tweet.publicMetrics!)
      Spacer()
    }
  }
}
