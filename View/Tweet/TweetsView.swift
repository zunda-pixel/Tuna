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

  var body: some View {
    VStack {
      if viewModel.showTweets.isEmpty {
        Image(systemName: "info.square")
        Text("No Tweets Found.")
      } else {
        ScrollView {
          LazyVStack {
            Divider()
            ForEach(viewModel.showTweets) { tweet in
              let cellViewModel = viewModel.getTweetCellViewModel(tweet.id)

              VStack {
                TweetCellView(path: $path, viewModel: cellViewModel)
                TweetToolBar(userID: viewModel.userID, tweetID: cellViewModel.tweet.id, tweet: cellViewModel.tweetText, metrics: cellViewModel.tweet.publicMetrics!)

                Divider()
              }
              .contentShape(Rectangle())
              .onTapGesture {
                let parentTweetCellViewModel: TweetCellViewModel? = {
                  if let reply = cellViewModel.tweet.referencedTweets.first(where: { $0.type == .repliedTo}) {
                    return viewModel.getTweetCellViewModel(reply.id)
                  } else {
                    return nil
                  }
                }()

                let tweetDetailViewModel: TweetDetailViewModel = .init(cellViewModel: cellViewModel, parentTweetViewModel: parentTweetCellViewModel)
                path.append(tweetDetailViewModel)
              }

              .onAppear {
                guard let lastTweet = viewModel.showTweets.last else { return }

                guard tweet.id == lastTweet.id else { return }

                Task {
                  await viewModel.fetchTweets(first: nil, last: lastTweet.id)
                }
              }
            }
          }
          .anyRefreshable {
            let firstTweetID = viewModel.showTweets.first?.id
            await viewModel.fetchTweets(first: firstTweetID, last: nil)
          }
        }
        .alert("Error", isPresented: $viewModel.didError) {
          Button {
            print(viewModel.error!)
          } label: {
            Text("Close")
          }
        }
      }
    }
    .onAppear {
      Task {
        guard viewModel.showTweets.isEmpty else { return }
        let firstTweetID = viewModel.showTweets.first?.id
        await viewModel.fetchTweets(first: firstTweetID, last: nil)
      }
    }
  }
}
