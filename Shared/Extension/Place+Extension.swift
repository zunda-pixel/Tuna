//
//  Place+Extension.swift
//  Tuna
//
//  Created by zunda on 2022/03/25.
//

import Foundation
import Sweet

extension Place {
  func setPlaceModel(_ place: Sweet.PlaceModel) {
    self.id = place.id
    self.name = place.name
  }
}
