//
//  UserView.swift
//  Tuna
//
//  Created by zunda on 2022/05/21.
//

import SwiftUI
import Sweet

enum TweetTab: String, CaseIterable, Identifiable {
  var id: String {
    return rawValue
  }

  case tweet = "Tweet"
  case mention = "Mention"
  case like = "Like"
}

struct UserView: View {
  let userID: String
  let user: Sweet.UserModel
  @State var selection: TweetTab = .tweet
  @Environment(\.managedObjectContext) private var viewContext

  var body: some View {
    VStack {
      ProfileImageView(user.profileImageURL)
        .frame(width: 100, height: 100)

      UserToolMenu(fromUserID: userID, toUserID: user.id)

      UserProfileView(user: user)

      if let metrics = user.metrics {
        HStack(alignment: .center) {
          NavigationLink {
            let followerUserViewModel: FollowerUserViewModel = .init(userID: userID, ownerID: user.id)
            UsersView(viewModel: followerUserViewModel)
              .navigationTitle("@\(user.userName)")
              .navigationBarTitleDisplayMode(.inline)
          } label: {
            VStack {
              Text("FOLLOWERS")
              Text("\(metrics.followersCount)")
            }
          }
          NavigationLink {
            let followingUserViewModel: FollowingUserViewModel = .init(userID: userID, ownerID: user.id)
            UsersView(viewModel: followingUserViewModel)
              .navigationTitle("@\(user.userName)")
              .navigationBarTitleDisplayMode(.inline)
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
        let userTimelineViewModel: UserTimelineViewModel = .init(userID: userID, ownerID: user.id)
        TweetsView(viewModel: userTimelineViewModel)
          .tag(TweetTab.tweet)

        let userMentionsViewModel: UserMentionsViewModel = .init(userID: userID, ownerID: user.id)
        TweetsView(viewModel: userMentionsViewModel)
          .tag(TweetTab.mention)

        let likeViewModel: LikesViewModel = .init(userID: userID, ownerID: user.id)
        TweetsView(viewModel: likeViewModel)
          .tag(TweetTab.like)
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
    }
  }
}

struct UserView_Previews: PreviewProvider {
  static var previews: some View {
    let user: Sweet.UserModel = .init(id: "", name: "zunda", userName: "zunda_pixel",
                                      profileImageURL:  .init(string: "https://pbs.twimg.com/profile_images/974322170309390336/tY8HZIhk.jpg"),
                                      description: "hello from america",
                                      url: .init(string: "https://twitter.com"),
                                      createdAt: Date(), location: "ここはどこ",
                                      metrics: .init(followersCount: 111, followingCount: 222, tweetCount: 222, listedCount: 33))
    UserView(userID: "", user: user)
  }
}
