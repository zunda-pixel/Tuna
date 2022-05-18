//
//  ListMembersViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/04/25.
//

import Foundation
import Sweet

@MainActor final class ListMembersViewModel: UsersViewProtocol {
  var users: [Sweet.UserModel]
  let listID: String

  init(listID: String, users: [Sweet.UserModel] = []) {
    self.listID = listID
    self.users = users
  }

  func fetchUsers() async {
    do {
      let sweet = try await Sweet()
      let listResponse = try await sweet.fetchAddedUsersToList(listID: listID)
      users = listResponse.users
    } catch {
      print(error)
    }
  }
}
