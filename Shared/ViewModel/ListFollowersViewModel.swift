//
//  ListFollowersViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/05/31.
//

import Foundation
import Sweet

final class ListFollowersViewModel: UsersViewProtocol {
  static func == (lhs: ListFollowersViewModel, rhs: ListFollowersViewModel) -> Bool {
    lhs.listID == lhs.listID
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(listID)
    hasher.combine(paginationToken)
    hasher.combine(userID)
    hasher.combine(users)
  }

  let listID: String

  var paginationToken: String?
  var error: Error?

  @Published var didError = false
  @Published var users: [Sweet.UserModel] = []

  let userID: String

  init(userID: String, listID: String) {
    self.userID = userID
    self.listID = listID
  }

  func fetchUsers(reset resetData: Bool) async {
    do {
      let response = try await Sweet(userID: userID).fetchListFollowers(listID: listID, paginationToken: paginationToken)

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
