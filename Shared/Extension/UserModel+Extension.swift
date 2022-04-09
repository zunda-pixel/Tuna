//
//  UserModel+Extension.swift
//  Tuna
//
//  Created by zunda on 2022/03/24.
//

import Foundation
import Sweet

extension Sweet.UserModel {
  public init(user: User) {
    let decoder = JSONDecoder()
    let emptyData = Data()
    let metrics = try? decoder.decode(Sweet.UserPublicMetrics.self, from: user.metrics ?? emptyData)
    let withheld = try? decoder.decode(Sweet.WithheldModel.self, from: user.withheld ?? emptyData)
    let entity = try? decoder.decode(Sweet.EntityModel.self, from: user.entities ?? emptyData)
    
    self.init(id: user.id!, name: user.name!, userName: user.userName!, verified: user.verified, profileImageURL: user.profileImageURL, description: user.descriptions, protected: user.protected, url: user.url, createdAt: user.createdAt, location: user.location, pinnedTweetID: user.pinnedTweetID, metrics: metrics, withheld: withheld, entity: entity)
  }
}
