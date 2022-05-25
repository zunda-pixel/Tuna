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
        VStack {
          TweetCellView(viewModel: cellViewModel)
            .environment(\.managedObjectContext, viewModel.viewContext)
            .onTapGesture {
              viewModel.latestTapTweetID = cellViewModel.tweet.id
              viewModel.isPresentedTweetToolbar.toggle()
            }
          if let latestTapTweetID = viewModel.latestTapTweetID, latestTapTweetID == cellViewModel.tweet.id, viewModel.isPresentedTweetToolbar {
            TweetToolBar(userID: cellViewModel.authorUser.id, tweetID: cellViewModel.tweet.id)
          }
        }
        .onAppear {
          guard let lastTweet = viewModel.showTweets.last else{
            return
          }

          if tweet.id == lastTweet.id {
            Task {
              await fetchTweets(first: nil, last: tweet.id)
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
      let firstTweetID = viewModel.timelines.first
      await fetchTweets(first: firstTweetID, last: nil)
    }
    .onAppear {
      let firstTweetID = viewModel.timelines.first
      Task {
        await fetchTweets(first: firstTweetID, last: nil)
      }
    }
  }
}
