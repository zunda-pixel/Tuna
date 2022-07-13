//
//  TweetsView.swift
//  Tuna
//
//  Created by zunda on 2022/03/21.
//

import Sweet
import SwiftUI

struct TweetsView<ViewModel: TweetsViewProtocol>: View {
  @StateObject var viewModel: ViewModel
  @Binding var path: NavigationPath

  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async {
    if viewModel.loadingTweets {
      return
    }

    viewModel.loadingTweets = true

    defer {
      viewModel.loadingTweets = false
    }

    await viewModel.fetchTweets(first: firstTweetID, last: lastTweetID)
  }

  var body: some View {
    VStack(alignment: .center) {
      if !viewModel.loadingTweets && viewModel.showTweets.isEmpty {
        Image(systemName: "info.square")
        Text("No Tweets Found.")
      } else {
        List {
          ForEach(viewModel.showTweets) { tweet in
            let cellViewModel = viewModel.getTweetCellViewModel(tweet.id)

            let isTappedTweet: Bool = {
              if let latestTapTweetID = viewModel.latestTapTweetID {
                let sameTweetID = latestTapTweetID == cellViewModel.tweet.id
                return viewModel.isPresentedTweetToolbar && sameTweetID
              } else {
                return false
              }
            }()

            VStack {
              TweetCellView(path: $path, viewModel: cellViewModel)
                .onTapGesture {
                  viewModel.isPresentedTweetToolbar = viewModel.latestTapTweetID != cellViewModel.tweet.id || !viewModel.isPresentedTweetToolbar
                  viewModel.latestTapTweetID = cellViewModel.tweet.id
                }
              if isTappedTweet {
                TweetToolBar(userID: viewModel.userID, tweetID: cellViewModel.tweet.id, tweet: cellViewModel.tweetText, metrics: cellViewModel.tweet.publicMetrics!)
              }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
              Button {
                let tweetDetailViewModel: TweetDetailViewModel = .init(cellViewModel: cellViewModel)
                path.append(tweetDetailViewModel)
              } label: {
                Image(systemName: "ellipsis")
              }
            }
            .onAppear {
              guard let lastTweet = viewModel.showTweets.last else {
                return
              }

              if tweet.id == lastTweet.id {
                Task {
                  await fetchTweets(first: nil, last: lastTweet.id)
                }
              }
            }
          }
        }
        if viewModel.loadingTweets {
          ProgressView()
        }
      }
    }

    .alert("Error", isPresented: $viewModel.didError) {
      Button {
        print(viewModel.error!)
      } label: {
        Text("Close")
      }
    }
    .listStyle(.plain)
    .refreshable {
      let firstTweetID = viewModel.showTweets.first?.id
      await fetchTweets(first: firstTweetID, last: nil)
    }
    .onAppear {
      Task {
        guard viewModel.showTweets.isEmpty else { return }
        let firstTweetID = viewModel.showTweets.first?.id
        await fetchTweets(first: firstTweetID, last: nil)
      }
    }
  }
}
