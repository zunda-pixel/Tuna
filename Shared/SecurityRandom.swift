//
//  SecurityRandom.swift
//  Tuna
//
//  Created by zunda on 2022/03/23.
//

import Foundation

struct SecurityRandom {
  static func secureRandomBytes(count: Int) -> [Int8] {
    var bytes = [Int8](repeating: 0, count: count)

    let status = SecRandomCopyBytes(
      kSecRandomDefault,
      count,
      &bytes
    )

    if status == errSecSuccess {
      return bytes
    } else {
      fatalError()
    }
  }
}
