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

  @State var userID: String?
  @State var isPresentedCreateTweetView = false

  var body: some Scene {
    WindowGroup {
      Group {
        if let userID = userID {
          TabView {
            NavigationView {
              let tweetViewModel: ReverseChronologicalViewModel = .init(userID: userID, viewContext: persistenceController.container.viewContext)
              TweetsView(viewModel: tweetViewModel)
                .navigationTitle("Timeline")
                .navigationBarTitleDisplayMode(.inline)
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
            .navigationViewStyle(.stack)
            .sheet(isPresented: $isPresentedCreateTweetView) {
              let viewModel = NewTweetViewModel()
              NewTweetView(isPresentedDismiss: $isPresentedCreateTweetView, viewModel: viewModel)
            }
            .tabItem {
              Image(systemName: "house")
            }
            ListsView(userID: userID)
              .environment(\.managedObjectContext, persistenceController.container.viewContext)
              .navigationBarTitleDisplayMode(.inline)
              .navigationViewStyle(.stack)
              .navigationTitle("List")
              .tabItem {
                Image(systemName: "list.dash.header.rectangle")
              }
            let tweetsViewModel: SearchTweetsViewModel = .init(userID: userID, viewContext: persistenceController.container.viewContext)
            let searchViewModel: SearchViewModel = .init(tweetsViewModel: tweetsViewModel)
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
      .onAppear {
        self.userID = Secret.currentUserID
      }
    }
  }
}
