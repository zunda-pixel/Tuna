//
//  UserProfileView.swift
//  Tuna
//
//  Created by zunda on 2022/05/23.
//

import SwiftUI
import Sweet

struct UserProfileView: View {
  let user: Sweet.UserModel

  var body: some View {
    Text(user.name)
      .font(.title)

    Text("@\(user.userName)")
      .foregroundColor(.gray)

    if let description = user.description {
      Text(description)
    }

    if let url = user.url {
      HStack {
        Image(systemName: "link")

        let urlModel = user.entity?.urls.first { $0.url == url}

        Link(urlModel!.displayURL, destination: url)
      }
    }

    if let createdAt = user.createdAt {
      HStack {
        Image(systemName: "calendar")

        let formatter: DateFormatter = {
          let formatter: DateFormatter = .init()
          formatter.dateFormat = "yyyy年M月"
          return formatter
        }()

        Text(formatter.string(from: createdAt) + "からTwitterを利用しています")
      }
    }

    if let location = user.location {
      HStack {
        Image(systemName: "location")
        Text(location)
      }
    }
  }
}

struct UserProfileView_Previews: PreviewProvider {
  static var previews: some View {
    UserProfileView(user: .init(id: "", name: "", userName: ""))
  }
}
