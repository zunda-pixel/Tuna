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
  @State var isPresented = false
  @State var providers: [NSItemProvider] = []

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
              .navigationBarTitleDisplayMode(.inline)
              .navigationViewStyle(.stack)
              .navigationTitle("List")
              .tabItem {
                Image(systemName: "list.dash.header.rectangle")
              }
          }
        } else {
          LoginView()
            .onOpenURL { url in
              Task {
                do {
                  try await DeepLink.doSomething(url)
                  self.userID = Secret.currentUserID
                } catch {
                  print(error)
                }
              }
            }
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
