//
//  UserMentionsViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/06/04.
//

import Foundation
import CoreData
import Sweet

final class UserMentionsViewModel: NSObject, TweetsViewProtocol {
  var userID: String
  var latestTapTweetID: String?
  var error: Error?

  @Published var didError: Bool = false
  @Published var loadingTweets: Bool = false
  @Published var isPresentedTweetToolbar: Bool = false
  @Published var isPresentedTweetDetail: Bool = false

  let viewContext: NSManagedObjectContext

  var paginationToken: String?

  var timelines: [String] = []

  let fetchShowTweetController: NSFetchedResultsController<Tweet>
  let fetchTweetController: NSFetchedResultsController<Tweet>
  let fetchUserController: NSFetchedResultsController<User>
  let fetchMediaController: NSFetchedResultsController<Media>
  let fetchPollController: NSFetchedResultsController<Poll>
  let fetchPlaceController: NSFetchedResultsController<Place>

  var showTweets: [Tweet] { fetchShowTweetController.fetchedObjects ?? [] }
  var allTweets: [Tweet] { fetchTweetController.fetchedObjects ?? [] }
  var allUsers: [User] { fetchUserController.fetchedObjects ?? [] }
  var allMedias: [Media] { fetchMediaController.fetchedObjects ?? [] }
  var allPolls: [Poll] { fetchPollController.fetchedObjects ?? [] }
  var allPlaces: [Place] { fetchPlaceController.fetchedObjects ?? [] }


  func getTweet(_ tweetID: String?) -> Sweet.TweetModel? {
    guard let tweetID = tweetID else { return nil }

    guard let tweet = allTweets.first(where: { $0.id == tweetID }) else { return nil }

    return .init(tweet: tweet)
  }
  
  func addPlace(_ place: Sweet.PlaceModel) throws {
    if let firstPlace = allPlaces.first(where: { $0.id == place.id }) {
      firstPlace.setPlaceModel(place)
    } else {
      let newPlace = Place(context: viewContext)
      newPlace.setPlaceModel(place)
    }

    try viewContext.save()
  }

  func addTweet(_ tweet: Sweet.TweetModel) throws {
    if let firstTweet = allTweets.first(where: { $0.id == tweet.id }) {
      try firstTweet.setTweetModel(tweet)
    } else {
      let newTweet = Tweet(context: viewContext)
      try newTweet.setTweetModel(tweet)
    }

    try viewContext.save()
  }

  func addPoll(_ poll: Sweet.PollModel) throws {
    if let firstPoll = allPolls.first(where: { $0.id == poll.id }) {
      try firstPoll.setPollModel(poll)
    } else {
      let newPoll = Poll(context: viewContext)
      try newPoll.setPollModel(poll)
    }
    try viewContext.save()
  }

  func addUser(_ user: Sweet.UserModel) throws {
    if let firstUser = allUsers.first(where: { $0.id == user.id }) {
      try firstUser.setUserModel(user)
    } else {
      let newUser = User(context: viewContext)
      try newUser.setUserModel(user)
    }
    try viewContext.save()
  }

  func addMedia(_ media: Sweet.MediaModel) throws {
    if let firstMedia = allMedias.first(where: { $0.key == media.key }) {
      firstMedia.setMediaModel(media)
    } else {
      let newMedia = Media(context: viewContext)
      newMedia.setMediaModel(media)
    }
    try viewContext.save()
  }

  
  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async {
    do {
      let response = try await Sweet(userID: userID).fetchMentions(by: userID, untilID: lastTweetID, sinceID: firstTweetID, paginationToken: paginationToken)

      paginationToken = response.meta?.nextToken

      try response.tweets.forEach { tweet in
        try addTweet(tweet)
        try addTimeline(tweet.id)
      }

      try response.relatedTweets.forEach { tweet in
        try addTweet(tweet)
      }

      try response.users.forEach { user in
        try addUser(user)
      }

      try response.medias.forEach { media in
        try addMedia(media)
      }

      try response.polls.forEach { poll in
        try addPoll(poll)
      }

      try response.places.forEach { place in
        try addPlace(place)
      }

      updateTimeLine()
    } catch let newError {
      self.error = newError
      self.didError.toggle()
    }
  }

  init(userID: String, viewContext: NSManagedObjectContext) {
    self.userID = userID
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
