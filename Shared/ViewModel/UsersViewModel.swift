//
//  UsersViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/04/25.
//

import Foundation
import Sweet

@MainActor protocol UsersViewProtocol: ObservableObject {
  var users: [Sweet.UserModel] { get set }
  var error: Error? { get set }
  var didError: Bool { get set }
  var paginationToken: String? { get set }
  func fetchUsers(reset resetData : Bool) async
}
