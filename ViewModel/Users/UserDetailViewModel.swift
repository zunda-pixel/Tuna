import Foundation
import Sweet

final class UserDetailViewModel: ObservableObject, Hashable {
  static func == (lhs: UserDetailViewModel, rhs: UserDetailViewModel) -> Bool {
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
