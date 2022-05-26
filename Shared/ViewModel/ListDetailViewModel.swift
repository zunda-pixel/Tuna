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

final class ListTweetsViewModel: NSObject, TweetsViewProtocol {
  var loadingTweets = false
  var paginationToken: String?
  var latestTapTweetID: String?
  var error: Error?
  var timelines: [String] = []

  let listID: String
  let userID: String

  @Published var isPresentedTweetToolbar: Bool = false
  @Published var didError: Bool = false

  let viewContext: NSManagedObjectContext

  let fetchShowTweetController: NSFetchedResultsController<Tweet>
  let fetchTweetController: NSFetchedResultsController<Tweet>
  let fetchUserController: NSFetchedResultsController<User>
  let fetchMediaController: NSFetchedResultsController<Media>
  let fetchPollController: NSFetchedResultsController<Poll>
  let fetchPlaceController: NSFetchedResultsController<Place>

  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async {
    do {
      let maxResults = 100

      let listResponse = try await Sweet().fetchListTweets(listID: listID, maxResults: maxResults, paginationToken: paginationToken)

      paginationToken = listResponse.meta?.nextToken

      let tweetIDs = listResponse.tweets.map(\.id)

      if tweetIDs.isEmpty {
        return
      }

      let tweetResponse = try await  Sweet().lookUpTweets(by: tweetIDs)

      try tweetResponse.tweets.forEach { tweet in
        try addTweet(tweet)
        try addTimeline(tweet.id)
      }

      try tweetResponse.relatedTweets.forEach { tweet in
        try addTweet(tweet)
      }

      try tweetResponse.users.forEach { user in
        try addUser(user)
      }

      try tweetResponse.medias.forEach { media in
        try addMedia(media)
      }

      try tweetResponse.polls.forEach { poll in
        try addPoll(poll)
      }

      try tweetResponse.places.forEach { place in
        try addPlace(place)
      }

      updateTimeLine()

      if let firstTweetID = firstTweetID, tweetResponse.tweets.count == maxResults {
        await fetchTweets(first: firstTweetID, last: nil)
      }
    } catch let newError {
      self.error = newError
      self.didError.toggle()
    }
  }

  init(userID: String, listID: String, viewContext: NSManagedObjectContext) {
    self.userID = userID
    self.listID = listID
    self.viewContext = viewContext

    self.fetchShowTweetController = {
      let fetchRequest = NSFetchRequest<Tweet>()
      fetchRequest.entity = Tweet.entity()
      fetchRequest.sortDescriptors = [.init(keyPath: \Tweet.createdAt, ascending: false)]
      fetchRequest.predicate = .init(format: "id IN %@", [])

      return NSFetchedResultsController<Tweet>(
        fetchRequest: fetchRequest,
        managedObjectContext: viewContext,
        sectionNameKeyPath: nil,
        cacheName: nil
      )
    }()

    self.fetchTweetController = {
      let fetchRequest = NSFetchRequest<Tweet>()
      fetchRequest.entity = Tweet.entity()
      fetchRequest.sortDescriptors = []

      return NSFetchedResultsController<Tweet>(
        fetchRequest: fetchRequest,
        managedObjectContext: viewContext,
        sectionNameKeyPath: nil,
        cacheName: nil
      )
    }()

    self.fetchUserController = {
      let fetchRequest = NSFetchRequest<User>()
      fetchRequest.entity = User.entity()
      fetchRequest.sortDescriptors = []

      return NSFetchedResultsController<User>(
        fetchRequest: fetchRequest,
        managedObjectContext: viewContext,
        sectionNameKeyPath: nil,
        cacheName: nil
      )
    }()

    self.fetchPollController = {
      let fetchRequest = NSFetchRequest<Poll>()
      fetchRequest.entity = Poll.entity()
      fetchRequest.sortDescriptors = []

      return NSFetchedResultsController<Poll>(
        fetchRequest: fetchRequest,
        managedObjectContext: viewContext,
        sectionNameKeyPath: nil,
        cacheName: nil
      )
    }()

    self.fetchMediaController = {
      let fetchRequest = NSFetchRequest<Media>()
      fetchRequest.entity = Media.entity()
      fetchRequest.sortDescriptors = []

      return NSFetchedResultsController<Media>(
        fetchRequest: fetchRequest,
        managedObjectContext: viewContext,
        sectionNameKeyPath: nil,
        cacheName: nil
      )
    }()

    self.fetchPlaceController = {
      let fetchRequest = NSFetchRequest<Place>()
      fetchRequest.entity = Place.entity()
      fetchRequest.sortDescriptors = []

      return NSFetchedResultsController<Place>(
        fetchRequest: fetchRequest,
        managedObjectContext: viewContext,
        sectionNameKeyPath: nil,
        cacheName: nil
      )
    }()

    super.init()

    fetchShowTweetController.delegate = self
    fetchTweetController.delegate = self
    fetchUserController.delegate = self
    fetchPlaceController.delegate = self
    fetchPollController.delegate = self
    fetchMediaController.delegate = self

    try! fetchShowTweetController.performFetch()
    try! fetchTweetController.performFetch()
    try! fetchUserController.performFetch()
    try! fetchPlaceController.performFetch()
    try! fetchPollController.performFetch()
    try! fetchMediaController.performFetch()
  }

  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    objectWillChange.send()
  }

  func addTimeline(_ tweetID: String) throws {
    if timelines.contains(where: { $0 == tweetID }) {
      return
    }

    timelines.append(tweetID)
  }

  func updateTimeLine() {
    fetchShowTweetController.fetchRequest.predicate = .init(format: "id IN %@", timelines)

    // TODOなぜかこれをしないとうまく動作しない
    try! fetchShowTweetController.performFetch()
  }
}


