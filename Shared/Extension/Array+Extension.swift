//
//  Array+Extension.swift
//  Tuna
//
//  Created by zunda on 2022/04/18.
//

import Foundation

extension RangeReplaceableCollection where Element: Equatable {
  mutating func appendIfNotContains(_ element: Element) {
    if !contains(element) {
      append(element)
    }
  }
}
