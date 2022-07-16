//
//  ListDetailViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/04/21.
//

import Foundation
import Sweet

@MainActor protocol ListDetailViewProtocol: ObservableObject, Hashable {
  associatedtype TweetsViewModel: TweetsViewProtocol
  var list: Sweet.ListModel { get }
  var tweetsViewModel: TweetsViewModel { get }
  var userID: String { get }
}

final class ListDetailViewModel: ListDetailViewProtocol {
  static func == (lhs: ListDetailViewModel, rhs: ListDetailViewModel) -> Bool {
    lhs.list.id == rhs.list.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(list)
    hasher.combine(tweetsViewModel)
  }

  let userID: String
  let list: Sweet.ListModel
  let tweetsViewModel: ListTweetsViewModel

  init(userID: String, list: Sweet.ListModel, tweetsViewModel: ListTweetsViewModel) {
    self.userID = userID
    self.list = list
    self.tweetsViewModel = tweetsViewModel
  }
}
