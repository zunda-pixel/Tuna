//
//  User+Extension.swift
//  Tuna
//
//  Created by zunda on 2022/03/24.
//

import Foundation
import Sweet

extension User {
  public func setUserModel(_ user: Sweet.UserModel) throws {
    self.id = user.id
    self.name = user.name
    self.userName = user.userName
    self.verified = user.verified ?? false
    self.profileImageURL = user.profileImageURL
    self.descriptions = user.description
    self.protected = user.protected ?? false
    self.url = user.url
    self.createdAt = user.createdAt
    self.location = user.location
    self.pinnedTweetID = user.pinnedTweetID
    
    let encoder = JSONEncoder()
    self.metrics = try encoder.encode(user.metrics)
    self.withheld = try encoder.encode(user.withheld)
    self.entities = try encoder.encode(user.entity)
  }
}
