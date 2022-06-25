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

  @State var userID: String? = Secret.currentUserID
  @State var isPresentedCreateTweetView = false
  @State var isPresentedSettingsView = false

  var body: some Scene {
    WindowGroup {
      Group {
        if let userID = userID {
          TabView {
            NavigationStack {
              let tweetViewModel: ReverseChronologicalViewModel = .init(userID: userID, viewContext: persistenceController.container.viewContext)
              TweetsView(viewModel: tweetViewModel)
                .navigationTitle("Timeline")
                .navigationBarTitleDisplayMode(.inline)
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
            NavigationStack {
              ListsView(userID: userID)
                .navigationTitle("List")
                .navigationBarTitleDisplayMode(.large)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
            .tabItem {
              Image(systemName: "list.dash.header.rectangle")
            }

            NavigationStack {
              let tweetsViewModel: SearchTweetsViewModel = .init(userID: userID, viewContext: persistenceController.container.viewContext)
              let usersViewModel: SearchUsersViewModel = .init(userID: userID)
              let searchViewModel: SearchViewModel = .init(tweetsViewModel: tweetsViewModel, usersViewModel: usersViewModel)

              SearchView(viewModel: searchViewModel)
                .navigationTitle("Search")
                .navigationBarTitleDisplayMode(.large)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
              .tabItem {
                Image(systemName: "doc.text.magnifyingglass")
              }

            NavigationStack {
              let bookmarksViewModel: BookmarksViewModel = .init(userID: userID, viewContext: persistenceController.container.viewContext)

              TweetsView(viewModel: bookmarksViewModel)
                .navigationTitle("Book")
                .navigationBarTitleDisplayMode(.large)
            }
              .tabItem {
                Image(systemName: "book.closed")
              }
            NavigationStack {
              let likesViewModel:LikesViewModel = .init(userID: userID, viewContext: persistenceController.container.viewContext)
              TweetsView(viewModel: likesViewModel)
                .navigationTitle("Likes")
                .navigationBarTitleDisplayMode(.large)
            }
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
