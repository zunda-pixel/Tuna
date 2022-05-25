//
//  ListDetailViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/04/21.
//

import Foundation
import Sweet

@MainActor protocol ListDetailViewProtocol: ObservableObject {
  var list: Sweet.ListModel { get }

  var didError: Bool { get set }
  var error: Error? { get set }
  var timelines: [String] { get set }

  var allTweets: [Sweet.TweetModel] { get set }
  var allUsers: [Sweet.UserModel] { get set }
  var allMedias: [Sweet.MediaModel] { get set }
  var allPolls: [Sweet.PollModel] { get set }
  var allPlaces: [Sweet.PlaceModel] { get }

  func getTweet(_ tweetID: String?) -> Sweet.TweetModel?
  func getPoll(_ pollID: String?) -> Sweet.PollModel?
  func getUser(_ userID: String?) -> Sweet.UserModel?
  func getMedias(_ mediaIDs: [String]?) -> [Sweet.MediaModel]
  func getPlace(_ placeID: String?) -> Sweet.PlaceModel?
  func getTweetCellViewModel(_ tweetID: String) -> TweetCellViewModel
  func fetchTweets() async
}

extension ListDetailViewProtocol {
  func getTweetCellViewModel(_ tweetID: String) -> TweetCellViewModel {
    let tweetModel = getTweet(tweetID)!

    let retweetTweetModel = getTweet(tweetModel.referencedTweet?.id)

    let authorUser = getUser(tweetModel.authorID!)!

    let retweetUser = getUser(retweetTweetModel?.authorID)

    let medias = getMedias(tweetModel.attachments?.mediaKeys)

    let poll = getPoll(tweetModel.attachments?.pollID)

    let place = getPlace(tweetModel.geo?.placeID)

    let viewModel: TweetCellViewModel = .init(tweet: tweetModel, retweet: retweetTweetModel, author: authorUser, retweetUser: retweetUser, medias: medias, poll: poll, place: place)

    return viewModel
  }

  func getPlace(_ placeID: String?) -> Sweet.PlaceModel? {
    guard let placeID = placeID else { return nil }

    let firstPlace = allPlaces.first(where: { $0.id == placeID })

    return firstPlace
  }

  func getPoll(_ pollID: String?) -> Sweet.PollModel? {
    guard let pollID = pollID else { return nil }

    let firstPoll = allPolls.first(where: { $0.id == pollID })

    return firstPoll
  }

  func getMedias(_ mediaIDs: [String]?) -> [Sweet.MediaModel] {
    guard let mediaIDs = mediaIDs else {
      return []
    }

    let medias = allMedias.filter { mediaIDs.contains($0.key) }

    return medias
  }

  func getUser(_ userID: String?) -> Sweet.UserModel? {
    guard let userID = userID else { return nil }

    let user = allUsers.first(where: { $0.id == userID })

    return user
  }

  func getTweet(_ tweetID: String?) -> Sweet.TweetModel? {
    guard let tweetID = tweetID else {
      return nil
    }

    let retweetTweet = allTweets.first { $0.id == tweetID }

    return retweetTweet
  }
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
