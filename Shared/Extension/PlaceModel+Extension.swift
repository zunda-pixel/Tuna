//
//  PlaceModel+Extension.swift
//  Tuna
//
//  Created by zunda on 2022/03/25.
//

import Foundation
import Sweet

extension Sweet.PlaceModel {
  init(place: Place) {
    self.init(id: place.id!, name: place.name!)
  }
}
