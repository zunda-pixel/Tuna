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
          UserView(viewModel: viewModel, path: $path)
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
        .navigationDestination(for: TweetCellViewModel.self) { tweetCellViewModel in
          TweetDetailView(tweetCellViewModel: tweetCellViewModel, path: $path)
            .navigationTitle("Detail")
        }
    }
  }
}

struct LikeNavigationView_Previews: PreviewProvider {
  static var previews: some View {
    LikeNavigationView(userID: "")
  }
}
