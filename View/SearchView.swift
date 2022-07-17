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

  var body: some View {
    NavigationStack(path: $path) {
      List {
        Section {
          HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search Twitter", text: $viewModel.tweetsViewModel.searchText)
              .onChange(of: viewModel.tweetsViewModel.searchText) { newValue in
                viewModel.usersViewModel.searchText = newValue
              }
          }
        }

        if !viewModel.tweetsViewModel.searchText.isEmpty {
          Section {
            NavigationLink(value: viewModel.tweetsViewModel) {
              Label("Tweets with \"\(viewModel.tweetsViewModel.searchText)\"", systemImage: "bubble.left")
            }

            NavigationLink(value: viewModel.usersViewModel) {
              Label("Users with \"\(viewModel.usersViewModel.searchText)\"", systemImage: "person")
            }
          }
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
      .navigationDestination(for: TweetDetailViewModel.self) { viewModel in
        TweetDetailView(viewModel: viewModel, path: $path)
          .navigationTitle("Detail")
          .navigationBarTitleDisplayMode(.inline)
      }
      .navigationDestination(for: SearchTweetsViewModel.self) { viewModel in
        TweetsView(viewModel: viewModel, path: $path)
          .navigationTitle(viewModel.searchText)
          .navigationBarTitleDisplayMode(.inline)
      }
      .navigationDestination(for: SearchUsersViewModel.self) { viewModel in
        UsersView(viewModel: viewModel, path: $path)
          .navigationTitle(viewModel.searchText)
          .navigationBarTitleDisplayMode(.inline)
      }
    }
  }
}
