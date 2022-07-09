//
//  ListDetailViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/04/21.
//

import Foundation
import Sweet
import CoreData

@MainActor protocol ListDetailViewProtocol: ObservableObject, Hashable {
  associatedtype TweetsViewModel: TweetsViewProtocol
  var list: Sweet.ListModel { get }
  var tweetsViewModel: TweetsViewModel { get }
  var userID: String { get }
}

final class ListDetailViewModel<T: TweetsViewProtocol>: ListDetailViewProtocol {
  static func == (lhs: ListDetailViewModel<T>, rhs: ListDetailViewModel<T>) -> Bool {
    lhs.list.id == rhs.list.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(userID)
    hasher.combine(list)
    hasher.combine(tweetsViewModel)
  }

  let userID: String
  let list: Sweet.ListModel
  let tweetsViewModel: T

  init(userID: String, list: Sweet.ListModel, tweetsViewModel: T) {
    self.userID = userID
    self.list = list
    self.tweetsViewModel = tweetsViewModel
  }
}
