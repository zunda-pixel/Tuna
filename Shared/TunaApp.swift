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

  var body: some Scene {
    WindowGroup {
      Group {
        if let userID = userID {
          TabView {
            NavigationStack {
              let tweetViewModel: ReverseChronologicalViewModel = .init(userID: userID, viewContext: persistenceController.container.viewContext)
              TweetsView(viewModel: tweetViewModel)
                .toolbar {
                  ToolbarItem(placement: .navigationBarLeading) {
                    SelectUserMenu(userID: $userID)
                      .environment(\.managedObjectContext, persistenceController.container.viewContext)
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
              let viewModel = NewTweetViewModel()
              NewTweetView(isPresentedDismiss: $isPresentedCreateTweetView, viewModel: viewModel)
            }
            .tabItem {
              Image(systemName: "house")
            }
            ListsView(userID: userID)
              .environment(\.managedObjectContext, persistenceController.container.viewContext)
              .tabItem {
                Image(systemName: "list.dash.header.rectangle")
              }
            let tweetsViewModel: SearchTweetsViewModel = .init(userID: userID, viewContext: persistenceController.container.viewContext)
            let usersViewModel: SearchUsersViewModel = .init()
            let searchViewModel: SearchViewModel = .init(tweetsViewModel: tweetsViewModel, usersViewModel: usersViewModel)
            SearchView(viewModel: searchViewModel)
              .environment(\.managedObjectContext, persistenceController.container.viewContext)
              .tabItem {
                Image(systemName: "doc.text.magnifyingglass")
              }
            let bookmarksViewModel: BookmarksViewModel = .init(userID: userID, viewContext: persistenceController.container.viewContext)
            TweetsView(viewModel: bookmarksViewModel)
              .tabItem {
                Image(systemName: "book.closed")
              }
            let likesViewModel:LikesViewModel = .init(userID: userID, viewContext: persistenceController.container.viewContext)
            TweetsView(viewModel: likesViewModel)
              .tabItem {
                Image(systemName: "heart")
              }
          }
        } else {
          LoginView(userID: $userID)
            .tabItem {
              Image(systemName: "person")
            }
        }
      }
    }
  }
}
