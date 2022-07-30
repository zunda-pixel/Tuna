import Sweet
import SwiftUI

struct ReverseChronologicalTweetsView<ViewModel: ReverseChronologicalTweetsViewProtocol>: View {
  @Binding var path: NavigationPath
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
    ScrollView {
      LazyVStack {
        ForEach(viewModel.showTweets) { tweet in
          let cellViewModel = viewModel.getTweetCellViewModel(tweet.id!)

          VStack {
            TweetCellView(path: $path, viewModel: cellViewModel)
            TweetToolBar(userID: viewModel.userID, tweet: cellViewModel.tweet, user: cellViewModel.author)
          }
          .contentShape(Rectangle())
          .onTapGesture {
            let tweetDetailViewModel: TweetDetailViewModel = .init(cellViewModel: cellViewModel)
            path.append(tweetDetailViewModel)
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
    }
    .alert("Error", isPresented: $viewModel.didError) {
      Button {
        print(viewModel.error!)
      } label: {
        Text("Close")
      }
    }
    .refreshable {
      let firstTweetID = viewModel.showTweets.first?.id
      await fetchTweets(first: firstTweetID, last: nil)
    }
    .onAppear {
      Task {
        let firstTweetID = viewModel.showTweets.first?.id
        await fetchTweets(first: firstTweetID, last: nil)
      }
    }
  }
}
