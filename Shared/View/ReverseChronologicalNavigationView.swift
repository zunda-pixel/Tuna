import SwiftUI

struct ReverseChronologicalNavigationView: View {
  @Environment(\.managedObjectContext) var viewContext
  let userID: String
  @State var path = NavigationPath()
  @State var isPresentedCreateTweetView = false
  @State var isPresentedSettingsView = false

  var body: some View {
    NavigationStack(path: $path) {
      let tweetViewModel: ReverseChronologicalViewModel = .init(userID: userID, viewContext: viewContext)
      ReverseChronologicalTweetsView(path: $path, viewModel: tweetViewModel)
        .navigationTitle("Timeline")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: TweetCellViewModel.self) { viewModel in
          TweetDetailView(viewModel: viewModel, path: $path)
            .navigationTitle("Detail")
            .navigationBarTitleDisplayMode(.inline)
        }
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
        .navigationDestination(for: QuoteTweetsViewModel.self) { viewModel in
          TweetsView(viewModel: viewModel, path: $path)
            .navigationTitle("Quote Tweet")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationDestination(for: LikeUsersViewModel.self) { viewModel in
          UsersView(viewModel: viewModel, path: $path)
            .navigationTitle("Like")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationDestination(for: RetweetUsersViewModel.self) { viewModel in
          UsersView(viewModel: viewModel, path: $path)
            .navigationTitle("Retweet")
            .navigationBarTitleDisplayMode(.inline)
        }

        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button {
              isPresentedSettingsView.toggle()
            } label: {
              Image(systemName: "gear")
            }
            .sheet(isPresented: $isPresentedSettingsView) {
              SettingsView(userID: userID)
            }
          }
          ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
              isPresentedCreateTweetView.toggle()
            }) {
              Image(systemName: "plus.message")
            }
          }
        }
    }
    .sheet(isPresented: $isPresentedCreateTweetView) {
      let viewModel = NewTweetViewModel(userID: userID)
      NewTweetView(viewModel: viewModel)
    }
  }
}
