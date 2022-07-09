//


import SwiftUI

struct BookmarksNavigationView: View {
  @State var path = NavigationPath()
  @Environment(\.managedObjectContext) var viewContext
  
  let userID: String

  var body: some View {
    NavigationStack(path: $path) {
      let bookmarksViewModel: BookmarksViewModel = .init(userID: userID)

      TweetsView(viewModel: bookmarksViewModel, path: $path)
        .navigationTitle("Book")
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
            .navigationBarTitleDisplayMode(.inline)
        }
    }
  }
}

struct BookmarksNavigationView_Previews: PreviewProvider {
  static var previews: some View {
    BookmarksNavigationView(userID: "")
  }
}
