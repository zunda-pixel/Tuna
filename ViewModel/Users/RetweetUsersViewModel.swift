import Foundation
import Sweet

final class RetweetUsersViewModel: UsersViewProtocol, Hashable {
  static func == (lhs: RetweetUsersViewModel, rhs: RetweetUsersViewModel) -> Bool {
    lhs.userID == lhs.userID && lhs.tweetID == rhs.tweetID
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
  let tweetID: String

  init(userID: String, tweetID: String) {
    self.userID = userID
    self.tweetID = tweetID
  }

  func fetchUsers(reset resetData: Bool) async {
    do {
      let response = try await Sweet(userID: userID).fetchRetweetUsers(tweetID: tweetID, paginationToken: paginationToken)

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
