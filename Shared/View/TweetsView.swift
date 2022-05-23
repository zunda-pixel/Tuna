//
//  TweetsView.swift
//  Tuna
//
//  Created by zunda on 2022/03/21.
//

import CoreData
import Sweet
import SwiftUI

extension Sweet.TwitterError: LocalizedError {

}

struct TweetsView: View {
  let userID: String

  @Environment(\.managedObjectContext) private var viewContext

  @State var error: Sweet.TwitterError?
  @State var didError = false
  @State var isPresentedTweetToolbar = false
  @State var latestTapTweetID: String?

  @FetchRequest private var timelines: FetchedResults<Timeline>
  @FetchRequest private var allTweets: FetchedResults<Tweet>
  @FetchRequest private var allUsers: FetchedResults<User>
  @FetchRequest private var allMedias: FetchedResults<Media>
  @FetchRequest private var allPolls: FetchedResults<Poll>
  @FetchRequest private var allPlaces: FetchedResults<Place>
  @FetchRequest private var showTweets: FetchedResults<Tweet>

  init(userID: String) {
    self.userID = userID

    self._timelines = FetchRequest(
      entity: Timeline.entity(),
      sortDescriptors: [],
      predicate: .init(format: "ownerID = %@", userID)
    )

    self._showTweets = FetchRequest(
      entity: Tweet.entity(),
      sortDescriptors: [NSSortDescriptor(keyPath: \Tweet.createdAt, ascending: false)]
    )

    self._allTweets = FetchRequest(
      entity: Tweet.entity(),
      sortDescriptors: [NSSortDescriptor(keyPath: \Tweet.createdAt, ascending: false)]
    )

    self._allUsers = FetchRequest(entity: User.entity(), sortDescriptors: [])
    self._allMedias = FetchRequest(entity: Media.entity(), sortDescriptors: [])
    self._allPolls = FetchRequest(entity: Poll.entity(), sortDescriptors: [])
    self._allPlaces = FetchRequest(entity: Place.entity(), sortDescriptors: [])
  }

  private func updateTimeLine() {
    let tweetIDs = timelines.compactMap(\.tweetID)
    showTweets.nsPredicate = NSPredicate(format: "id IN %@", tweetIDs)
  }

  private func getPlace(placeID: String?) -> Sweet.PlaceModel? {
    guard let placeID = placeID,
          let firstPlace = allPlaces.first(where: { $0.id == placeID })
    else {
      return nil
    }

    let placeModel: Sweet.PlaceModel = .init(place: firstPlace)
    return placeModel
  }

  private func getPoll(pollKey: String?) -> Sweet.PollModel? {
    guard let pollKey = pollKey,
      let firstPoll = allPolls.first(where: { $0.id == pollKey })
    else {
      return nil
    }

    let pollModel: Sweet.PollModel = .init(poll: firstPoll)

    return pollModel
  }

  private func getMedias(mediaKeys: [String]?) -> [Sweet.MediaModel] {
    guard let mediaKeys = mediaKeys else {
      return []
    }

    let medias = allMedias.filter { mediaKeys.contains($0.key!) }

    let mediaModels: [Sweet.MediaModel] = medias.map { .init(media: $0) }

    return mediaModels
  }

  private func getAuthorUser(authorID: String?) -> Sweet.UserModel? {
    guard let authorID = authorID,
      let user = allUsers.first(where: { $0.id == authorID })
    else {
      return nil
    }

    let userModel: Sweet.UserModel = .init(user: user)

    return userModel
  }

  private func getRetweetTweet(retweetID: String?) -> Sweet.TweetModel? {
    guard let retweetID = retweetID else {
      return nil
    }

    let retweetTweet = allTweets.first { $0.id == retweetID }

    var retweetTweetModel: Sweet.TweetModel? = nil

    if let retweetTweet = retweetTweet {
      retweetTweetModel = .init(tweet: retweetTweet)
    }

    return retweetTweetModel
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

  func addTimeline(tweet: Sweet.TweetModel, userID: String) throws {
    if let _ = timelines.first(where: { $0.tweetID == tweet.id }) {
      return
    }

    let newTimeline = Timeline(context: viewContext)
    newTimeline.tweetID = tweet.id
    newTimeline.ownerID = userID
    try viewContext.save()
  }

  func getTimeline(first firstTweetID: String? = nil, last lastTweetID: String? = nil) async {
    do {
      let sweet = try await Sweet()

      let maxResults = 100

      let response = try await sweet.fetchTimeLine(by: userID, maxResults: maxResults, untilID: lastTweetID, sinceID: firstTweetID)

      try response.tweets.forEach { tweet in
        try addTweet(tweet)
        try addTimeline(tweet: tweet, userID: userID)
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

      if firstTweetID != nil && response.tweets.count == maxResults {
        let firstTweetID = timelines.first?.tweetID
        await getTimeline(first: firstTweetID)
      }

      updateTimeLine()
    } catch {
      self.error = error as? Sweet.TwitterError
      self.didError.toggle()
    }
  }

  var body: some View {
    List {
      ForEach(showTweets) { tweet in
        let tweetModel: Sweet.TweetModel = .init(tweet: tweet)

        let retweetTweetModel = getRetweetTweet(retweetID: tweetModel.referencedTweet?.id)

        let authorUser = getAuthorUser(authorID: tweet.authorID!)!
        let retweetUser = getAuthorUser(authorID: retweetTweetModel?.authorID)

        let medias = getMedias(mediaKeys: tweetModel.attachments?.mediaKeys)

        let poll = getPoll(pollKey: tweetModel.attachments?.pollID)

        let place = getPlace(placeID: tweetModel.geo?.placeID)

        let viewModel: TweetCellViewModel = .init(
          tweet: tweetModel, retweet: retweetTweetModel, author: authorUser,
          retweetUser: retweetUser, medias: medias, poll: poll, place: place)
        VStack {
          TweetCellView(viewModel: viewModel)
            .onTapGesture {
              latestTapTweetID = tweetModel.id
              isPresentedTweetToolbar.toggle()
            }
          if let latestTapTweetID = latestTapTweetID, latestTapTweetID == tweetModel.id, isPresentedTweetToolbar{
            TweetToolBar(userID: authorUser.id, tweetID: tweetModel.id)
          }
        }
        .onAppear {
          guard let lastTweet = showTweets.last else{
            return
          }

          if tweet.id == lastTweet.id {
            Task {
              await getTimeline(last: tweet.id)
            }
          }
        }
        .swipeActions(edge: .leading) {
          Button(
            action: {
              Task {
                try! await Sweet().retweet(userID: userID, tweetID: tweetModel.id)
              }
            },
            label: {
              Label("like", systemImage: "heart")
            })
        }
        .swipeActions(edge: .trailing) {
          let retweeted = tweetModel.referencedTweet?.type == .retweeted
          Button(
            action: {
              Task {
                if retweeted {
                  try! await Sweet().deleteRetweet(
                    userID: userID, tweetID: tweetModel.id)
                } else {
                  try! await Sweet().retweet(userID: userID, tweetID: tweetModel.id)
                }
              }
            },
            label: {
              Label(retweeted ? "remove" : "retweet", systemImage: "repeat")
            }
          )
          .tint(retweeted ? .red : .green)
        }
      }
    }
    .alert("Error", isPresented: $didError) {
      Button {
        print(error!)
      } label: {
        Text("Close")
      }
    }
    .listStyle(.plain)
    .refreshable {
      let firstTweetID = timelines.first?.tweetID
      await getTimeline(first: firstTweetID)
    }
    .onAppear {
      Task {
        await getTimeline()
        updateTimeLine()
      }
    }
  }
}

struct TweetsView_Previews: PreviewProvider {
  static var previews: some View {
    TweetsView(userID: "")
  }
}
