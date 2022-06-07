//
//  SettingsView.swift
//  Tuna
//
//  Created by zunda on 2022/05/22.
//

import SwiftUI
import Sweet

struct SettingsView: View {
  @Binding var selectedUserID: String?
  @FetchRequest private var users: FetchedResults<User>

  init(userID: Binding<String?>) {
    self._selectedUserID = userID

    self._users = FetchRequest(
      entity: User.entity(),
      sortDescriptors: [],
      predicate: .init(format: "id IN %@", Secret.loginUserIDs)
    )
  }

  func removeUserID(_ userID: String) {
    if userID == Secret.currentUserID {
      let userID = Secret.loginUserIDs.first { userID != $0 }
      Secret.currentUserID = userID
      selectedUserID = userID
    }

    Secret.removeLoginUser(userID)
  }

  var body: some View {
    NavigationStack {
      List {
        Section("ACCOUNT") {
          ForEach(users) { user in
            let userModel: Sweet.UserModel = .init(user: user)

            NavigationLink {
              AccountSettingView(user: userModel)
            } label: {
              HStack {
                ProfileImageView(userModel.profileImageURL)
                  .frame(width: 30, height: 30)
                Text(userModel.userName)
                Spacer()
              }
            }
            .swipeActions(edge: .trailing) {
              Button(role: .destructive) {
                removeUserID(userModel.id)
              } label: {
                Text("Delete")
              }
            }
          }

          LoginView(userID: $selectedUserID)
        }

        Section("General") {
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
    }
  }
}

struct SettingView_Previews: PreviewProvider {
  @State static var userID: String? = ""
  static var previews: some View {
    SettingsView(userID: $userID)
  }
}
