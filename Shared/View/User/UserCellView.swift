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
  }
}

struct UserCellView_Preview: PreviewProvider {
  static var previews: some View {
    UserCellView(ownerID: "", user: .init(id: "133213", name: "zunda", userName: "zunda_dev", verified: true, profileImageURL: .init(string: "https://pbs.twimg.com/profile_images/974322170309390336/tY8HZIhk.jpg")! ,description: "f;ajsd;lfjkasd;lfkj"))
  }
}
