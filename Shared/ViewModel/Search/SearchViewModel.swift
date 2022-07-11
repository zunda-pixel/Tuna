//
//  SearchViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/05/26.
//

import Foundation

@MainActor protocol SearchViewProtocol: ObservableObject {
  associatedtype TweetsViewModel: SearchTweetsViewModel
  associatedtype UsersViewModel: SearchUsersViewModel

  var searchUserIDs: [String] { get }
  var tweetsViewModel: TweetsViewModel { get set }
  var usersViewModel: UsersViewModel { get set }
}

@MainActor final class SearchViewModel: NSObject, SearchViewProtocol {
  var searchUserIDs: [String] = []
  @Published var tweetsViewModel: SearchTweetsViewModel
  @Published var usersViewModel: SearchUsersViewModel
  var searchText: String = ""

  init(userID: String) {

    self.tweetsViewModel = .init(userID: userID)
    self.usersViewModel = .init(userID: userID)
  }
}
