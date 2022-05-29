//
//  ListMembersViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/04/25.
//

import Foundation
import Sweet

@MainActor final class ListMembersViewModel: UsersViewProtocol {
  var paginationToken: String?

  @Published var didError = false

  var error: Error?
  var users: [Sweet.UserModel] = []
  let listID: String

  init(listID: String) {
    self.listID = listID
  }

  func fetchUsers() async {
    do {
      let response = try await Sweet().fetchAddedUsersToList(listID: listID, paginationToken: paginationToken)

      if response.meta?.nextToken != nil {
        users = response.users
      } else {
        users.append(contentsOf: response.users)
      }

      paginationToken = response.meta?.nextToken
    } catch let newError {
      self.error = newError
      self.didError.toggle()
    }
  }
}
