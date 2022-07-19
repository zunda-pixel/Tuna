//
//  TweetDetailView.swift
//  Tuna
//
//  Created by zunda on 2022/06/05.
//

import SwiftUI

final class TweetDetailViewModel<CellViewModel: TweetCellViewProtocol>: ObservableObject, Hashable {
  static func == (lhs: TweetDetailViewModel, rhs: TweetDetailViewModel) -> Bool {
    lhs.cellViewModel == rhs.cellViewModel
  }

  func hash(into hasher: inout Hasher) {
    cellViewModel.hash(into: &hasher)
  }

  let cellViewModel: CellViewModel

  let parentTweetViewModel: CellViewModel?

  init(cellViewModel: CellViewModel, parentTweetViewModel: CellViewModel? = nil) {
    self.cellViewModel = cellViewModel
    self.parentTweetViewModel = parentTweetViewModel
  }
}

struct TweetDetailView<ViewModel: TweetDetailViewModel<TweetCellViewModel>>: View {
  @StateObject var viewModel: ViewModel
  @Binding var path: NavigationPath

  var body: some View {
    VStack {
      if let parentTweetCellViewModel = viewModel.parentTweetViewModel {
        VStack {
          TweetCellView(path: $path, viewModel: parentTweetCellViewModel)
          TweetToolBar(userID: parentTweetCellViewModel.userID, tweet: parentTweetCellViewModel.tweet, user: parentTweetCellViewModel.author)
          TweetDetailInformation(userID: parentTweetCellViewModel.userID, tweetID: parentTweetCellViewModel.tweet.id, metrics: parentTweetCellViewModel.tweet.publicMetrics!, path: $path)
        }
      }

      VStack {
        TweetCellView(path: $path, viewModel: viewModel.cellViewModel)
        TweetToolBar(userID: viewModel.cellViewModel.userID, tweet: viewModel.cellViewModel.tweet, user: viewModel.cellViewModel.author)
          .padding(.bottom)
        HStack {
          Text(viewModel.cellViewModel.tweet.createdAt!, format: .dateTime)
          Text("via \(viewModel.cellViewModel.tweet.source!)")
        }
        .padding(.bottom)
        TweetDetailInformation(userID: viewModel.cellViewModel.userID, tweetID: viewModel.cellViewModel.tweet.id, metrics: viewModel.cellViewModel.tweet.publicMetrics!, path: $path)
          .padding(.bottom)
      }

      let repliesTweetsViewModel: RepliesTweetsViewModel = .init(userID: viewModel.cellViewModel.userID, conversationID: viewModel.cellViewModel.tweet.conversationID!)

      TweetsView(viewModel: repliesTweetsViewModel, path: $path)

      Spacer()
    }
  }
}


