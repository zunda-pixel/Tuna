//
//  SelectUserView.swift
//  Tuna
//
//  Created by zunda on 2022/04/13.
//

import SwiftUI

struct SelectUserMenu: View {
  @Binding var selectedUserID: String?
  @FetchRequest private var users: FetchedResults<User>
  @State var isPresentedSettingView = false

  init(userID: Binding<String?>) {
    self._selectedUserID = userID

    self._users = FetchRequest(
      entity: User.entity(),
      sortDescriptors: [],
      predicate: .init(format: "id IN %@", Secret.loginUserIDs)
    )
  }

  var body: some View {
    Menu {
      ForEach(users) { user in
        Button {
          selectedUserID = user.id
        } label: {
          Label {
            VStack(alignment: .leading) {
              Text(user.name ?? "")
              Text(user.userName ?? "")
            }
          } icon: {
            ProfileImageView(user.profileImageURL)
              .frame(width: 30, height: 30)
          }
        }
      }

      Button {
        print("Button clicked")
        isPresentedSettingView.toggle()
      } label: {
        Label("Setting", systemImage: "gear")
      }

    } label: {
      Image(systemName: "person")
    }
    
    .sheet(isPresented: $isPresentedSettingView) {
      SettingsView(userID: $selectedUserID)
    }
  }
}