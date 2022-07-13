import SwiftUI

struct SpaceDetail: View {
  @StateObject var viewModel: SpaceDetailViewModel

  @Binding var path: NavigationPath

  var body: some View {
    VStack(alignment: .center) {
      Text(viewModel.space.title!)
        .font(.title)

      ProfileImageView(viewModel.creator.profileImageURL)
        .frame(width: 100, height: 100)
        .onTapGesture {
          let userViewModel: UserViewModel = .init(userID: viewModel.userID, user: viewModel.creator)
          path.append(userViewModel)
        }

      ScrollView(.horizontal) {
        HStack {
          ForEach(viewModel.speakers) { speaker in
            ProfileImageView(speaker.profileImageURL)
              .frame(width: 60, height: 60)
              .padding(.vertical)
              .onTapGesture {
                let userViewModel: UserViewModel = .init(userID: viewModel.userID, user: speaker)
                path.append(userViewModel)
              }
          }
        }
        .padding(.horizontal, 50)
      }

      let url: URL = .init(string: "https://twitter.com/i/spaces/\(viewModel.space.id)")!
      Link("Open Space", destination: url)
        .padding()

      let spaceTweetsViewModel: SpaceTweetsViewModel = .init(userID: viewModel.userID, spaceID: viewModel.space.id)

      TweetsView(viewModel: spaceTweetsViewModel, path: $path)

      Spacer()
    }
  }
}
