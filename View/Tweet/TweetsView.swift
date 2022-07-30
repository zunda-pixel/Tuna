//
//  TweetsView.swift
//  Tuna
//
//  Created by zunda on 2022/03/21.
//

import Sweet
import SwiftUI

struct TweetsView<ViewModel: TweetsViewProtocol>: View {
  @ObservedObject var viewModel: ViewModel
  @Binding var path: NavigationPath

  var body: some View {
    VStack {
      if viewModel.showTweets.isEmpty {
        Image(systemName: "info.square")
        Text("No Tweets Found.")
      } else {
        ScrollView {
          LazyVStack {
            ForEach(viewModel.showTweets) { tweet in
              let cellViewModel = viewModel.getTweetCellViewModel(tweet.id)

              VStack {
                TweetCellView(path: $path, viewModel: cellViewModel)
                TweetToolBar(userID: viewModel.userID, tweet: cellViewModel.tweet, user: cellViewModel.author)
              }
              .contentShape(Rectangle())
              .contextMenu {
                let url: URL = .init(string: "https://twitter.com/\(cellViewModel.author.id)/status/\(cellViewModel.tweet.id)")!
                ShareLink(item: url) {
                  Label("Share", systemImage: "square.and.arrow.up")
                }
              }
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
        }
        .refreshable {
          let firstTweetID = viewModel.showTweets.first?.id
          await viewModel.fetchTweets(first: firstTweetID, last: nil)
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
