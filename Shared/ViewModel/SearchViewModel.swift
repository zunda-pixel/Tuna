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

@MainActor final class SearchViewModel<T: SearchTweetsViewModel, U: SearchUsersViewModel>: NSObject, SearchViewProtocol {
  var searchUserIDs: [String] = []
  var tweetsViewModel: T
  var usersViewModel: U
  var searchText: String = ""

  init(tweetsViewModel: T, usersViewModel: U) {
    self.tweetsViewModel = tweetsViewModel
    self.usersViewModel = usersViewModel
  }
}
