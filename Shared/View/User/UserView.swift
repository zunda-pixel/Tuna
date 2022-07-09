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
  @Binding var path: NavigationPath

  @Environment(\.managedObjectContext) private var viewContext

  var body: some View {
    VStack {
      ProfileImageView(user.profileImageURL)
        .frame(width: 100, height: 100)

      UserToolMenu(fromUserID: userID, toUserID: user.id)

      UserProfileView(user: user)

      if let metrics = user.metrics {
        HStack(alignment: .center) {
          let followerUserViewModel: FollowerUserViewModel = .init(userID: userID, ownerID: user.id)

          NavigationLink(value: followerUserViewModel) {
            VStack {
              Text("FOLLOWERS")
              Text("\(metrics.followersCount)")
            }
          }

          let followingUserViewModel: FollowingUserViewModel = .init(userID: userID, ownerID: user.id)
          NavigationLink(value: followingUserViewModel) {
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
        TweetsView(viewModel: userTimelineViewModel, path: $path)
          .tag(TweetTab.tweet)

        let userMentionsViewModel: UserMentionsViewModel = .init(userID: userID, ownerID: user.id)
        TweetsView(viewModel: userMentionsViewModel, path: $path)
          .tag(TweetTab.mention)

        let likeViewModel: LikesViewModel = .init(userID: userID, ownerID: user.id)
        TweetsView(viewModel: likeViewModel, path: $path)
          .tag(TweetTab.like)
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
    }
  }
}
