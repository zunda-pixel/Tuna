//
//  CGSize+Extension.swift
//  Tuna
//
//  Created by zunda on 2022/06/21.
//

import CoreGraphics

extension CGSize {
  var center: CGPoint {
    return .init(x: self.width / 2, y: self.height / 2)
  }
}
