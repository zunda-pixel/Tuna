//
//  SelectUserView.swift
//  Tuna
//
//  Created by zunda on 2022/04/13.
//

import SwiftUI

struct SelectUserView: View {
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

  var body: some View {
    VStack {
      ForEach(users) { user in
        HStack {
          ProfileImageView(user.profileImageURL)
            .frame(width: 30, height: 30)
          VStack(alignment: .leading) {
            Text(user.name ?? "")
            Text(user.userName ?? "")
          }
          Image(systemName: user.id == selectedUserID ? "checkmark.circle.fill" : "circle")
        }
        .onTapGesture {
          selectedUserID = user.id
        }
      }

      LoginView()
    }
    .background(.red)
  }
}

struct SelectUserView_Previews: PreviewProvider {
  @State static var userID = ""
  static var previews: some View {
    SelectUserView(userID: .init(get: {userID}, set: {userID = $0!}))
  }
}
