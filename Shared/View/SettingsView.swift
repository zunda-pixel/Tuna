//
//  SettingsView.swift
//  Tuna
//
//  Created by zunda on 2022/05/22.
//

import SwiftUI
import Sweet

struct SettingsView: View {
  @State var path = NavigationPath()

  let userID: String

  var body: some View {
    NavigationStack(path: $path) {
      List {
        Section("General") {
          let mutingUsersView: MutingUsersViewModel = .init(userID: userID)
          NavigationLink(value: mutingUsersView) {
            Label("Muting", systemImage: "speaker.slash")
          }

          let blockingUsersView: BlockingUsersViewModel = .init(userID: userID)

          NavigationLink(value: blockingUsersView) {
            Label("Blocking", systemImage: "xmark.shield")
          }

          NavigationLink {
            Text("Hello")
          } label: {
            HStack {
              Image(systemName: "iphone")
              Text("表示")
            }
          }
          NavigationLink {
            Text("Hello")
          } label: {
            HStack {
              Image(systemName: "iphone.radiowaves.left.and.right")
              Text("Behaviors")
            }
          }
          NavigationLink {
            Text("Hello")
          } label: {
            HStack {
              Image(systemName: "speaker")
                .symbolVariant(.circle)
              Text("Sound")
            }
          }
          NavigationLink {
            Text("Hello")
          } label: {
            HStack {
              Image(systemName: "safari")
              Text("Browser")
            }
          }
          NavigationLink {
            Text("Hello")
          } label: {
            HStack {
              Image(systemName: "rectangle.grid.2x2")
              Text("App Icon")
            }
          }
        }

        Section("ABOUT") {
          NavigationLink {
            Text("Hello")
          } label: {
            HStack {
              Image(systemName: "person")
              Text("Mange Subscription")
            }
          }
          NavigationLink {
            Text("Hello")
          } label: {
            HStack {
              Image(systemName: "person")
              Text("Sync Status")
            }
          }
          NavigationLink {
            Text("Hello")
          } label: {
            HStack {
              Image(systemName: "person")
              Text("Support")
            }
          }
          NavigationLink {
            Text("Hello")
          } label: {
            HStack {
              Image(systemName: "person")
              Text("zunda")
            }
          }
        }
      }
      .navigationDestination(for: MutingUsersViewModel.self) { viewModel in
        UsersView(viewModel: viewModel, path: $path)
          .navigationTitle("Mute")
          .navigationBarTitleDisplayMode(.inline)
      }
      .navigationDestination(for: BlockingUsersViewModel.self) { viewModel in
        UsersView(viewModel: viewModel, path: $path)
          .navigationTitle("Mute")
          .navigationBarTitleDisplayMode(.inline)
      }
      .navigationDestination(for: UserViewModel.self) { viewModel in
        UserView(viewModel: viewModel, path: $path)
          .navigationTitle("@\(viewModel.user.userName)")
          .navigationBarTitleDisplayMode(.inline)
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
    }
  }
}
