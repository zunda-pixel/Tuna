//
//  View+Extension.swift
//  Tuna
//
//  Created by zunda on 2022/05/22.
//

import SwiftUI

extension View {
  func `if`<T: View>(_ conditional: Bool, transform: (Self) -> T) -> some View {
    Group {
      if conditional {
        transform(self)
      } else {
        self
      }
    }
  }
}
