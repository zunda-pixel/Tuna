import SwiftUI

struct LikeNavigationView: View {
  @Environment(\.managedObjectContext) var viewContext
  
  @State var path = NavigationPath()
  let userID: String

  var body: some View {
    NavigationStack(path: $path) {
      let likesViewModel:LikesViewModel = .init(userID: userID, ownerID: userID)
      TweetsView(viewModel: likesViewModel, path: $path)
        .navigationTitle("Likes")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: UserViewModel.self) { viewModel in
          UserView(viewModel: viewModel, path: $path, timelineViewModel: .init(userID: userID, ownerID: viewModel.user.id))
            .navigationTitle("@\(viewModel.user.userName)")
            .navigationBarTitleDisplayMode(.inline)
            .environment(\.managedObjectContext, viewContext)
        }
        .navigationDestination(for: FollowingUserViewModel.self) { viewModel in
          UsersView(viewModel: viewModel, path: $path)
            .navigationTitle("Following")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationDestination(for: FollowerUserViewModel.self) { viewModel in
          UsersView(viewModel: viewModel, path: $path)
            .navigationTitle("Follower")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationDestination(for: TweetDetailViewModel<TweetCellViewModel>.self) { viewModel in
          TweetDetailView(viewModel: viewModel, path: $path)
            .navigationTitle("Detail")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationDestination(for: QuoteTweetsViewModel.self) { viewModel in
          TweetsView(viewModel: viewModel, path: $path)
            .navigationTitle("Quote Tweet")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationDestination(for: UserMentionsViewModel.self) { viewModel in
          TweetsView(viewModel: viewModel, path: $path)
            .navigationTitle("Mention")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationDestination(for: LikesViewModel.self) { viewModel in
          TweetsView(viewModel: viewModel, path: $path)
            .navigationTitle("Like")
            .navigationBarTitleDisplayMode(.inline)
        }

    }
  }
}

struct LikeNavigationView_Previews: PreviewProvider {
  static var previews: some View {
    LikeNavigationView(userID: "")
  }
}
