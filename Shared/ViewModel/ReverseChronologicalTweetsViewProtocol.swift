//


import Foundation

import Foundation
import Sweet
import CoreData

@MainActor protocol ReverseChronologicalTweetsViewProtocol: NSFetchedResultsControllerDelegate, ObservableObject {
  var loadingTweets: Bool { get set }

  var userID: String { get }
  var isPresentedTweetToolbar: Bool { get set }
  var latestTapTweetID: String? { get set }

  var error: Error? { get }
  var didError: Bool { get set }

  var paginationToken: String? { get set }
  var viewContext: NSManagedObjectContext { get }

  var showTweets: [Tweet] { get }
  var allUsers: [User] { get }
  var allMedias: [Media] { get }
  var allPolls: [Poll] { get }
  var allPlaces: [Place] { get }

  func addTimeline(_ tweetID: String) throws
  func addTweet(_ tweet: Sweet.TweetModel) throws
  func addUser(_ user: Sweet.UserModel) throws
  func addPlace(_ place: Sweet.PlaceModel) throws
  func addPoll(_ poll: Sweet.PollModel) throws
  func addMedia(_ media: Sweet.MediaModel) throws

  func getTweet(_ tweetID: String?) -> Sweet.TweetModel?
  func getPoll(_ pollID: String?) -> Sweet.PollModel?
  func getUser(_ userID: String?) -> Sweet.UserModel?
  func getMedias(_ mediaIDs: [String]?) -> [Sweet.MediaModel]
  func getPlace(_ placeID: String?) -> Sweet.PlaceModel?

  func getTweetCellViewModel(_ tweetID: String) -> TweetCellViewModel

  func fetchTweets(first firstTweetID: String?, last lastTweetID: String?) async
  func updateTimeLine()

  var fetchTimelineController: NSFetchedResultsController<Timeline> { get }
  var fetchShowTweetController: NSFetchedResultsController<Tweet> { get }
  var fetchTweetController: NSFetchedResultsController<Tweet> { get }
  var fetchUserController: NSFetchedResultsController<User> { get }
  var fetchMediaController: NSFetchedResultsController<Media> { get }
  var fetchPollController: NSFetchedResultsController<Poll> { get }
  var fetchPlaceController: NSFetchedResultsController<Place> { get }
}

extension ReverseChronologicalTweetsViewProtocol {
  var timelines: [String] { fetchTimelineController.fetchedObjects?.map(\.tweetID!) ?? [] }
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

  func addTimeline(_ tweetID: String) throws {
    if timelines.contains(where: { $0 == tweetID }) {
      return
    }

    let newTimeline = Timeline(context: viewContext)
    newTimeline.tweetID = tweetID
    newTimeline.ownerID = userID
    try viewContext.save()
  }

  func updateTimeLine() {
    fetchShowTweetController.fetchRequest.predicate = .init(format: "id IN %@", timelines)
  }
  
  func getPlace(_ placeID: String?) -> Sweet.PlaceModel? {
    guard let placeID = placeID else { return nil }

    guard let firstPlace = allPlaces.first(where: { $0.id == placeID }) else {
      return nil
    }

    return .init(place: firstPlace)
  }

  func getPoll(_ pollID: String?) -> Sweet.PollModel? {
    guard let pollID = pollID else { return nil }

    guard let firstPoll = allPolls.first(where: { $0.id == pollID }) else { return nil }

    return .init(poll: firstPoll)
  }

  func getMedias(_ mediaIDs: [String]?) -> [Sweet.MediaModel] {
    guard let mediaIDs = mediaIDs else {
      return []
    }

    let medias = allMedias.filter({ mediaIDs.contains($0.key!) })

    return medias.map { .init(media: $0) }
  }

  func getUser(_ userID: String?) -> Sweet.UserModel? {
    guard let userID = userID else { return nil }

    guard let firstUser = allUsers.first(where: { $0.id == userID }) else { return nil }

    return .init(user: firstUser)
  }

  func getTweetCellViewModel(_ tweetID: String) -> TweetCellViewModel {
    let tweet = getTweet(tweetID)!

    let author = getUser(tweet.authorID!)!

    let retweet: (user: Sweet.UserModel, tweet: Sweet.TweetModel)? = {
      if tweet.referencedTweet?.type != .retweeted { return nil }

      let tweet = getTweet(tweet.referencedTweet?.id)!
      let user = getUser(tweet.authorID)!

      return (user, tweet)
    }()

    let quoted: (user: Sweet.UserModel, tweet: Sweet.TweetModel)? = {
      guard let quotedTweetID: String? = {
        if tweet.referencedTweet?.type == .quoted {
          return tweet.referencedTweet?.id
        }

        if retweet?.tweet.referencedTweet?.type == .quoted {
          return retweet?.tweet.referencedTweet?.id
        }

        return nil
      }() else { return nil }

      let tweet = getTweet(quotedTweetID) ?? .init(id: UUID().uuidString, text: "Nothing Tweet")

      let user = getUser(tweet.authorID) ?? .init(id: UUID().uuidString, name: "Nothing Name", userName: "Nothing Name")

      return (user, tweet)
    }()

    let medias = getMedias(tweet.attachments?.mediaKeys)

    let poll = getPoll(tweet.attachments?.pollID)

    let place = getPlace(tweet.geo?.placeID)

    let viewModel: TweetCellViewModel = .init(
      userID: userID,
      tweet: tweet, author: author,
      retweet: retweet,
      quoted: quoted,
      medias: medias, poll: poll, place: place)

    return viewModel
  }
}
