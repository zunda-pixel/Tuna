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

  var body: some Scene {
    WindowGroup {
      Group {
        if let userID = userID {
          TabView {
            ReverseChronologicalNavigationView(userID: userID)
              .environment(\.managedObjectContext, persistenceController.container.viewContext)
              .tabItem {
                Label("Timeline", systemImage: "house")
                  .labelStyle(.iconOnly)
              }

            ListsView(userID: userID)
              .environment(\.managedObjectContext, persistenceController.container.viewContext)
              .tabItem {
                Label("List", systemImage: "list.dash.header.rectangle")
                  .labelStyle(.iconOnly)
              }

            let searchViewModel: SearchViewModel = .init(userID: userID)

            SearchView(viewModel: searchViewModel)
              .environment(\.managedObjectContext, persistenceController.container.viewContext)
              .tabItem {
                Label("Search Tweet User", systemImage: "doc.text.magnifyingglass")
                  .labelStyle(.iconOnly)
              }

            SearchSpacesView(userID: userID)
              .tabItem {
                Label("Search Space", systemImage: "airplane")
                  .labelStyle(.iconOnly)
              }

            BookmarksNavigationView(userID: userID)
              .environment(\.managedObjectContext, persistenceController.container.viewContext)
              .tabItem {
                Label("Bookmark", systemImage: "book.closed")
                  .labelStyle(.iconOnly)
              }

            LikeNavigationView(userID: userID)
              .environment(\.managedObjectContext, persistenceController.container.viewContext)
              .tabItem {
                Label("Like", systemImage: "heart")
                  .labelStyle(.iconOnly)
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
