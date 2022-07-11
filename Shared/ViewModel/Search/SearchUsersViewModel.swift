//
//  SearchUsersViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/05/31.
//

import Foundation
import Sweet

@MainActor final class SearchUsersViewModel: ObservableObject {
  let userID: String

  var searchText: String = ""

  @Published var users: [Sweet.UserModel] = []

  init(userID: String) {
    self.userID = userID
  }

  func fetchUsers() async {
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
