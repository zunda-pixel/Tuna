//
//  ListDetailViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/04/21.
//

import Foundation
import Sweet
import CoreData

@MainActor protocol ListDetailViewProtocol: ObservableObject {
  associatedtype TweetsViewModel: TweetsViewProtocol
  var list: Sweet.ListModel { get }
  var tweetsViewModel: TweetsViewModel { get }
  var userID: String { get }
}

@MainActor final class ListDetailViewModel<T: TweetsViewProtocol>: ListDetailViewProtocol {
  let userID: String
  let list: Sweet.ListModel
  let tweetsViewModel: T

  init(userID: String, list: Sweet.ListModel, tweetsViewModel: T) {
    self.userID = userID
    self.list = list
    self.tweetsViewModel = tweetsViewModel
  }
}
