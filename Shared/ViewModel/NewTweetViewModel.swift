//
//  CreateTweetViewModel.swift
//  Tuna
//
//  Created by zunda on 2022/03/26.
//

import Foundation
import Sweet
import CoreLocation

enum NewTweetError: Error, LocalizedError {
  case reverseGeocodeLocation
	
	var localizedDescription: String {
		switch self {
			case .reverseGeocodeLocation: return "can not get geocode"
		}
	}
}

@MainActor final class NewTweetViewModel: ObservableObject {
  @Published public var text = ""
  @Published public var selectedReplySetting: Sweet.ReplySetting = .everyone
  @Published public var didFail = false
  @Published public var locationString: String?
  @Published public var poll: Sweet.PostPollModel?
  @Published public var medias: [String] = []
  @Published public var error: Error?
  

	public var disableTweetButton: Bool {
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

  public func tweet() async {
    let tweet = Sweet.PostTweetModel(text: text, directMessageDeepLink: nil,
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
  
  public func getLeftTweetCount() -> Int {
    return 280 - text.count
  }
  
  public func setLocation() async {
    let locationManager = CLLocationManager()

    guard let location = locationManager.location else {
      locationManager.requestWhenInUseAuthorization()
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

