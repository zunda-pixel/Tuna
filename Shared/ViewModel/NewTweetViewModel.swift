//
//  CreateTweetViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/03/26.
//

import Foundation
import Sweet
import CoreLocation

@MainActor final class NewTweetViewModel: ObservableObject {
  @Published public var text = ""
  @Published public var selectedReplySetting: Sweet.ReplySetting = .everyone
  @Published public var didFail = false
  @Published public var locationString: String?
  @Published public var poll: Sweet.PostPollModel?
  @Published public var medias: [String] = []
  @Published public var error: Error?
  
  public func tweet() async throws {
    let tweet = Sweet.PostTweetModel(text: text, directMessageDeepLink: nil, forSuperFollowersOnly: false, geo: nil, media: nil, poll: poll, quoteTweetID: nil, reply: nil, replySettings: selectedReplySetting)
    let sweet = try await Sweet()
    let _ = try await sweet.createTweet(tweet)
  }
  
  public func getLeftTweetCount() -> Int {
    return 280 - text.count
  }
  
  public func setLocation() async {
    let locationManager = CLLocationManager()

    guard let location = locationManager.location else {
      locationManager.requestWhenInUseAuthorization()
      return
    }
    
    let geocoder = CLGeocoder()
    
    let places = try? await geocoder.reverseGeocodeLocation(location)
        
    self.locationString =  places?.last?.name
  }
}

