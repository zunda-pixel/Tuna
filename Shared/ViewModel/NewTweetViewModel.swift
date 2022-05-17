//
//  CreateTweetViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/03/26.
//

import CoreLocation
import Foundation
import Sweet

enum NewTweetError: Error, LocalizedError {
  case reverseGeocodeLocation

  var localizedDescription: String {
    switch self {
    case .reverseGeocodeLocation: return "can not get geocode"
    }
  }
}

@MainActor protocol NewTweetViewModelProtocol: ObservableObject {
  var text: String { get set }
  var selectedReplySetting: Sweet.ReplySetting { get set }
  var didFail: Bool { get set }
  var locationString: String? { get set }
  var poll: Sweet.PostPollModel? { get set }
  var medias: [String] { get set }
  var isPresentedPhotoPicker: Bool { get set }
  var results: [PhotoResult] { get set }
  var didPickPhoto: Bool { get set }
  var error: Error? { get set }
  var disableTweetButton: Bool { get }
  var leftTweetCount: Int { get }
  func tweet() async
  func setLocation() async
}

@MainActor final class NewTweetViewModel: NewTweetViewModelProtocol {
  @Published var text = ""
  @Published var selectedReplySetting: Sweet.ReplySetting = .everyone
  @Published var didFail = false
  @Published var locationString: String?
  @Published var poll: Sweet.PostPollModel?
  @Published var medias: [String] = []
  @Published var isPresentedPhotoPicker = false
  @Published var results: [PhotoResult] = []
  @Published var didPickPhoto = true
  @Published var error: Error?

  var disableTweetButton: Bool {
    if let poll = poll {
      for option in poll.options {
        if option.count < 1 {
          return true
        }
      }
    }

    if text.count > 280 {
      return true
    }

    if medias.count > 1 {
      return false
    }

    if text.count < 1 {
      return true
    }

    return false
  }

  func tweet() async {
    let tweet = Sweet.PostTweetModel(
      text: text, directMessageDeepLink: nil,
      forSuperFollowersOnly: false, geo: nil,
      media: nil, poll: poll, quoteTweetID: nil,
      reply: nil, replySettings: selectedReplySetting)
    do {
      let sweet = try await Sweet()
      let _ = try await sweet.createTweet(tweet)
    } catch {
      self.error = error
    }
  }

  var leftTweetCount: Int {
    return 280 - text.count
  }

  func setLocation() async {
    let locationManager = CLLocationManager()

    guard let location = locationManager.location else {
      return
    }

    do {
      let places = try await CLGeocoder().reverseGeocodeLocation(location)

      guard let place = places.first else {
        return
      }

      self.locationString = (place.locality ?? "") + (place.name ?? "")
    } catch {
      self.error = NewTweetError.reverseGeocodeLocation
    }
  }
}
