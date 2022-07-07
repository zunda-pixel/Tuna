//
//  SearchUsersViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/05/31.
//

import Foundation
import Sweet

@MainActor final class SearchUsersViewModel: UsersViewProtocol {
  var paginationToken: String?
  var searchText: String = ""
  var error: Error?

  let userID: String

  init(userID: String) {
    self.userID = userID
  }

  @Published var didError: Bool = false
  @Published var users: [Sweet.UserModel] = []

  func fetchUsers(reset resetData : Bool) async {
    var newUsers: [Sweet.UserModel] = []

    if let response = try? await Sweet(userID: userID).lookUpUser(screenID: searchText) {
      newUsers.append(response.user)
    }

    if let response = try? await Sweet(userID: userID).lookUpUser(userID: searchText) {
      if !newUsers.contains(where: { $0.id == response.user.id } ) {
        newUsers.append(response.user)
      }
    }

    self.users = newUsers
  }
}
