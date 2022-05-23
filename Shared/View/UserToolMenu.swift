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

  var body: some View {
    Menu {
      FollowButton(viewModel: .init(from: fromUserID, to: toUserID))
      BlockButton(viewModel: .init(from: fromUserID, to: toUserID))
      MuteButton(viewModel: .init(from: fromUserID, to: toUserID))
    } label: {
      Image(systemName: "ellipsis")
    }
  }
}

struct UserToolMenu_Previews: PreviewProvider {
    static var previews: some View {
      UserToolMenu(fromUserID: "", toUserID: "")
    }
}
