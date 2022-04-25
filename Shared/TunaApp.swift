//
//  TunaApp.swift
//  Shared
//
//  Created by zunda on 2022/03/21.
//

import KeychainAccess
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
              TweetsView(userID: userID)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .navigationTitle("Timeline")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                  ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {

                    }) {
                      Image(systemName: "person")
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
            SearchView()
              .tabItem {
                Image(systemName: "magnifyingglass")
              }
            SelectUserView(userID: .init(get: { userID }, set: { self.userID = $0 }))
              .environment(\.managedObjectContext, persistenceController.container.viewContext)
              .tabItem{
                Image(systemName: "house")
              }
          }
        } else {
          LoginView()
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
