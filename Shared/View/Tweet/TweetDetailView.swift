//
//  TweetDetailView.swift
//  Tuna
//
//  Created by zunda on 2022/06/05.
//

import SwiftUI

struct TweetDetailView<Tweet: TweetCellViewProtocol>: View {
  @StateObject var viewModel: Tweet
  @Binding var path: NavigationPath

  var body: some View {
    VStack {
      TweetCellView(path: $path, viewModel: viewModel)
      TweetToolBar(userID: viewModel.userID, tweetID: viewModel.tweet.id,
                   tweet: viewModel.tweet.text, metrics: viewModel.tweet.publicMetrics!)
      TweetDetailInformation(userID: viewModel.userID, tweetID: viewModel.tweet.id, metrics: viewModel.tweet.publicMetrics!)
      Spacer()
    }
  }
}
