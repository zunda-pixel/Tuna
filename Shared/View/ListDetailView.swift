//
//  ListDetailView.swift
//  Tuna
//
//  Created by zunda on 2022/03/29.
//

import Sweet
import SwiftUI

struct ListDetailView: View {
  let list: Sweet.ListModel
  @State var paginationToken: String? = nil

  @State private var timelines: [String] = []
  @State private var allTweets: [Sweet.TweetModel] = []
  @State private var allUsers: [Sweet.UserModel] = []
  @State private var allMedias: [Sweet.MediaModel] = []
  @State private var allPolls: [Sweet.PollModel] = []
  @State private var allPlaces: [Sweet.PlaceModel] = []

  init(list: Sweet.ListModel) {
    self.list = list
  }

  private func getPlace(placeID: String?) -> Sweet.PlaceModel? {
    guard let placeID = placeID,
          let firstPlace = allPlaces.first(where: { $0.id == placeID })
    else {
      return nil
    }

    return firstPlace
  }

  private func getPoll(pollKey: String?) -> Sweet.PollModel? {
    guard let pollKey = pollKey,
      let firstPoll = allPolls.first(where: { $0.id == pollKey })
    else {
      return nil
    }

    return firstPoll
  }

  private func getMedias(mediaKeys: [String]?) -> [Sweet.MediaModel] {
    guard let mediaKeys = mediaKeys else {
      return []
    }

    let medias = allMedias.filter { mediaKeys.contains($0.key) }

    return medias
  }

  private func getAuthorUser(authorID: String?) -> Sweet.UserModel? {
    guard let authorID = authorID,
      let user = allUsers.first(where: { $0.id == authorID })
    else {
      return nil
    }

    return user
  }

  private func getRetweetTweet(retweetID: String?) -> Sweet.TweetModel? {
    guard let retweetID = retweetID else {
      return nil
    }

    let retweetTweet = allTweets.first { $0.id == retweetID }

    return retweetTweet
  }

  func getListTweets() async throws {
    let sweet = try await Sweet()
    let listResponse = try await sweet.fetchListTweets(listID: list.id, paginationToken: paginationToken)

    paginationToken = listResponse.meta?.nextToken

    let tweetIDs = listResponse.tweets.map(\.id)

    let tweetResponse = try await sweet.lookUpTweets(by: tweetIDs)

    allTweets.append(contentsOf: tweetResponse.tweets)
    allTweets.append(contentsOf: tweetResponse.relatedTweets)
    allUsers.append(contentsOf: tweetResponse.users)
    allPolls.append(contentsOf: tweetResponse.polls)
    allMedias.append(contentsOf: tweetResponse.medias)
    allPlaces.append(contentsOf: tweetResponse.places)

    timelines.append(contentsOf: tweetIDs)
  }

  func getTweet(_ tweetID: String) -> Sweet.TweetModel? {
    let firstTweet = allTweets.first { $0.id == tweetID }
    return firstTweet
  }

  var body: some View {
    VStack {
      Text(list.name)
      Text(list.description!)

      HStack {
        Text("\(list.memberCount!) members")
        Text("\(list.followerCount!) followers")
      }
    }

    List(timelines, id: \.self) { tweetID in
      let tweetModel = getTweet(tweetID)!

      let retweetTweetModel = getRetweetTweet(retweetID: tweetModel.referencedTweet?.id)

      let authorUser = getAuthorUser(authorID: tweetModel.authorID!) ?? .init(id: "", name: "", userName: "")
      let retweetUser = getAuthorUser(authorID: retweetTweetModel?.authorID)

      let medias = getMedias(mediaKeys: tweetModel.attachments?.mediaKeys)

      let poll = getPoll(pollKey: tweetModel.attachments?.pollID)

      let place = getPlace(placeID: tweetModel.geo?.placeID)

      TweetCellView(viewModel: .init(tweet: tweetModel, retweet: retweetTweetModel, author: authorUser, retweetUser: retweetUser, medias: medias, poll: poll, place: place))

      .onAppear {
        guard let lastTweetID = timelines.last else{
          return
        }

        if tweetModel.id == lastTweetID {
          Task {
            do {
              try await getListTweets()
            } catch {
              print(error)
              fatalError()
            }
          }
        }
      }
    }
    .onAppear {
      Task {
        do {
          try await getListTweets()
        } catch {
          print(error)
          fatalError()
        }
      }
    }
    .refreshable {
      do {
        try await getListTweets()
      } catch {
        print(error)
        fatalError()
      }
    }
  }
}

struct ListDetailView_Previews: PreviewProvider {
  static var previews: some View {
    ListDetailView(list: .init(id: "", name: ""))
  }
}
