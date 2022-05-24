//
//  UserView.swift
//  Tuna
//
//  Created by zunda on 2022/05/21.
//

import SwiftUI
import Sweet
import UniformTypeIdentifiers

enum TweetTab: String, CaseIterable, Identifiable {
  var id: String {
    return rawValue
  }

  case tweet = "Tweet"
  case like = "Like"
}

struct UserView: View {
  let user: Sweet.UserModel
  @State var selection: TweetTab = .tweet
  @Environment(\.managedObjectContext) private var viewContext

  var body: some View {
    GeometryReader { geometry in
      //ScrollView {
        VStack {
          let size = geometry.size.width / 3
          ProfileImageView(user.profileImageURL)
            .frame(width: size, height: size)

          // TODO UserToolMenuを表示するとエラーになってしまう
          // UserToolMenu(fromUserID: Secret.currentUserID!, toUserID: user.id)

          UserProfileView(user: user)

          if let metrics = user.metrics {
            HStack(alignment: .center) {
              NavigationLink {
                Text("Hello")
              } label: {
                VStack {
                  Text("FOLLOWERS")
                  Text("\(metrics.followersCount)")
                }
              }
              NavigationLink {
                Text("Hello")
              } label: {
                VStack {
                  Text("FOLLOWING")
                  Text("\(metrics.followingCount)")
                }
              }
            }
          }

          Picker("User Tab", selection: $selection) {
            ForEach(TweetTab.allCases) { tab in
              Text(tab.rawValue)
                .tag(tab)
            }
          }
          .pickerStyle(.segmented)

          TabView(selection: $selection) {
            UserTweetsView(userID: user.id)
              .environment(\.managedObjectContext, viewContext)
              .tag(TweetTab.tweet)
            Text("Like")
              .tag(TweetTab.like)
          }
          .tabViewStyle(.page(indexDisplayMode: .never))
        }
     // }
    }
  }
}

struct UserView_Previews: PreviewProvider {
  static var previews: some View {
    UserView(user: .init(id: "", name: "zunda" ,userName: "zunda_pixel", profileImageURL:  .init(string: "https://pbs.twimg.com/profile_images/974322170309390336/tY8HZIhk_400x400.jpg"),  description: "hello from america", url: .init(string: "https://twitter.com"),createdAt: Date(), location: "ここはどこ", metrics: .init(followersCount: 111, followingCount: 222, tweetCount: 222, listedCount: 33)))
  }
}
