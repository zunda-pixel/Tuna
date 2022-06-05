//
//  QuotedTweetCellView.swift
//  Tuna
//
//  Created by zunda on 2022/04/15.
//

import SwiftUI
import Sweet

struct QuotedTweetCellView: View {
  let tweet: Sweet.TweetModel
  let user: Sweet.UserModel

  var body: some View {
    HStack(alignment: .top) {
      ProfileImageView(user.profileImageURL)
        .frame(width: 30, height: 30)
      VStack(alignment: .leading) {
        if let userName = user.userName {
          (Text(user.name) + Text(" @\(userName)").foregroundColor(.gray))
            .lineLimit(1)
        }

        Text(tweet.text)
          .lineLimit(nil)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
  }
}
