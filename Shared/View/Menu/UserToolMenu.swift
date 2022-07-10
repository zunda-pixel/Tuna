//
//  UserToolMenu.swift
//  Tuna
//
//  Created by zunda on 2022/05/23.
//

import SwiftUI
import Sweet

struct UserToolMenu: View {
  let fromUserID: String
  let toUserID: String

  @Binding var error: Error?
  @Binding var didError: Bool

  var body: some View {
    Menu {
      FollowButton(fromUserID: fromUserID, toUserID: toUserID, error: $error, didError: $didError)
      UnFollowButton(fromUserID: fromUserID, toUserID: toUserID, error: $error, didError: $didError)

      BlockButton(fromUserID: fromUserID, toUserID: toUserID, error: $error, didError: $didError)
      UnBlockButton(fromUserID: fromUserID, toUserID: toUserID, error: $error, didError: $didError)
      
      MuteButton(fromUserID: fromUserID, toUserID: toUserID, error: $error, didError: $didError)
      UnMuteButton(fromUserID: fromUserID, toUserID: toUserID, error: $error, didError: $didError)
    } label: {
      Image(systemName: "ellipsis")
    }
  }
}
