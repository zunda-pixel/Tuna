//
//  KeychainAccess+Extension.swift
//  Tuna
//
//  Created by zunda on 2022/03/23.
//

import Foundation
import KeychainAccess

extension Keychain {
  convenience init() {
    self.init(service: Secret.bundleIdentifier)
  }
}
