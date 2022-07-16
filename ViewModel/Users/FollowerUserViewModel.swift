//
//  FollowerUserViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/06/05.
//

import Foundation
import Sweet

final class FollowerUserViewModel: UsersViewProtocol, Hashable {
  static func == (lhs: FollowerUserViewModel, rhs: FollowerUserViewModel) -> Bool {
    lhs.userID == rhs.userID && lhs.ownerID == rhs.ownerID
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(ownerID)
    hasher.combine(paginationToken)
    hasher.combine(users)
  }
  
  let userID: String
  let ownerID: String

  var paginationToken: String?
  var error: Error?

  @Published var didError = false
  @Published var users: [Sweet.UserModel] = []

  init(userID: String, ownerID: String) {
    self.userID = userID
    self.ownerID = ownerID
  }

  func fetchUsers(reset resetData: Bool) async {
    do {
      let response = try await Sweet(userID: userID).fetchFollower(userID: ownerID, paginationToken: paginationToken)

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
