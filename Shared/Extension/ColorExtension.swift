//
//  ColorExtension.swift
//  Tuna
//
//  Created by zunda on 2022/05/21.
//

import SwiftUI

extension Color {
  static var random: Color {
    return .init(
      red: .random(in: 0...1),
      green: .random(in: 0...1),
      blue: .random(in: 0...1)
    )
  }
}
