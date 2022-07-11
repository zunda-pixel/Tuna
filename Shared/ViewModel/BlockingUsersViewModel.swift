import Foundation
import Sweet

final class BlockingUsersViewModel: UsersViewProtocol {
  static func == (lhs: BlockingUsersViewModel, rhs: BlockingUsersViewModel) -> Bool {
    lhs.userID == lhs.userID
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(paginationToken)
    hasher.combine(userID)
    hasher.combine(users)
  }

  var paginationToken: String?
  var error: Error?

  @Published var didError = false
  @Published var users: [Sweet.UserModel] = []

  let userID: String

  init(userID: String) {
    self.userID = userID
  }

  func fetchUsers(reset resetData: Bool) async {
    do {
      let response = try await Sweet(userID: userID).fetchBlocking(userID: userID, paginationToken: paginationToken)

      if resetData {
        users = []
      }

      response.users.forEach { newUser in
        if let firstIndex = users.firstIndex(where: { $0.id == newUser.id }) {
          users[firstIndex] = newUser
        } else {
          users.append(newUser)
        }
      }

      paginationToken = response.meta?.nextToken
    } catch let newError {
      self.error = newError
      self.didError.toggle()
    }
  }
}
