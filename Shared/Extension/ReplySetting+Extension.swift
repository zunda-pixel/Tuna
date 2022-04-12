//
//  ReplySetting.swift
//  Tuna
//
//  Created by zunda on 2022/04/11.
//

import Sweet

extension Sweet.ReplySetting {
  var description: String {
    switch self {
    case .mentionedUsers: return "People you mention"
    case .following: return "People you follow or mention"
    case .everyone: return "Everyone"
    }
  }
}
