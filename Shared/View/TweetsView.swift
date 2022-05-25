//
//  TweetsView.swift
//  Tuna
//
//  Created by zunda on 2022/03/21.
//

import CoreData
import Sweet
import SwiftUI

extension Sweet.TwitterError: LocalizedError {

}

struct TweetsView<ViewModel: TweetsViewProtocol>: View {
  @StateObject var viewModel: ViewModel

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
              await viewModel.fetchTweets(first: nil, last: tweet.id, paginationToken: nil)
            }
          }
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
      let firstTweetID = viewModel.timelines.first?.tweetID
      await viewModel.fetchTweets(first: firstTweetID, last: nil, paginationToken: nil)
    }
    .onAppear {
      let firstTweetID = viewModel.timelines.first?.tweetID
      Task {
        await viewModel.fetchTweets(first: firstTweetID, last: nil, paginationToken: nil)
      }
    }
  }
}
