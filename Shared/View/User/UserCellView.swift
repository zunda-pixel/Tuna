//
//  UserCellView.swift
//  Tuna
//
//  Created by zunda on 2022/04/25.
//

import SwiftUI
import Sweet

struct UserCellView: View {
  let ownerID: String
  let user: Sweet.UserModel

  @Binding var path: NavigationPath

  var body: some View {
    HStack(alignment: .top) {
      ProfileImageView(user.profileImageURL)
        .frame(width: 60, height: 60)
      VStack(alignment: .leading) {
        HStack(alignment: .center) {
          VStack(alignment: .leading) {
            HStack {
              Text(user.userName)
              if let verified = user.verified, verified {
                Image(systemName: "checkmark.seal")
                  .symbolVariant(.fill)
              }
            }

            Text("@\(user.name)")
              .foregroundColor(.gray)
          }
          Spacer()

          if ownerID != user.id {
            Button {
              print("Follow")
            } label: {
              Text("Follow")
                .padding(.horizontal, 10)
            }
            .clipShape(Capsule())
            .buttonStyle(.bordered)
          }
        }
        if let description = user.description {
          Text(description)
        }
      }
    }
    .contentShape(Rectangle())
    .onTapGesture {
      let userViewModel: UserViewModel = .init(userID: ownerID, user: user)
      path.append(userViewModel)
    }
  }
}
