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
  case media = "Media"
  case like = "Like"
}

struct UserView: View {
  let user: Sweet.UserModel
  @State var selection: TweetTab = .tweet
  @Environment(\.managedObjectContext) private var viewContext

  var body: some View {
    GeometryReader { geometry in
      VStack {
        ProfileImageView(user.profileImageURL)
          .frame(width: geometry.size.width / 2, height: geometry.size.width / 2)

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
          Text("Tweet")
            .tabItem {
              Text("Tweet")
            }
            .tag(TweetTab.tweet)
          Text("Media")
            .tabItem {
              Text("Media")
            }
            .tag(TweetTab.media)
          Text("Like")
            .tabItem {
              Text("Like")
            }
            .tag(TweetTab.like)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
      }
    }
  }
}

struct UserView_Previews: PreviewProvider {
  static var previews: some View {
    UserView(user: .init(id: "", name: "zunda" ,userName: "zunda_pixel", profileImageURL:  .init(string: "https://pbs.twimg.com/profile_images/974322170309390336/tY8HZIhk_400x400.jpg"),  description: "hello from america", url: .init(string: "https://twitter.com"),createdAt: Date(), location: "ここはどこ", metrics: .init(followersCount: 111, followingCount: 222, tweetCount: 222, listedCount: 33)))
  }
}
