//
//  TunaApp.swift
//  Shared
//
//  Created by zunda on 2022/03/21.
//

import Sweet
import SwiftUI

@main
struct TunaApp: App {
  let persistenceController = PersistenceController.shared

  @State var reverseChronologicalPath = NavigationPath()

  @State var userID: String? = Secret.currentUserID
  @State var isPresentedCreateTweetView = false
  @State var isPresentedSettingsView = false

  var body: some Scene {
    WindowGroup {
      Group {
        if let userID = userID {
          TabView {
            NavigationStack(path: $reverseChronologicalPath) {
              let tweetViewModel: ReverseChronologicalViewModel = .init(userID: userID, viewContext: persistenceController.container.viewContext)
              ReverseChronologicalTweetsView(path: $reverseChronologicalPath, viewModel: tweetViewModel)
                .navigationTitle("Timeline")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: TweetCellViewModel.self) { tweetCellViewModel in
                  TweetDetailView(tweetCellViewModel: tweetCellViewModel, path: $reverseChronologicalPath)
                    .navigationTitle("Detail")
                }
                .navigationDestination(for: UserViewModel.self) { viewModel in
                  UserView(viewModel: viewModel, path: $reverseChronologicalPath)
                    .navigationTitle("@\(viewModel.user.userName)")
                    .navigationBarTitleDisplayMode(.inline)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }
                .navigationDestination(for: FollowingUserViewModel.self) { viewModel in
                  UsersView(viewModel: viewModel, path: $reverseChronologicalPath)
                    .navigationTitle("Following")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .navigationDestination(for: FollowerUserViewModel.self) { viewModel in
                  UsersView(viewModel: viewModel, path: $reverseChronologicalPath)
                    .navigationTitle("Follower")
                    .navigationBarTitleDisplayMode(.inline)
                }

                .toolbar {
                  ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                      isPresentedSettingsView.toggle()
                    } label: {
                      Image(systemName: "gear")
                    }
                    .sheet(isPresented: $isPresentedSettingsView) {
                      SettingsView()
                    }
                  }
                  ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                      isPresentedCreateTweetView.toggle()
                    }) {
                      Image(systemName: "plus.message")
                    }
                  }
                }
            }
            .sheet(isPresented: $isPresentedCreateTweetView) {
              let viewModel = NewTweetViewModel(userID: userID)
              NewTweetView(viewModel: viewModel)
            }
            .tabItem {
              Image(systemName: "house")
            }

            ListsView(userID: userID)
              .navigationTitle("List")
              .navigationBarTitleDisplayMode(.large)
              .environment(\.managedObjectContext, persistenceController.container.viewContext)
              .tabItem {
                Image(systemName: "list.dash.header.rectangle")
              }

            let searchViewModel: SearchViewModel = .init(userID: userID)

            SearchView(viewModel: searchViewModel)
              .navigationTitle("Search")
              .navigationBarTitleDisplayMode(.large)
              .environment(\.managedObjectContext, persistenceController.container.viewContext)
              .tabItem {
                Image(systemName: "doc.text.magnifyingglass")
              }

            BookmarksNavigationView(userID: userID)
              .environment(\.managedObjectContext, persistenceController.container.viewContext)
              .tabItem {
                Image(systemName: "book.closed")
              }

            LikeNavigationView(userID: userID)
              .environment(\.managedObjectContext, persistenceController.container.viewContext)
              .tabItem {
                Image(systemName: "heart")
              }
          }
        } else {
          LoginView(userID: $userID) {
            Text("Login")
          }
          .environment(\.managedObjectContext, persistenceController.container.viewContext)
          .tabItem {
            Image(systemName: "person")
          }
        }
      }
    }
  }
}
