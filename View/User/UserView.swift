//
//  UserView.swift
//  Tuna
//
//  Created by zunda on 2022/05/21.
//

import SwiftUI
import Sweet

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

  init(userID: String, user: Sweet.UserModel) {
    self.userID = userID
    self.user = user
  }
}

struct UserView: View {
  @StateObject var viewModel: UserViewModel

  @Binding var path: NavigationPath

  @Environment(\.managedObjectContext) private var viewContext

  @StateObject var timelineViewModel: UserTimelineViewModel

  var body: some View {
    ScrollView {
      VStack {
        ProfileImageView(viewModel.user.profileImageURL)
          .frame(width: 100, height: 100)

        UserProfileView(user:viewModel.user)

        HStack(alignment: .center) {
          Button {
            let viewModel: FollowerUserViewModel = .init(userID: viewModel.userID, ownerID: viewModel.user.id)
            path.append(viewModel)
          } label: {
            VStack {
              Label("FOLLOWERS", systemImage: "figure.wave")
              Text("\(viewModel.user.metrics!.followersCount)")
            }
          }

          Button {
            let viewModel: FollowingUserViewModel = .init(userID: viewModel.userID, ownerID: viewModel.user.id)
            path.append(viewModel)
          } label: {
            VStack {
              Label("FOLLOWING", systemImage: "figure.walk")
              Text("\(viewModel.user.metrics!.followingCount)")
            }
          }
        }

        Button {
          let viewModel: UserMentionsViewModel = .init(userID: viewModel.userID, ownerID: viewModel.user.id)
          path.append(viewModel)
        } label: {
          Label("Mention", systemImage: "ellipsis.message")
        }
        .padding()

        Button {
          let viewModel: LikesViewModel = .init(userID: viewModel.userID, ownerID: viewModel.user.id)
          path.append(viewModel)
        } label: {
          Label("Like", systemImage: "heart")
        }
        .padding()

        TweetsView(viewModel: timelineViewModel, path: $path)
      }
    }
    .refreshable {
      await timelineViewModel.fetchTweets(first: nil, last: nil)
    }
    .onAppear {
      Task {
        await timelineViewModel.fetchTweets(first: nil, last: nil)
      }
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
