//
//  SelectUserView.swift
//  Tuna
//
//  Created by zunda on 2022/04/13.
//

import SwiftUI

struct SelectUserMenu: View {
  @Environment(\.managedObjectContext) var context
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
          Secret.currentUserID = user.id
          selectedUserID = user.id
        } label: {
          ProfileImageView(user.profileImageURL)
            .frame(width: 30, height: 30)
          VStack(alignment: .leading) {
            Text(user.name!)
            Text(user.userName!)
          }
        }
      }

      Button {
        isPresentedSettingView.toggle()
      } label: {
        Label("Setting", systemImage: "gear")
      }

    } label: {
      let user = users.first { $0.id == Secret.currentUserID }
      ProfileImageView(user?.profileImageURL)
        .frame(width: 30, height: 30)
    }
    .onAppear {
      users.nsPredicate = .init(format: "id IN %@", Secret.loginUserIDs)
    }
    
    .sheet(isPresented: $isPresentedSettingView) {
      SettingsView(userID: $selectedUserID)
    }
  }
}
