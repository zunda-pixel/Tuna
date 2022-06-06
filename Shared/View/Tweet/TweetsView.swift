//
//  TweetsView.swift
//  Tuna
//
//  Created by zunda on 2022/03/21.
//

import CoreData
import Sweet
import SwiftUI

struct TweetsView<ViewModel: TweetsViewProtocol>: View {
  @StateObject var viewModel: ViewModel

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
    List {
      ForEach(viewModel.showTweets) { tweet in
        let cellViewModel = viewModel.getTweetCellViewModel(tweet.id!)

        let isTappedTweet: Bool = {
          if let latestTapTweetID = viewModel.latestTapTweetID {
            let sameTweetID = latestTapTweetID == cellViewModel.tweet.id
            return viewModel.isPresentedTweetToolbar && sameTweetID
          } else {
            return false
          }
        }()

        VStack {
          TweetCellView(viewModel: cellViewModel)
            .onTapGesture {
              viewModel.isPresentedTweetToolbar = viewModel.latestTapTweetID != cellViewModel.tweet.id || !viewModel.isPresentedTweetToolbar
              viewModel.latestTapTweetID = cellViewModel.tweet.id
            }
          if isTappedTweet {
            TweetToolBar(userID: viewModel.userID, tweetID: cellViewModel.tweet.id, tweet: cellViewModel.tweetText, metrics: cellViewModel.tweet.publicMetrics!)
              .padding(.horizontal, 50)
          }

          NavigationLink(isActive: $viewModel.isPresentedTweetDetail) {
            TweetDetailView(tweetCellViewModel: cellViewModel)
          } label: {
            EmptyView()
          }
          .frame(width: 0, height: 0)
          .hidden()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
          Button {
            viewModel.isPresentedTweetDetail.toggle()
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

      Button {
        Task {
          await fetchTweets(first: nil, last: viewModel.showTweets.last?.id)
        }
      } label: {
        Text("more Loading")
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
      let firstTweetID = viewModel.showTweets.first?.id
      Task {
        await fetchTweets(first: firstTweetID, last: nil)
      }
    }
  }
}
