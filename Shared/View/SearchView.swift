//
//  SearchView.swift
//  Tuna
//
//  Created by zunda on 2022/04/18.
//

import SwiftUI
import Sweet

struct SearchView: View {
  @State var path = NavigationPath()
  @State var searchText: String = ""
  @Environment(\.managedObjectContext) var viewContext
  @StateObject var searchUsersViewModel: SearchUsersViewModel
  @StateObject var searchTweetsViewModel: SearchTweetsViewModel

  init(userID: String) {
    self._searchTweetsViewModel = .init(wrappedValue: .init(userID: userID))
    self._searchUsersViewModel = .init(wrappedValue: .init(userID: userID))
  }

  var body: some View {
    NavigationStack(path: $path) {
      List {
        HStack {
          Image(systemName: "magnifyingglass")
          TextField("Search Keyword", text: $searchText)
            .onSubmit(of: .text) {
              Task {
                searchUsersViewModel.searchText = searchText
                await searchUsersViewModel.fetchUsers()
              }
              Task {
                searchTweetsViewModel.searchText = searchText
                await searchTweetsViewModel.fetchTweets(first: nil, last: nil)
              }
            }
        }

        if !searchUsersViewModel.users.isEmpty {
          SearchUsersView(viewModel: searchUsersViewModel)
        }
        if !searchTweetsViewModel.showTweets.isEmpty {
          TweetsView(viewModel: searchTweetsViewModel, path: $path)
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
      .navigationDestination(for: TweetCellViewModel.self) { viewModel in
        TweetDetailView(viewModel: viewModel, path: $path)
          .navigationTitle("Detail")
          .navigationBarTitleDisplayMode(.inline)
      }
    }
  }
}
