//
//  AccountSettingView.swift
//  Tuna
//
//  Created by zunda on 2022/05/22.
//

import SwiftUI
import Sweet


struct AccountSettingView: View {
  let user: Sweet.UserModel

  var body: some View {
    Text(user.userName)
  }
}

struct AccountSettingView_Previews: PreviewProvider {
  static var previews: some View {
    AccountSettingView(user: .init(id: "", name: "'", userName: ""))
  }
}
