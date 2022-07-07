//
//  FollowerUserViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/06/05.
//

import Foundation
import Sweet

@MainActor final class FollowerUserViewModel: UsersViewProtocol {
  let userID: String

  var paginationToken: String?
  var error: Error?

  @Published var didError = false
  @Published var users: [Sweet.UserModel] = []

  init(userID: String) {
    self.userID = userID
  }

  func fetchUsers(reset resetData: Bool) async {
    do {
      let response = try await Sweet(userID: userID).fetchFollower(userID: userID, paginationToken: paginationToken)

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
