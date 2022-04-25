//
//  UsersViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/04/25.
//

import Foundation
import Sweet

@MainActor protocol UsersViewModelProtocol: ObservableObject {
  var users: [Sweet.UserModel] { get set }

  func fetchUsers() async
}
