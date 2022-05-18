//
//  SearchView.swift
//  Tuna
//
//  Created by zunda on 2022/04/18.
//

import SwiftUI
import Sweet

struct SearchView: View {
  @State private var timelines: [String] = []
  @State private var allTweets: [Sweet.TweetModel] = []
  @State private var allUsers: [Sweet.UserModel] = []
  @State private var allMedias: [Sweet.MediaModel] = []
  @State private var allPolls: [Sweet.PollModel] = []
  @State private var allPlaces: [Sweet.PlaceModel] = []
  @State private var searchText: String = ""
  @State private var searchUserIDs: [String] = []

  func searchUser() async {
    searchUserIDs = []

    if let userResponse = try? await Sweet().lookUpUser(userID: searchText) {
      allUsers.appendIfNotContains(userResponse.user)
      searchUserIDs.appendIfNotContains(userResponse.user.id)
    }

    if let screenResponse = try? await Sweet().lookUpUser(screenID: searchText) {
      allUsers.appendIfNotContains(screenResponse.user)
      searchUserIDs.appendIfNotContains(screenResponse.user.id)
    }
  }

  func searchTweet(old oldTweetID: String? = nil, latest latestTweetID: String? = nil) async {
    do {
      let searchResponse = try await Sweet().searchRecentTweet(by: searchText, untilID: oldTweetID, sinceID: latestTweetID)
      let tweetIDs = searchResponse.tweets.map(\.id)

      if tweetIDs.isEmpty {
        if oldTweetID == nil && latestTweetID == nil {
          timelines = []
        }

        return
      }

      let tweetResponse = try await Sweet().lookUpTweets(by: tweetIDs)

      tweetResponse.tweets.forEach {
        allTweets.appendIfNotContains($0)
      }

      tweetResponse.relatedTweets.forEach {
        allTweets.appendIfNotContains($0)
      }

      tweetResponse.users.forEach {
        allUsers.appendIfNotContains($0)
      }

      tweetResponse.medias.forEach {
        allMedias.appendIfNotContains($0)
      }

      tweetResponse.polls.forEach {
        allPolls.appendIfNotContains($0)
      }

      tweetResponse.places.forEach {
        allPlaces.appendIfNotContains($0)
      }


      if oldTweetID != nil {
        timelines.append(contentsOf: tweetIDs)
      } else if latestTweetID != nil {
        timelines = tweetIDs + timelines
      } else {
        timelines = tweetIDs
      }
    } catch {
      print(error)
      fatalError()
    }
  }

  private func getPlace(placeID: String?) -> Sweet.PlaceModel? {
    guard let placeID = placeID else { return nil }

    let firstPlace = allPlaces.first(where: { $0.id == placeID })

    return firstPlace
  }

  private func getPoll(key pollKey: String?) -> Sweet.PollModel? {
    guard let pollKey = pollKey else { return nil}

    let firstPoll = allPolls.first(where: { $0.id == pollKey })

    return firstPoll
  }

  private func getMedias(keys mediaKeys: [String]?) -> [Sweet.MediaModel] {
    guard let mediaKeys = mediaKeys else {
      return []
    }

    let medias = allMedias.filter { mediaKeys.contains($0.key) }

    return medias
  }

  private func getUser(_ userID: String?) -> Sweet.UserModel? {
    guard let userID = userID else { return nil }

    let firstUser = allUsers.first(where: { $0.id == userID })

    return firstUser
  }

  func getTweet(_ tweetID: String?) -> Sweet.TweetModel? {
    guard let tweetID = tweetID else {
      return nil
    }

    let firstTweet = allTweets.first { $0.id == tweetID }
    return firstTweet
  }

  let pages = ["User", "Tweet"]

  @State var selection: Int = 0

  var body: some View {
    NavigationView {
      VStack {
        Picker("Menu", selection: $selection) {
          ForEach(0..<pages.count, id: \.self) { index in
            Text(pages[index])
              .tag(index)
          }
        }
        .pickerStyle(.segmented)

        TabView(selection: $selection) {
          List(searchUserIDs, id: \.self) { userID in
            HStack {
              let user = getUser(userID)!
              ProfileImageView(user.profileImageURL)
                .frame(width: 30, height: 30)
              Text(user.userName)
            }
          }
          .tag(0)
          List(timelines, id: \.self) { tweetID in
            let tweetModel = getTweet(tweetID)!

            let retweetTweetModel = getTweet(tweetModel.referencedTweet?.id)

            let authorUser = getUser(tweetModel.authorID!)!
            let retweetUser = getUser(retweetTweetModel?.authorID)

            let medias = getMedias(keys: tweetModel.attachments?.mediaKeys)

            let poll = getPoll(key: tweetModel.attachments?.pollID)

            let place = getPlace(placeID: tweetModel.geo?.placeID)

            let viewModel: TweetCellViewModel = .init(tweet: tweetModel, retweet: retweetTweetModel, author: authorUser, retweetUser: retweetUser, medias: medias, poll: poll, place: place)
            TweetCellView(viewModel: viewModel)
              .onAppear {
                guard let lastTweetID = timelines.last else {
                  return
                }

                if tweetModel.id == lastTweetID {
                  Task {
                    await searchTweet(old: lastTweetID)
                  }
                }
              }
          }
          .tag(1)
          .tabViewStyle(.page(indexDisplayMode: .never))
        }
      }

    }
    .navigationViewStyle(.stack)
    .searchable(text: $searchText, prompt: Text("Search Keyword"))
    .refreshable {
      guard let firstTweetID = timelines.first else { return }
      await searchTweet(latest: firstTweetID)
    }
    .onSubmit(of: .search) {
      Task {
        await searchTweet()
      }

      Task {
        await searchUser()
      }
    }
  }
}
