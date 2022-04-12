//
//  TwitterOauth2+Extension.swift
//  Tuna
//
//  Created by zunda on 2022/03/23.
//

import Foundation

extension TwitterOAuth2 {
  init() {
    self.init(clientID: Secret.clientID, clientSecretKey: Secret.clientSecretKey)
  }
}
