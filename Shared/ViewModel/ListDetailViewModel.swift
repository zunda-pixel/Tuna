//
//  ListDetailViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/04/21.
//

import Foundation
import Sweet

@MainActor protocol ListDetailViewProtocol: TweetsViewProtocol {
  var list: Sweet.ListModel { get }
}

@MainActor final class ListDetailViewModel: ListDetailViewProtocol {
  var error: Error?
  @Published var didError: Bool = false
  @Published var timelines: [String] = []
  @Published var allTweets: [Sweet.TweetModel] = []
  @Published var allUsers: [Sweet.UserModel] = []
  @Published var allMedias: [Sweet.MediaModel] = []
  @Published var allPolls: [Sweet.PollModel] = []
  @Published var allPlaces: [Sweet.PlaceModel] = []

  var paginationToken: String? = nil

  let list: Sweet.ListModel

  init(list: Sweet.ListModel) {
    self.list = list
  }

  func fetchTweets() async {
    do {
      let sweet = try await Sweet()
      let listResponse = try await sweet.fetchListTweets(listID: list.id, paginationToken: paginationToken)

      paginationToken = listResponse.meta?.nextToken

      let tweetIDs = listResponse.tweets.map(\.id)

      if tweetIDs.isEmpty {
        return
      }

      let tweetResponse = try await sweet.lookUpTweets(by: tweetIDs)

      tweetResponse.tweets.forEach {
        allTweets.appendIfNotContains($0)
      }

      tweetResponse.relatedTweets.forEach {
        allTweets.appendIfNotContains($0)
      }

      tweetResponse.users.forEach {
        allUsers.appendIfNotContains($0)
      }

      tweetResponse.polls.forEach {
        allPolls.appendIfNotContains($0)
      }

      tweetResponse.medias.forEach {
        allMedias.appendIfNotContains($0)
      }

      tweetResponse.places.forEach {
        allPlaces.appendIfNotContains($0)
      }

      timelines.append(contentsOf: tweetIDs)
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }
}
