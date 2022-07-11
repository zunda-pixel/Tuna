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
                Image(systemName: "house")
              }

            ListsView(userID: userID)
              .environment(\.managedObjectContext, persistenceController.container.viewContext)
              .tabItem {
                Image(systemName: "list.dash.header.rectangle")
              }

            SearchView(userID: userID)
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
