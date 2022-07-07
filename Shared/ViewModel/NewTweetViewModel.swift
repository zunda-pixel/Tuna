//
//  CreateTweetViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/03/26.
//

import CoreLocation
import Sweet
import PhotosUI
import Photos
import SwiftUI

@MainActor protocol NewTweetViewProtocol: NSObject, ObservableObject, CLLocationManagerDelegate {
  var userID: String { get }
  var text: String { get set }
  var selectedReplySetting: Sweet.ReplySetting { get set }
  var didError: Bool { get set }
  var locationString: String? { get set }
  var poll: Sweet.PostPollModel? { get set }
  var photos: [Photo] { get set }
  var photosPickerItems: [PhotosPickerItem] { get set }
  var error: Error? { get set }
  var disableTweetButton: Bool { get }
  var locationManager: CLLocationManager { get }
  var leftTweetCount: Int { get }
  var loadingLocation: Bool { get set }
  var quotedTweet: Sweet.TweetModel? { get }
  func tweet() async
  func setLocation() async
  func loadPhotos(with pickers: [PhotosPickerItem]) async
  func pollButtonAction()
}

final class NewTweetViewModel: NSObject, NewTweetViewProtocol {
  @Published var text = ""
  @Published var selectedReplySetting: Sweet.ReplySetting = .everyone
  @Published var didError = false
  @Published var locationString: String?
  @Published var poll: Sweet.PostPollModel?
  @Published var photos: [Photo] = []
  @Published var photosPickerItems: [PhotosPickerItem] = []
  @Published var loadingLocation: Bool = false

  let userID: String
  let quotedTweet: Sweet.TweetModel?

  var error: Error?
  var locationManager: CLLocationManager = .init()

  init(userID: String, quoted quotedTweet: Sweet.TweetModel? = nil) {
    self.userID = userID
    self.quotedTweet = quotedTweet

    super.init()
    locationManager.delegate = self
  }

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

    if photos.count > 1 {
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
      media: nil, poll: poll, quoteTweetID: quotedTweet?.id,
      reply: nil, replySettings: selectedReplySetting)
    do {
      let _ = try await Sweet(userID: userID).createTweet(tweet)
    } catch {
      self.error = error
    }
  }

  var leftTweetCount: Int {
    return 280 - text.count
  }

  func setLocation() async {
    loadingLocation = true

    defer {
      loadingLocation = false
    }

    guard let location = locationManager.location else {
      return
    }

    do {
      let places = try await CLGeocoder().reverseGeocodeLocation(location)

      guard let place = places.first else {
        return
      }

      self.locationString = (place.locality ?? "") + (place.name ?? "")
    } catch let newError {
      self.error = newError
    }
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    Task {
      await setLocation()
    }
  }

  func loadPhotos(with pickers: [PhotosPickerItem]) async {
    let oldPhotos = photos
    var newPhotos: [Photo] = []

    do {
      for picker in pickers {
        if let foundPhoto = oldPhotos.first(where: { $0.id == picker.itemIdentifier }) {
          newPhotos.append(foundPhoto)
        } else {
          let item = try await picker.loadPhoto()
          let newPhoto = Photo(id: picker.itemIdentifier, item: item)
          newPhotos.append(newPhoto)
        }

        photos = newPhotos
      }

      photos = newPhotos
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }
  func pollButtonAction() {
    if poll?.options == nil || poll!.options.count < 2 {
      poll = .init(options: ["", ""], durationMinutes: 10)
    } else {
      poll = nil
    }
  }
}
