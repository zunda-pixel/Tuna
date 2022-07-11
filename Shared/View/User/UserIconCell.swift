import SwiftUI
import Sweet


struct UserIconCell: View {
  let user: Sweet.UserModel
  var body: some View {
    VStack {
      ProfileImageView(user.profileImageURL)
        .frame(width: 50, height: 50)
      Text(user.name)
      Text("@\(user.userName)")
        .lineLimit(1)
    }
  }
}

struct UserIconCell_Previews: PreviewProvider {
  static var previews: some View {
    UserIconCell(user: .init(id: "123", name: "name", userName: "userName"))
  }
}

struct SearchUsersView: View {
  @StateObject var viewModel: SearchUsersViewModel

  var body: some View {
    ScrollView(.horizontal) {
      ForEach(viewModel.users) { user in
        UserIconCell(user: user)
          .padding()
      }
    }
  }
}
