//
//  UserCellView.swift
//  Tuna
//
//  Created by zunda on 2022/04/25.
//

import SwiftUI
import Sweet

struct UserCellView: View {
  let user: Sweet.UserModel

  var body: some View {
    HStack {
      ProfileImageView(user.profileImageURL)
        .frame(width: 30, height: 30)
      VStack(alignment: .leading) {
        HStack {
          VStack {
            HStack {
              Text(user.userName)
              if let verified = user.verified, verified {
                Image(systemName: "checkmark.seal")
                  .symbolVariant(.fill)
              }
            }

            Text("@\(user.name)")
          }
          Spacer()
          Button {
          } label: {
            Text("Follow")
          }
        }
        if let description = user.description {
          Text(description)
        }
      }
    }
  }
}
