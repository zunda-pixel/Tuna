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
        .navigationDestination(for: UserDetailViewModel.self) { viewModel in
          UserDetailView(viewModel: viewModel, path: $path, timelineViewModel: .init(userID: userID, ownerID: viewModel.user.id))
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
    }
  }
}

struct BookmarksNavigationView_Previews: PreviewProvider {
  static var previews: some View {
    BookmarksNavigationView(userID: "")
  }
}
