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

final class UserViewModel: ObservableObject, Hashable {
  static func == (lhs: UserViewModel, rhs: UserViewModel) -> Bool {
    lhs.userID == rhs.userID && lhs.user == rhs.user
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(user)
  }

  let userID: String
  let user: Sweet.UserModel
  @Published var selection: TweetTab = .tweet

  init(userID: String, user: Sweet.UserModel) {
    self.userID = userID
    self.user = user
  }
}

struct UserView: View {
  @StateObject var viewModel: UserViewModel

  @Binding var path: NavigationPath

  @Environment(\.managedObjectContext) private var viewContext

  var body: some View {
    VStack {
      ProfileImageView(viewModel.user.profileImageURL)
        .frame(width: 100, height: 100)

      UserProfileView(user:viewModel.user)

      if let metrics = viewModel.user.metrics {
        HStack(alignment: .center) {
          let followerUserViewModel: FollowerUserViewModel = .init(userID: viewModel.userID, ownerID: viewModel.user.id)

          NavigationLink(value: followerUserViewModel) {
            VStack {
              Text("FOLLOWERS")
              Text("\(metrics.followersCount)")
            }
          }

          let followingUserViewModel: FollowingUserViewModel = .init(userID: viewModel.userID, ownerID: viewModel.user.id)
          NavigationLink(value: followingUserViewModel) {
            VStack {
              Text("FOLLOWING")
              Text("\(metrics.followingCount)")
            }
          }
        }
      }

      Picker("User Tab", selection: $viewModel.selection) {
        ForEach(TweetTab.allCases) { tab in
          Text(tab.rawValue)
            .tag(tab)
        }
      }
      .pickerStyle(.segmented)

      TabView(selection: $viewModel.selection) {
        let userTimelineViewModel: UserTimelineViewModel = .init(userID: viewModel.userID, ownerID: viewModel.user.id)
        TweetsView(viewModel: userTimelineViewModel, path: $path)
          .tag(TweetTab.tweet)

        let userMentionsViewModel: UserMentionsViewModel = .init(userID: viewModel.userID, ownerID: viewModel.user.id)
        TweetsView(viewModel: userMentionsViewModel, path: $path)
          .tag(TweetTab.mention)

        let likeViewModel: LikesViewModel = .init(userID: viewModel.userID, ownerID: viewModel.user.id)
        TweetsView(viewModel: likeViewModel, path: $path)
          .tag(TweetTab.like)
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
    }
    .toolbar {
      if viewModel.userID != viewModel.user.id {
        ToolbarItem(placement: .navigationBarTrailing) {
          UserToolMenu(fromUserID: viewModel.userID, toUserID: viewModel.user.id)
        }
      }
    }
  }
}
