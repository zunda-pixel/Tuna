//
//  SearchView.swift
//  Tuna
//
//  Created by zunda on 2022/04/18.
//

import SwiftUI
import Sweet

struct SearchView<ViewModel: SearchViewProtocol>: View {
  @StateObject var viewModel: ViewModel
  @State var path = NavigationPath()
  @Environment(\.managedObjectContext) var viewContext

  enum Pages: String, CaseIterable, Identifiable {
    case user = "User"
    case tweet = "Tweet"

    var id: String { self.rawValue }
  }

  @State var selection: Pages = .tweet

  var body: some View {
    NavigationStack {
      VStack {
        Picker("Menu", selection: $selection) {
          ForEach(Pages.allCases) { page in
            Text(page.rawValue)
              .tag(page)
          }
        }
        .pickerStyle(.segmented)

        TabView(selection: $selection) {
          TweetsView(viewModel: viewModel.tweetsViewModel, path: $path)
            .tag(Pages.tweet)

          UsersView(viewModel: viewModel.usersViewModel, path: $path)
            .tag(Pages.user)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
      }
      .searchable(text: $viewModel.tweetsViewModel.searchText, prompt: Text("Search Keyword"))
      .onSubmit(of: .search) {
        Task {
          let firstTweetID = viewModel.tweetsViewModel.showTweets.first?.id
          await viewModel.tweetsViewModel.fetchTweets(first: firstTweetID, last: nil)
        }

        Task {
          viewModel.usersViewModel.searchText = viewModel.tweetsViewModel.searchText
          await viewModel.usersViewModel.fetchUsers(reset: true)
        }
      }
      .navigationTitle("Search")
      .navigationBarTitleDisplayMode(.large)
      .navigationDestination(for: UserViewModel.self) { viewModel in
        UserView(viewModel: viewModel, path: $path)
          .navigationTitle("@\(viewModel.user.userName)")
          .navigationBarTitleDisplayMode(.inline)
          .environment(\.managedObjectContext, viewContext)
      }
      .navigationDestination(for: FollowingUserViewModel.self) { viewModel in
        UsersView(viewModel: viewModel, path: $path)
          .navigationTitle("Following")
          .navigationBarTitleDisplayMode(.inline)
      }
      .navigationDestination(for: FollowerUserViewModel.self) { viewModel in
        UsersView(viewModel: viewModel, path: $path)
          .navigationTitle("Follower")
          .navigationBarTitleDisplayMode(.inline)
      }
      .navigationDestination(for: TweetCellViewModel.self) { tweetCellViewModel in
        TweetDetailView(tweetCellViewModel: tweetCellViewModel, path: $path)
          .navigationTitle("Detail")
      }
    }
  }
}
