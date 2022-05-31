//
//  ListMembersViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/04/25.
//

import Foundation
import Sweet

@MainActor final class ListFollowersViewModel: UsersViewProtocol {
  var paginationToken: String?

  @Published var didError = false

  var error: Error?
  @Published var users: [Sweet.UserModel] = []
  let listID: String

  init(listID: String) {
    self.listID = listID
  }

  func fetchUsers(reset resetData: Bool) async {
    do {
      let response = try await Sweet().fetchFollowedUsers(listID: listID, paginationToken: paginationToken)

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

@MainActor final class ListMembersViewModel: UsersViewProtocol {
  var paginationToken: String?

  @Published var didError = false

  var error: Error?
  var users: [Sweet.UserModel] = []
  let listID: String

  init(listID: String) {
    self.listID = listID
  }

  func fetchUsers(reset resetData: Bool) async {
    do {
      let response = try await Sweet().fetchAddedUsersToList(listID: listID, paginationToken: paginationToken)

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
