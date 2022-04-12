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
  let userID: String?

  @State var isPresentedCreateTweetView = false
  @State var isPresented = false
  @State var providers: [NSItemProvider] = []

  init() {
    self.userID = UserDefaults().string(forKey: "currentUserID")
  }

  var body: some Scene {
    WindowGroup {
      TabView {
        NavigationView {
          TweetsView()
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
        ListsView()
          .tabItem {
            Image(systemName: "list.dash.header.rectangle")
          }

        LoginView()
          .onOpenURL { url in
            Task {
              do {
                try await DeepLink.doSomething(url)
              } catch {
                print(error)
              }
            }
          }
          .tabItem {
            Image(systemName: "person")
          }
        Text("hello")
          .tabItem {
            Image(systemName: "arrowshape.zigzag.forward")
          }
      }

    }
  }
}
