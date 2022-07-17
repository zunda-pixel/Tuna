//
//  TweetDetailView.swift
//  Tuna
//
//  Created by zunda on 2022/06/05.
//

import SwiftUI

final class TweetDetailViewModel: ObservableObject, Hashable {
  static func == (lhs: TweetDetailViewModel, rhs: TweetDetailViewModel) -> Bool {
    lhs.cellViewModel == rhs.cellViewModel
  }

  func hash(into hasher: inout Hasher) {
    cellViewModel.hash(into: &hasher)
  }

  let cellViewModel: TweetCellViewModel

  let parentTweetViewModel: TweetCellViewModel?

  init(cellViewModel: TweetCellViewModel, parentTweetViewModel: TweetCellViewModel? = nil) {
    self.cellViewModel = cellViewModel
    self.parentTweetViewModel = parentTweetViewModel
  }
}

struct TweetDetailView<ViewModel: TweetDetailViewModel>: View {
  @StateObject var viewModel: ViewModel
  @Binding var path: NavigationPath

  var body: some View {
    VStack {
      if let parentTweetCellViewModel = viewModel.parentTweetViewModel {
        VStack {
          TweetCellView(path: $path, viewModel: parentTweetCellViewModel)
          TweetToolBar(userID: parentTweetCellViewModel.userID, tweetID: parentTweetCellViewModel.tweet.id,
                       tweet: viewModel.cellViewModel.tweet.text, metrics: parentTweetCellViewModel.tweet.publicMetrics!)
          TweetDetailInformation(userID: parentTweetCellViewModel.userID, tweetID: parentTweetCellViewModel.tweet.id, metrics: parentTweetCellViewModel.tweet.publicMetrics!, path: $path)
        }
      }

      VStack {
        TweetCellView(path: $path, viewModel: viewModel.cellViewModel)
        TweetToolBar(userID: viewModel.cellViewModel.userID, tweetID: viewModel.cellViewModel.tweet.id,
                     tweet: viewModel.cellViewModel.tweet.text, metrics: viewModel.cellViewModel.tweet.publicMetrics!)
        TweetDetailInformation(userID: viewModel.cellViewModel.userID, tweetID: viewModel.cellViewModel.tweet.id, metrics: viewModel.cellViewModel.tweet.publicMetrics!, path: $path)
      }

      let repliesTweetsViewModel: RepliesTweetsViewModel = .init(userID: viewModel.cellViewModel.userID, conversationID: viewModel.cellViewModel.tweet.conversationID!)

      TweetsView(viewModel: repliesTweetsViewModel, path: $path)

      Spacer()
    }
  }
}


